import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class ParsedReceipt {
  final String? merchant;
  final int? total; // Cents
  final DateTime? date;
  final double confidence;
  final List<String> rawLines;

  ParsedReceipt({
    this.merchant,
    this.total,
    this.date,
    required this.confidence,
    required this.rawLines,
  });
}

class ReceiptParser {
  static ParsedReceipt parse(RecognizedText recognizedText) {
    final List<String> lines = [];
    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        lines.add(line.text.trim());
      }
    }
    return parseFromLines(lines);
  }

  static ParsedReceipt parseFromLines(List<String> lines) {
    String? merchant;
    int? total;
    DateTime? date;
    double confidence = 0.0;

    // 1. Merchant Detection (Priority: Top 5 lines, filtered)
    for (int i = 0; i < lines.length && i < 5; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;
      
      // Filter out lines with obvious non-merchant data
      if (RegExp(r'\d').hasMatch(line) && !RegExp(r'[A-Za-z]').hasMatch(line)) {
        continue;
      }
      if (line.toLowerCase().contains('tel') || 
          line.toLowerCase().contains('phone') || 
          line.contains('+') || 
          line.contains(':')) {
        continue;
      }
      if (line.toLowerCase().contains('date') || line.contains('/')) {
        continue;
      }
      
      merchant = line;
      confidence += 0.2;
      break;
    }

    // 2. Amount Detection (Priority: Keywords > Largest Number)
    total = _findAmountByKeywords(lines);
    if (total != null) {
      confidence += 0.4;
    } else {
      total = _findLargestAmount(lines);
    }

    // 3. Date Detection
    date = _findDate(lines);
    if (date != null) {
      confidence += 0.3;
    } else {
      date = DateTime.now(); // Fallback
    }

    // 4. Currency Detection
    final hasCurrency = lines.any((l) => 
      l.contains('\$') || 
      l.toUpperCase().contains('HTG') || 
      l.toUpperCase().contains('USD'));
    if (hasCurrency) confidence += 0.1;

    return ParsedReceipt(
      merchant: merchant,
      total: total,
      date: date,
      confidence: confidence.clamp(0.0, 1.0),
      rawLines: lines,
    );
  }

  static int? _findAmountByKeywords(List<String> lines) {
    final keywords = ['GRAND TOTAL', 'TOTAL', 'AMOUNT', 'BALANCE', 'DUE', 'NET'];
    for (final kw in keywords) {
      for (final line in lines) {
        final upper = line.toUpperCase();
        if (upper.contains(kw)) {
          // Avoid matching SUBTOTAL when looking for TOTAL
          if (kw == 'TOTAL' && upper.contains('SUBTOTAL')) {
            continue;
          }

          final amount = _extractAmount(line);
          if (amount != null) {
            return amount;
          }

          // If amount not on same line, look at the next line
          final idx = lines.indexOf(line);
          if (idx != -1 && idx < lines.length - 1) {
            final nextAmount = _extractAmount(lines[idx + 1]);
            if (nextAmount != null) {
              return nextAmount;
            }
          }
        }
      }
    }
    return null;
  }

  static int? _findLargestAmount(List<String> lines) {
    int? maxAmount;
    for (final line in lines) {
      final amount = _extractAmount(line);
      if (amount != null) {
        if (maxAmount == null || amount > maxAmount) {
          maxAmount = amount;
        }
      }
    }
    return maxAmount;
  }

  static int? _extractAmount(String text) {
    // Robust numeric extraction for currencies (e.g., 1,234.56 or 1234.56)
    final regex = RegExp(r'(\d{1,3}(?:,\d{3})*(?:\.\d{2})?)');
    final matches = regex.allMatches(text);
    if (matches.isNotEmpty) {
      try {
        final match = matches.last.group(0)!;
        final clean = match.replaceAll(',', '');
        return (double.parse(clean) * 100).round();
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  static DateTime? _findDate(List<String> lines) {
    final regexes = [
      RegExp(r'(\d{4})[-/](\d{1,2})[-/](\d{1,2})'), // YYYY-MM-DD
      RegExp(r'(\d{1,2})[-/](\d{1,2})[-/](\d{2,4})'), // DD/MM/YY or MM/DD/YY
      RegExp(r'(\d{1,2})\s+([A-Za-z]{3,})\s+(\d{4})'), // DD Month YYYY
    ];

    for (final line in lines) {
      for (final reg in regexes) {
        final match = reg.firstMatch(line);
        if (match != null) {
          try {
            final g1 = match.group(1)!;
            final g2 = match.group(2)!;
            final g3 = match.group(3)!;

            // Handle "DD Month YYYY"
            if (int.tryParse(g2) == null) {
              final months = ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec'];
              final monthIdx = months.indexWhere((m) => g2.toLowerCase().startsWith(m));
              if (monthIdx != -1) {
                return DateTime(int.parse(g3), monthIdx + 1, int.parse(g1));
              }
            }

            final n1 = int.parse(g1);
            final n2 = int.parse(g2);
            final n3 = int.parse(g3);

            if (n1 > 1000) {
              return DateTime(n1, n2, n3);
            } // YYYY-MM-DD

            // Heuristic for DD/MM vs MM/DD
            if (n1 > 12) {
              return DateTime(n3 > 100 ? n3 : 2000 + n3, n2, n1);
            }
            return DateTime(n3 > 100 ? n3 : 2000 + n3, n1, n2);
          } catch (_) {}
        }
      }
    }
    return null;
  }
}
