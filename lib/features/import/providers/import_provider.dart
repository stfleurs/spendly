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
  final String? error;

  ImportState({
    this.selectedFile,
    this.csvData = const [],
    this.parsedTransactions = const [],
    this.columnMapping = const {},
    this.isLoading = false,
    this.error,
  });

  ImportState copyWith({
    File? selectedFile,
    List<List<dynamic>>? csvData,
    List<RawImportTransaction>? parsedTransactions,
    Map<String, int>? columnMapping,
    bool? isLoading,
    String? error,
  }) {
    return ImportState(
      selectedFile: selectedFile ?? this.selectedFile,
      csvData: csvData ?? this.csvData,
      parsedTransactions: parsedTransactions ?? this.parsedTransactions,
      columnMapping: columnMapping ?? this.columnMapping,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
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
          state = state.copyWith(
            selectedFile: file,
            csvData: data,
            isLoading: false,
            columnMapping: _guessMapping(data),
          );
        } else if (extension == 'pdf') {
          final text = await _repository.extractTextFromPdf(file);
          final transactions = _repository.parsePdfText(text);
          state = state.copyWith(
            selectedFile: file,
            parsedTransactions: transactions,
            isLoading: false,
          );
        }
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Map<String, int> _guessMapping(List<List<dynamic>> data) {
    if (data.isEmpty) return {};
    final headers = data[0].map((e) => e.toString().toLowerCase()).toList();
    final mapping = <String, int>{};

    for (int i = 0; i < headers.length; i++) {
      final h = headers[i];
      if (h.contains('date')) mapping['date'] = i;
      if (h.contains('desc') || h.contains('merchant') || h.contains('payee')) mapping['description'] = i;
      if (h.contains('amount') || h.contains('value') || h.contains('total')) mapping['amount'] = i;
    }

    return mapping;
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

    if (dateIdx == null || descIdx == null || amountIdx == null) return;

    // Skip header
    for (int i = 1; i < state.csvData.length; i++) {
      final row = state.csvData[i];
      if (row.length <= dateIdx || row.length <= descIdx || row.length <= amountIdx) continue;

      transactions.add(RawImportTransaction(
        date: row[dateIdx].toString(),
        description: row[descIdx].toString(),
        amount: row[amountIdx].toString(),
      ));
    }

    state = state.copyWith(parsedTransactions: transactions);
  }
}

final importProvider = StateNotifierProvider<ImportNotifier, ImportState>((ref) {
  return ImportNotifier(ref.read(importRepositoryProvider));
});
