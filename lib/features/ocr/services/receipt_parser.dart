import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:spendly/core/models/receipt.dart';

class ParsedReceipt {
  final String? merchant;
  final String? address;
  final String? phone;
  final String? email;
  final int? subtotal;
  final int? tax;
  final int? total;
  final DateTime? date;
  final String? paymentMethod;
  final String? receiptNumber;
  final double confidence;
  final List<OCRLine> lines;
  final List<ReceiptItem> items;

  ParsedReceipt({
    this.merchant,
    this.address,
    this.phone,
    this.email,
    this.subtotal,
    this.tax,
    this.total,
    this.date,
    this.paymentMethod,
    this.receiptNumber,
    required this.confidence,
    required this.lines,
    required this.items,
  });
}

class ReceiptParser {
  // Generic words that appear on receipts but are NOT merchant names
  static const _merchantBlocklist = {
    'receipt', 'invoice', 'statement', 'bill', 'order', 'tax invoice',
    'sales receipt', 'purchase receipt', 'receipt #', 'receipt no',
    'thank you', 'welcome', 'customer', 'guest',
  };

  static ParsedReceipt parse(RecognizedText recognizedText) {
    final List<OCRLine> lines = [];
    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        lines.add(OCRLine(
          text: line.text.trim(),
          bounds: line.boundingBox,
        ));
      }
    }
    // Sort lines by vertical position primarily, then horizontal
    lines.sort((a, b) {
      if ((a.top - b.top).abs() < 10) return a.left.compareTo(b.left);
      return a.top.compareTo(b.top);
    });

    return parseFromLines(lines);
  }

  static ParsedReceipt parseFromLines(List<OCRLine> lines) {
    String? merchant;
    String? address;
    String? phone;
    String? email;
    int? subtotal;
    int? tax;
    int? total;
    DateTime? date;
    String? paymentMethod;
    String? receiptNumber;
    double confidence = 0.0;

    // 1. Merchant Detection
    merchant = _findMerchant(lines);
    if (merchant != null) confidence += 0.2;

    // Look for address (multiple lines)
    if (merchant != null) {
      final merchantIdx = lines.indexWhere((l) => l.text == merchant);
      if (merchantIdx != -1) {
        address = _findAddress(lines.sublist(merchantIdx + 1, (merchantIdx + 6).clamp(0, lines.length)));
      }
    }

    // 2. Contact Info Detection
    final contact = _findContactInfo(lines);
    phone = contact['phone'];
    email = contact['email'];

    // 3. Amount Detection
    total = _findAmountByKeywords(lines);
    if (total == null) {
      total = _findLargestAmount(lines);
    } else {
      confidence += 0.4;
    }

    final taxSubtotal = _findTaxAndSubtotal(lines);
    tax = taxSubtotal['tax'];
    subtotal = taxSubtotal['subtotal'];

    // 4. Date Detection
    date = _findDate(lines);
    if (date != null) {
      confidence += 0.2;
    } else {
      date = DateTime.now();
    }

    // 5. Additional Metadata
    paymentMethod = _findPaymentMethod(lines);
    receiptNumber = _findReceiptNumber(lines);

    // 6. Line Item Extraction
    final extractedItems = _findItems(lines);

    return ParsedReceipt(
      merchant: merchant,
      address: address,
      phone: phone,
      email: email,
      subtotal: subtotal,
      tax: tax,
      total: total,
      date: date,
      paymentMethod: paymentMethod,
      receiptNumber: receiptNumber,
      confidence: confidence.clamp(0.0, 1.0),
      lines: lines,
      items: extractedItems,
    );
  }

  static List<ReceiptItem> _findItems(List<OCRLine> lines) {
    final List<ReceiptItem> items = [];
    final totalKeywords = ['TOTAL', 'SUBTOTAL', 'TAX', 'VAT', 'GST', 'GRAND TOTAL', 'NET', 'BALANCE'];
    
    for (final line in lines) {
      final text = line.text;
      final upperLine = text.toUpperCase();
      
      // Skip lines that are likely totals, dates, or contact info
      if (totalKeywords.any((kw) => upperLine.contains(kw))) continue;
      if (text.contains('/') || text.contains('@')) continue;
      
      final amounts = _extractAllAmounts(text);
      if (amounts.isEmpty) continue;
      
      String description = text;
      final firstAmountMatch = RegExp(r'\$?\s*(\d{1,3}(?:,\d{3})*(?:\.\d{2})?)').firstMatch(text);
      if (firstAmountMatch != null) {
        description = text.substring(0, firstAmountMatch.start).trim();
      }
      
      if (description.length < 3 || !RegExp(r'[A-Za-z]').hasMatch(description)) continue;
      
      int amount = amounts.last;
      int? quantity;
      int? unitPrice;
      
      if (amounts.length >= 3) {
        unitPrice = amounts[amounts.length - 2];
        final numbers = RegExp(r'(\d+(?:\.\d+)?)').allMatches(text);
        if (numbers.length >= 3) {
          final qtyText = numbers.elementAt(numbers.length - 3).group(0);
          if (qtyText != null) {
            quantity = (double.tryParse(qtyText) ?? 1.0).round();
          }
        }
      } else if (amounts.length == 2) {
        unitPrice = amounts[0];
      }
      
      items.add(ReceiptItem(
        description: description,
        amount: amount,
        quantity: quantity,
        unitPrice: unitPrice,
      ));
    }
    
    return items;
  }

  static List<int> _extractAllAmounts(String text) {
    final regex = RegExp(r'\$?\s*(\d{1,3}(?:,\d{3})*(?:\.\d{2}))'); // Requires .xx for items
    final matches = regex.allMatches(text);
    final List<int> amounts = [];
    
    for (final match in matches) {
      try {
        final clean = match.group(1)!.replaceAll(',', '');
        amounts.add((double.parse(clean) * 100).round());
      } catch (_) {}
    }
    return amounts;
  }

  static int? _findAmountByKeywords(List<OCRLine> lines) {
    final keywords = ['GRAND TOTAL', 'TOTAL DUE', 'TOTAL', 'BALANCE DUE', 'BALANCE', 'NET DUE', 'NET', 'SUBTOTAL'];
    final List<({int amount, double score})> candidates = [];
    final maxY = lines.isEmpty ? 0.0 : lines.last.bottom;
    final maxRight = lines.fold<double>(0, (max, l) => l.right > max ? l.right : max);

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final upper = line.text.toUpperCase();
      
      int? foundAmount;
      double baseScore = 0.0;

      for (final kw in keywords) {
        if (!upper.contains(kw)) {
          continue;
        }

        if (upper.contains('DESCRIPTION') || upper.contains('QTY') || 
            upper.contains('UNIT PRICE') || upper.contains('ITEM')) {
          continue;
        }

        if (kw == 'TOTAL' && upper.contains('SUBTOTAL')) {
          continue;
        }

        baseScore += 50.0;
        if (kw == 'GRAND TOTAL') baseScore += 20.0;
        
        foundAmount = _extractAmount(line.text);
        if (foundAmount == null && i < lines.length - 1) {
          final nextLine = lines[i + 1];
          if ((nextLine.top - line.bottom).abs() < 30) {
            foundAmount = _extractAmount(nextLine.text);
            if (foundAmount != null) {
              baseScore += 10.0;
            }
          }
        }
        break;
      }

      if (foundAmount != null) {
        double score = baseScore;
        if (line.bottom > maxY * 0.75) score += 20.0;
        if (line.bottom > maxY * 0.90) score += 10.0;
        if (maxRight > 0 && line.right > maxRight * 0.7) score += 15.0;
        
        candidates.add((amount: foundAmount, score: score));
      }
    }

    if (candidates.isEmpty) return null;

    // Magnitude scoring: reward larger amounts (totals are usually large)
    final largestAmount = candidates.map((c) => c.amount).reduce((a, b) => a > b ? a : b);
    final List<({int amount, double score})> scoredCandidates = candidates.map((c) {
      double finalScore = c.score;
      if (c.amount == largestAmount) finalScore += 15.0;
      return (amount: c.amount, score: finalScore);
    }).toList();

    scoredCandidates.sort((a, b) => b.score.compareTo(a.score));
    return scoredCandidates.first.amount;
  }

  static int? _findLargestAmount(List<OCRLine> lines) {
    int? maxAmount;
    for (final line in lines) {
      final text = line.text;
      final upper = text.toUpperCase();
      
      if (upper.contains('SERVICE') || upper.contains('PRODUCT') || upper.contains('ITEM')) continue;

      final amount = _extractAmount(text);
      if (amount != null) {
        if (maxAmount == null || amount > maxAmount) {
          maxAmount = amount;
        }
      }
    }
    return maxAmount;
  }

  static String? _findMerchant(List<OCRLine> lines) {
    final List<({String text, double score})> candidates = [];
    final maxY = lines.isEmpty ? 1.0 : lines.last.bottom;

    for (int i = 0; i < lines.length && i < 15; i++) {
      final line = lines[i];
      final text = line.text;
      if (text.isEmpty || !RegExp(r'[A-Za-z]').hasMatch(text)) {
        continue;
      }

      final lower = text.toLowerCase().trim();
      if (_merchantBlocklist.any((w) => lower == w || lower.startsWith(w))) {
        continue;
      }
      if (text.contains('@') || RegExp(r'(\d[\d\-\s\(\)]{8,}\d)').hasMatch(text)) {
        continue;
      }

      double score = 0.0;
      // Position: top is much better
      if (line.top < maxY * 0.1) {
        score += 40.0;
      } else if (line.top < maxY * 0.2) {
        score += 20.0;
      }

      // Format: Title Case is common for business names
      if (RegExp(r'^[A-Z][a-z]+(\s+[A-Z][a-z]+)*$').hasMatch(text)) score += 20.0;
      
      // Slogan/Generic guard: too long or all caps short words usually slogans or headers
      if (text.length > 30) score -= 20.0;
      if (RegExp(r'^[A-Z\s]+$').hasMatch(text) && text.length <= 12) score += 10.0;

      candidates.add((text: text, score: score));
    }

    if (candidates.isEmpty) return null;
    candidates.sort((a, b) => b.score.compareTo(a.score));
    return candidates.first.text;
  }

  static String? _findAddress(List<OCRLine> lines) {
    final List<String> addressLines = [];
    for (final line in lines) {
      final text = line.text;
      // Look for ZIP codes or street patterns
      if (RegExp(r'\d{5}').hasMatch(text) || 
          RegExp(r'^\d+\s+[A-Za-z]').hasMatch(text) ||
          RegExp(r'[A-Z]{2}\s+\d{5}').hasMatch(text)) {
        addressLines.add(text);
      }
    }
    return addressLines.isEmpty ? null : addressLines.join(', ');
  }

  static Map<String, String?> _findContactInfo(List<OCRLine> lines) {
    String? phone;
    String? email;
    for (final line in lines) {
      final text = line.text;
      if (phone == null) {
        final match = RegExp(r'(\+?\d[\d\-\s\(\)]{8,}\d)').firstMatch(text);
        if (match != null) phone = match.group(1);
      }
      if (email == null) {
        final match = RegExp(r'([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})').firstMatch(text);
        if (match != null) email = match.group(1);
      }
    }
    return {'phone': phone, 'email': email};
  }

  static Map<String, int?> _findTaxAndSubtotal(List<OCRLine> lines) {
    int? tax;
    int? subtotal;
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final upper = line.text.toUpperCase();
      if (tax == null && (upper.contains('TAX') || upper.contains('VAT') || upper.contains('GST') || 
          upper.contains('HST') || upper.contains('TPS') || upper.contains('TVQ'))) {
        tax = _extractAmount(line.text);
        if (tax == null && i + 1 < lines.length) {
          tax = _extractAmount(lines[i + 1].text);
        }
      }
      if (subtotal == null && upper.contains('SUBTOTAL')) {
        subtotal = _extractAmount(line.text);
        if (subtotal == null && i + 1 < lines.length) {
          subtotal = _extractAmount(lines[i + 1].text);
        }
      }
    }
    return {'tax': tax, 'subtotal': subtotal};
  }

  static String? _findPaymentMethod(List<OCRLine> lines) {
    final keywords = ['VISA', 'MASTERCARD', 'AMEX', 'CASH', 'DEBIT', 'CREDIT CARD', 'DISCOVER'];
    for (final line in lines) {
      final text = line.text;
      final upper = text.toUpperCase();
      for (final kw in keywords) {
        if (upper.contains(kw)) {
          final suffixMatch = RegExp(r'\*{2,}\s*\d{4}').firstMatch(text);
          return suffixMatch != null ? '$kw ${suffixMatch.group(0)}' : kw;
        }
      }
    }
    return null;
  }

  static String? _findReceiptNumber(List<OCRLine> lines) {
    final keywords = ['RECEIPT #', 'INVOICE #', 'RECEIPT NO', 'INVOICE NO', 'ORDER #', 'RECEIPT', 'INVOICE'];
    for (final line in lines) {
      final text = line.text;
      final upper = text.toUpperCase();
      for (final kw in keywords) {
        if (upper.contains(kw)) {
          final numberMatch = RegExp(r'#?\s*([A-Z0-9\-]{4,})', caseSensitive: false).firstMatch(text.substring(upper.indexOf(kw) + kw.length));
          if (numberMatch != null) return numberMatch.group(1);
        }
      }
    }
    return null;
  }

  static int? _extractAmount(String text) {
    // Ignore percentages (e.g. "Tax (8.00%)")
    final textWithoutPercentages = text.replaceAll(RegExp(r'\d+(\.\d+)?%'), '');
    
    final regex = RegExp(r'\$?\s*(\d{1,3}(?:,\d{3})*(?:\.\d{2})?)');
    final matches = regex.allMatches(textWithoutPercentages);
    if (matches.isEmpty) return null;
    try {
      final raw = matches.last.group(1)!;
      final clean = raw.replaceAll(',', '');
      final value = double.parse(clean);
      // Ignore obviously-wrong values (0, or absurdly large)
      if (value <= 0 || value > 999999) return null;
      return (value * 100).round();
    } catch (_) {
      return null;
    }
  }

  static DateTime? _findDate(List<OCRLine> lines) {
    final regexes = [
      RegExp(r'(\d{4})[-/](\d{1,2})[-/](\d{1,2})'), // YYYY-MM-DD
      RegExp(r'(\d{1,2})[-/](\d{1,2})[-/](\d{2,4})'), // DD/MM/YY or MM/DD/YY
      RegExp(r'(\d{1,2})\s+([A-Za-z]{3,})\s+(\d{4})'), // DD Month YYYY
    ];

    for (final line in lines) {
      final text = line.text;
      for (final reg in regexes) {
        final match = reg.firstMatch(text);
        if (match != null) {
          try {
            final g1 = match.group(1)!;
            final g2 = match.group(2)!;
            final g3 = match.group(3)!;

            // Handle "DD Month YYYY"
            if (int.tryParse(g2) == null) {
              const months = ['jan', 'feb', 'mar', 'apr', 'may', 'jun',
                              'jul', 'aug', 'sep', 'oct', 'nov', 'dec'];
              final monthIdx = months.indexWhere((m) => g2.toLowerCase().startsWith(m));
              if (monthIdx != -1) {
                return DateTime(int.parse(g3), monthIdx + 1, int.parse(g1));
              }
            }

            final n1 = int.parse(g1);
            final n2 = int.parse(g2);
            final n3 = int.parse(g3);

            if (n1 > 1000) return DateTime(n1, n2, n3); // YYYY-MM-DD

            // Heuristic: if first number > 12, it must be the day (DD/MM)
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
