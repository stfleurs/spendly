import 'dart:io';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:read_pdf_text/read_pdf_text.dart';
import 'package:pdfx/pdfx.dart' as px;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';

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

enum PDFParserType { syncfusion, fallback, ocr, none }

class PDFExtractionResult {
  final String text;
  final PDFParserType parserType;

  PDFExtractionResult({required this.text, required this.parserType});
}

class ImportRepository {
  Future<List<List<dynamic>>> parseCsv(File file) async {
    try {
      final bytes = await file.readAsBytes();
      
      // Use proper UTF-8 decoding instead of fromCharCodes to fix special characters (é, etc.)
      String input = utf8.decode(bytes, allowMalformed: true);
      
      // Strip UTF-8 BOM if present
      if (input.startsWith('\uFEFF')) {
        input = input.substring(1);
      } else if (input.startsWith('ï»¿')) {
        input = input.substring(3);
      }
      
      // Auto-detect delimiter (comma vs semicolon)
      // French and international banks frequently use semicolons
      // We check the first 10 lines because the very first line might be a title without delimiters.
      final lines = input.split('\n').where((line) => line.trim().isNotEmpty).take(10).toList();
      bool isSemicolonDelimited = false;
      for (final line in lines) {
        if (line.contains(';') && (line.split(';').length > line.split(',').length)) {
          isSemicolonDelimited = true;
          break;
        }
      }
      
      return CsvToListConverter(
        fieldDelimiter: isSemicolonDelimited ? ';' : ',',
      ).convert(input);
    } catch (e) {
      debugPrint('Spendly: Error parsing CSV: $e');
      return [];
    }
  }

  Future<PDFExtractionResult> extractTextFromPdf(File file) async {
    // Tier 1: Syncfusion (Primary)
    try {
      final PdfDocument document = PdfDocument(inputBytes: await file.readAsBytes());
      try {
        final PdfTextExtractor extractor = PdfTextExtractor(document);
        String text = extractor.extractText();
        document.dispose();

        if (text.trim().isNotEmpty) {
          debugPrint('Spendly: PDF extraction successful using Syncfusion');
          return PDFExtractionResult(text: text, parserType: PDFParserType.syncfusion);
        }
      } catch (e) {
        document.dispose();
        debugPrint('Spendly: Syncfusion PDF extraction failed: $e');
      }
    } catch (e) {
      debugPrint('Spendly: Syncfusion failed to open PDF: $e');
    }

    // Tier 2: read_pdf_text (Fallback)
    try {
      debugPrint('Spendly: Attempting fallback PDF extraction with read_pdf_text...');
      final String text = await ReadPdfText.getPDFtext(file.path);
      
      if (text.trim().isNotEmpty) {
        debugPrint('Spendly: PDF extraction successful using fallback (read_pdf_text)');
        return PDFExtractionResult(text: text, parserType: PDFParserType.fallback);
      }
    } catch (e) {
      debugPrint('Spendly: Fallback PDF extraction failed: $e');
    }

    // Tier 3: OCR (Intelligent Fallback)
    try {
      debugPrint('Spendly: Attempting Tier 3 OCR extraction...');
      final String ocrText = await _extractTextWithOcr(file);
      
      if (ocrText.trim().isNotEmpty) {
        debugPrint('Spendly: PDF extraction successful using OCR (ML Kit)');
        return PDFExtractionResult(text: ocrText, parserType: PDFParserType.ocr);
      }
    } catch (e) {
      debugPrint('Spendly: Tier 3 OCR extraction failed: $e');
    }

    // If both failed or returned empty
    throw Exception(
      'Unable to read this PDF statement automatically.\n\n'
      'It might be a scanned image, password-protected, or malformed.\n\n'
      'Try re-saving the PDF using "Print → Save as PDF" or exporting a CSV statement from your bank.'
    );
  }

  Future<String> _extractTextWithOcr(File file) async {
    final textRecognizer = TextRecognizer();
    StringBuffer buffer = StringBuffer();
    
    try {
      final document = await px.PdfDocument.openFile(file.path);
      
      // Limit to first 5 pages for performance as suggested
      final pageCount = document.pagesCount > 5 ? 5 : document.pagesCount;
      
      for (int i = 1; i <= pageCount; i++) {
        final page = await document.getPage(i);
        final pageImage = await page.render(
          width: page.width * 2, // Higher resolution for better OCR
          height: page.height * 2,
          format: px.PdfPageImageFormat.jpeg,
          quality: 100,
        );
        
        if (pageImage != null) {
          // Save to temp file for ML Kit processing
          final tempDir = await getTemporaryDirectory();
          final tempFile = File('${tempDir.path}/page_$i.jpg');
          await tempFile.writeAsBytes(pageImage.bytes);
          
          final inputImageFromFile = InputImage.fromFile(tempFile);
          final RecognizedText recognizedText = await textRecognizer.processImage(inputImageFromFile);
          buffer.writeln(recognizedText.text);
          
          await page.close();
          await tempFile.delete();
          
          // Optimization: If we find clear transaction indicators, we keep going, 
          // but if we hit obvious legal/footer text on later pages, we could stop.
          // For now, we just process up to 5 pages.
        }
      }
      await document.close();
    } catch (e) {
      debugPrint('Spendly: OCR internal failure: $e');
    } finally {
      textRecognizer.close();
    }
    
    return buffer.toString();
  }

  // Basic regex-based parsing for bank statements (PDF)
  // Enhanced to support French/International formats seen in the screenshots
  List<RawImportTransaction> parsePdfText(String text) {
    final List<RawImportTransaction> transactions = [];
    final lines = text.split('\n');
    
    // Improved regex to catch:
    // Dates: 01/11/2026, 01-Nov, 01 Nov 2026, 01.11.26
    final dateRegex = RegExp(r'(\d{1,2}[/.-]\d{1,2}[/.-]\d{2,4})|(\d{1,2}\s+[A-Za-z]{3,}\s*\d{0,4})');
    
    // Amounts: 1.234,56, 1 234,56, -123.45, 1,234.56
    // This catches numbers with decimal separators and optional thousands separators
    final amountRegex = RegExp(r'-?\d{1,3}(?:\s?\d{3})*(?:[.,]\d{2})');

    for (var line in lines) {
      final dateMatch = dateRegex.firstMatch(line);
      final amountMatches = amountRegex.allMatches(line).toList();
      
      // A transaction line usually has a date and at least one amount (debit or credit)
      if (dateMatch != null && amountMatches.isNotEmpty) {
        final date = dateMatch.group(0)!;
        
        // In bank statements, the last amount on a line is often the balance or the total.
        // We take the first amount as the primary transaction value if there's only one,
        // or we try to find the one that isn't the balance.
        final amount = amountMatches.first.group(0)!;
        
        // Description is usually between date and amount
        final dateEnd = dateMatch.end;
        final amountStart = amountMatches.first.start;
        String description = '';
        if (amountStart > dateEnd) {
          description = line.substring(dateEnd, amountStart).trim();
        } else {
          // If amount is before date, description might be after date
          description = line.substring(dateMatch.end).trim();
        }

        if (description.isNotEmpty && description.length > 2) {
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
