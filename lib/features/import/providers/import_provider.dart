import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:spendly/features/import/repository/import_repository.dart';

final importRepositoryProvider = Provider((ref) => ImportRepository());

class ImportState {
  final File? selectedFile;
  final List<List<dynamic>> csvData;
  final List<RawImportTransaction> parsedTransactions;
  final Map<String, int> columnMapping; // "date" -> 0, "description" -> 1, etc.
  final bool isLoading;
  final String? loadingMessage;
  final String? error;
  final PDFParserType? parserType;
  final int headerRowIndex;

  ImportState({
    this.selectedFile,
    this.csvData = const [],
    this.parsedTransactions = const [],
    this.columnMapping = const {},
    this.isLoading = false,
    this.loadingMessage,
    this.error,
    this.parserType,
    this.headerRowIndex = 0,
  });

  ImportState copyWith({
    File? selectedFile,
    List<List<dynamic>>? csvData,
    List<RawImportTransaction>? parsedTransactions,
    Map<String, int>? columnMapping,
    bool? isLoading,
    String? loadingMessage,
    String? error,
    PDFParserType? parserType,
    int? headerRowIndex,
  }) {
    return ImportState(
      selectedFile: selectedFile ?? this.selectedFile,
      csvData: csvData ?? this.csvData,
      parsedTransactions: parsedTransactions ?? this.parsedTransactions,
      columnMapping: columnMapping ?? this.columnMapping,
      isLoading: isLoading ?? this.isLoading,
      loadingMessage: loadingMessage ?? this.loadingMessage,
      error: error ?? this.error,
      parserType: parserType ?? this.parserType,
      headerRowIndex: headerRowIndex ?? this.headerRowIndex,
    );
  }
}

class MappingResult {
  final Map<String, int> mapping;
  final int headerIndex;
  MappingResult(this.mapping, this.headerIndex);
}

class ImportNotifier extends StateNotifier<ImportState> {
  final ImportRepository _repository;

  ImportNotifier(this._repository) : super(ImportState());

  Future<void> pickFile() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'pdf'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final extension = result.files.single.extension?.toLowerCase();

        if (extension == 'csv') {
          final data = await _repository.parseCsv(file);
          final mappingResult = _guessMapping(data);
          state = state.copyWith(
            selectedFile: file,
            csvData: data,
            isLoading: false,
            headerRowIndex: mappingResult.headerIndex,
            columnMapping: mappingResult.mapping,
          );
        } else if (extension == 'pdf') {
          state = state.copyWith(isLoading: true, loadingMessage: 'Processing PDF...', error: null);
          final result = await _repository.extractTextFromPdf(file);
          
          if (result.parserType == PDFParserType.ocr) {
            state = state.copyWith(loadingMessage: 'Recovering text with AI OCR...');
          }
          
          final transactions = _repository.parsePdfText(result.text);
          state = state.copyWith(
            selectedFile: file,
            parsedTransactions: transactions,
            isLoading: false,
            loadingMessage: null,
            parserType: result.parserType,
          );
        }
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  MappingResult _guessMapping(List<List<dynamic>> data) {
    if (data.isEmpty) return MappingResult({}, 0);
    
    // We try to find the actual header row by looking for a row that contains definitive transaction keywords
    // like "description" or "merchant", rather than just "date" which often appears in metadata.
    int headerRowIndex = 0;
    for (int i = 0; i < data.length && i < 20; i++) {
      final row = data[i].map((e) => e.toString().toLowerCase()).toList();
      
      // A strong indicator of a transaction table header is a "description" or "libellé" column
      if (row.any((cell) => cell.contains('description') || cell.contains('libellé') || cell.contains('merchant') || cell.contains('payee'))) {
        headerRowIndex = i;
        break;
      }
      
      // Fallback: row contains both 'date' and ('montant' or 'amount')
      bool hasDate = row.any((cell) => cell.contains('date'));
      bool hasAmount = row.any((cell) => cell.contains('montant') || cell.contains('amount') || cell.contains('débit'));
      if (hasDate && hasAmount) {
        headerRowIndex = i;
        break;
      }
    }

    final headers = data[headerRowIndex].map((e) => e.toString().toLowerCase()).toList();
    final mapping = <String, int>{};

    for (int i = 0; i < headers.length; i++) {
      final h = headers[i];
      // English & French keywords
      if (h.contains('date')) mapping['date'] = i;
      if (h.contains('desc') || h.contains('merchant') || h.contains('payee') || h.contains('libellé') || h.contains('détail')) mapping['description'] = i;
      
      // Amount mapping logic
      if (h.contains('amount') || h.contains('value') || h.contains('total')) {
        if (!h.contains('débit') && !h.contains('crédit')) mapping['amount'] = i;
      }
      // Specifically catch French debit/credit columns
      if (h.contains('débit') || h.contains('debit')) mapping['debit'] = i;
      if (h.contains('crédit') || h.contains('credit')) mapping['credit'] = i;
    }

    return MappingResult(mapping, headerRowIndex);
  }

  void updateMapping(String field, int index) {
    final newMapping = Map<String, int>.from(state.columnMapping);
    newMapping[field] = index;
    state = state.copyWith(columnMapping: newMapping);
  }

  void parseCsvWithMapping() {
    if (state.csvData.length < 2) return;
    
    final List<RawImportTransaction> transactions = [];
    final mapping = state.columnMapping;
    
    final dateIdx = mapping['date'];
    final descIdx = mapping['description'];
    final amountIdx = mapping['amount'];
    final debitIdx = mapping['debit'];
    final creditIdx = mapping['credit'];

    if (dateIdx == null || descIdx == null) return;
    if (amountIdx == null && debitIdx == null && creditIdx == null) return;

    // Skip until we find the actual data
    // We assume the data starts after the header row we found in _guessMapping
    // Or we just skip any row that doesn't have a valid date in the date column
    int startIdx = 0;
    for (int i = 0; i < state.csvData.length; i++) {
      if (state.csvData[i].length <= dateIdx) continue;
      final cell = state.csvData[i][dateIdx].toString().toLowerCase();
      if (RegExp(r'\d').hasMatch(cell)) {
        startIdx = i;
        break;
      }
    }

    for (int i = startIdx; i < state.csvData.length; i++) {
      final row = state.csvData[i];
      if (row.length <= dateIdx || row.length <= descIdx) continue;

      final date = row[dateIdx].toString();
      final desc = row[descIdx].toString();
      
      String amount = '';
      if (amountIdx != null && amountIdx < row.length) {
        amount = row[amountIdx].toString();
      } else {
        // Handle split debit/credit columns
        double creditVal = 0;
        double debitVal = 0;
        
        if (creditIdx != null && creditIdx < row.length) {
          final s = row[creditIdx].toString().replaceAll(RegExp(r'[^0-9.-]'), '');
          creditVal = double.tryParse(s) ?? 0;
        }
        if (debitIdx != null && debitIdx < row.length) {
          final s = row[debitIdx].toString().replaceAll(RegExp(r'[^0-9.-]'), '');
          debitVal = double.tryParse(s) ?? 0;
        }
        
        if (creditVal > 0) {
          amount = creditVal.toString();
        } else if (debitVal > 0) {
          amount = (-debitVal).toString();
        } else {
          amount = '0'; // Empty or 0 values
        }
      }

      if (date.isNotEmpty && desc.isNotEmpty && amount.isNotEmpty && amount != '0') {
        transactions.add(RawImportTransaction(
          date: date,
          description: desc,
          amount: amount,
        ));
      }
    }

    state = state.copyWith(parsedTransactions: transactions);
  }
}

final importProvider = StateNotifierProvider<ImportNotifier, ImportState>((ref) {
  return ImportNotifier(ref.read(importRepositoryProvider));
});
