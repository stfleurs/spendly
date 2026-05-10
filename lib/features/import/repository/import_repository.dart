import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class RawImportTransaction {
  final String date;
  final String description;
  final String amount;
  final Map<String, String> extraData;

  RawImportTransaction({
    required this.date,
    required this.description,
    required this.amount,
    this.extraData = const {},
  });
}

class ImportRepository {
  Future<List<List<dynamic>>> parseCsv(File file) async {
    try {
      final input = await file.readAsString();
      return const CsvToListConverter().convert(input);
    } catch (e) {
      debugPrint('Spendly: Error parsing CSV: $e');
      return [];
    }
  }

  Future<String> extractTextFromPdf(File file) async {
    try {
      final PdfDocument document = PdfDocument(inputBytes: await file.readAsBytes());
      final PdfTextExtractor extractor = PdfTextExtractor(document);
      String text = extractor.extractText();
      document.dispose();
      return text;
    } catch (e) {
      debugPrint('Spendly: Error extracting text from PDF: $e');
      return '';
    }
  }

  // Basic regex-based parsing for bank statements (PDF)
  // This is a simplified version; real bank statements vary wildly.
  List<RawImportTransaction> parsePdfText(String text) {
    final List<RawImportTransaction> transactions = [];
    final lines = text.split('\n');
    
    // Example regex for Date (MM/DD/YYYY or DD/MM/YYYY) and Amount
    // This is just a starting point.
    final dateRegex = RegExp(r'\d{1,2}[/-]\d{1,2}[/-]\d{2,4}');
    final amountRegex = RegExp(r'-?\d+[\.,]\d{2}');

    for (var line in lines) {
      final dateMatch = dateRegex.firstMatch(line);
      final amountMatches = amountRegex.allMatches(line).toList();
      
      if (dateMatch != null && amountMatches.isNotEmpty) {
        final date = dateMatch.group(0)!;
        final amount = amountMatches.last.group(0)!; // Usually the last amount on the line is the total for that row
        
        // Description is usually between date and amount
        final dateEnd = dateMatch.end;
        final amountStart = amountMatches.last.start;
        String description = '';
        if (amountStart > dateEnd) {
          description = line.substring(dateEnd, amountStart).trim();
        }

        if (description.isNotEmpty) {
          transactions.add(RawImportTransaction(
            date: date,
            description: description,
            amount: amount,
          ));
        }
      }
    }
    
    return transactions;
  }
}
