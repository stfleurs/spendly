import 'dart:ui';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:spendly/core/models/receipt.dart';
import 'package:spendly/core/services/search_indexer.dart';

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
  final String extractedText;
  final List<String> extractedTokens;
  final String archetype;
  final Map<String, double> fieldConfidences;

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
    required this.extractedText,
    required this.extractedTokens,
    required this.archetype,
    required this.fieldConfidences,
  });
}

class ReceiptParser {
  // Generic words that appear on receipts but are NOT merchant names
  static const _merchantBlocklist = {
    'receipt',
    'invoice',
    'statement',
    'bill',
    'order',
    'tax invoice',
    'sales receipt',
    'purchase receipt',
    'receipt #',
    'receipt no',
    'thank you',
    'welcome',
    'customer',
    'guest',
  };

  static ParsedReceipt parse(RecognizedText recognizedText) {
    final List<OCRLine> lines = [];
    final StringBuffer fullTextBuffer = StringBuffer();

    for (final block in recognizedText.blocks) {
      fullTextBuffer.writeln(block.text);
      for (final line in block.lines) {
        lines.add(OCRLine(text: line.text.trim(), bounds: line.boundingBox));
      }
    }

    lines.sort((a, b) {
      if ((a.top - b.top).abs() < 10) return a.left.compareTo(b.left);
      return a.top.compareTo(b.top);
    });

    // Spatial Merging: Group lines that are vertically at the same level
    final List<OCRLine> mergedLines = [];
    if (lines.isNotEmpty) {
      OCRLine current = lines.first;
      for (int i = 1; i < lines.length; i++) {
        final next = lines[i];
        // If Y-centers are very close (within half the height of the current line), merge them
        final verticalGap = (current.centerY - next.centerY).abs();
        final heightThreshold = current.bounds.height * 0.7; // 70% of line height
        
        if (verticalGap < heightThreshold) {
          // Merge horizontal text
          current = current.copyWith(
            text: '${current.text}    ${next.text}', // Large gap to distinguish columns
            bounds: Rect.fromLTRB(
              current.left < next.left ? current.left : next.left,
              current.top < next.top ? current.top : next.top,
              current.right > next.right ? current.right : next.right,
              current.bottom > next.bottom ? current.bottom : next.bottom,
            ),
          );
        } else {
          mergedLines.add(current);
          current = next;
        }
      }
      mergedLines.add(current);
    }

    final indexed = SearchIndexer.index(fullTextBuffer.toString());

    return parseFromLines(mergedLines, indexed.content, indexed.tokens);
  }

  static ParsedReceipt parseFromLines(
    List<OCRLine> lines,
    String extractedText,
    List<String> extractedTokens,
  ) {
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

    if (merchant != null) {
      final merchantIdx = lines.indexWhere((l) => l.text == merchant);
      if (merchantIdx != -1) {
        address = _findAddress(
          lines.sublist(
            merchantIdx + 1,
            (merchantIdx + 6).clamp(0, lines.length),
          ),
        );
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
    double dateConf = date != null ? 0.9 : 0.0;
    date ??= DateTime.now();

    // 5. Additional Metadata
    paymentMethod = _findPaymentMethod(lines);
    receiptNumber = _findReceiptNumber(lines);

    // 6. Archetype Detection
    final archetype = _detectArchetype(lines, extractedText);

    // 7. Line Item Extraction
    final extractedItems = _findItems(
      lines,
      merchant: merchant,
      address: address,
      phone: phone,
      email: email,
      paymentMethod: paymentMethod,
      receiptNumber: receiptNumber,
    );
    double itemsConf = extractedItems.isNotEmpty ? 0.8 : 0.3;

    final fieldConfidences = {
      'merchant': merchant != null ? 0.9 : 0.0,
      'date': dateConf,
      'total': total != null ? 0.85 : 0.0,
      'items': itemsConf,
    };

    // Overall confidence is a weighted average
    confidence = (fieldConfidences.values.reduce((a, b) => a + b) / fieldConfidences.length);

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
      extractedText: extractedText,
      extractedTokens: extractedTokens,
      archetype: archetype,
      fieldConfidences: fieldConfidences,
    );
  }

  static String _detectArchetype(List<OCRLine> lines, String text) {
    final upper = text.toUpperCase();
    if (upper.contains('GRATUITY') || upper.contains('TIP') || upper.contains('GUEST CHECK')) {
      return 'restaurant';
    }
    if (upper.contains('INVOICE') || upper.contains('BILL TO') || upper.contains('SHIP TO')) {
      return 'invoice';
    }
    if (upper.contains('PUMP #') || upper.contains('UNLEADED') || upper.contains('GALLONS')) {
      return 'gas';
    }
    // Thermal receipts are usually narrow
    final maxWidth = lines.fold<double>(0, (max, l) => l.bounds.width > max ? l.bounds.width : max);
    if (maxWidth < 500 && lines.length > 20) {
      return 'thermal';
    }
    return 'general';
  }

  static List<ReceiptItem> _findItems(
    List<OCRLine> lines, {
    String? merchant,
    String? address,
    String? phone,
    String? email,
    String? paymentMethod,
    String? receiptNumber,
  }) {
    final List<ReceiptItem> items = [];
    final summaryKeywords = [
      'TOTAL',
      'SUBTOTAL',
      'SUB TOTAL',
      'TAX',
      'VAT',
      'GST',
      'HST',
      'PST',
      'QST',
      'TPS',
      'TVQ',
      'GRAND TOTAL',
      'NET',
      'BALANCE',
      'CHANGE',
      'AMOUNT DUE',
      'TENDER',
      'PAID',
      'CASH',
      'CARD',
    ];
    final metadataKeywords = [
      'CASHIER',
      'THANK YOU',
      'WELCOME',
      'MERCHANT',
      'TERMINAL',
      'AUTH',
      'APPROVAL',
      'AID',
      'TVR',
      'IAD',
      'TSI',
      'ARC',
      'CVM',
      'ENTRY',
      'ACCOUNT',
      'REF',
      'TRACE',
      'ORDER',
      'INVOICE',
      'RECEIPT',
      'DUPLICATE',
      'CUSTOMER COPY',
      'STORE COPY',
      'SERVED BY',
    ];
    final tableHeaderKeywords = [
      'DESCRIPTION',
      'QTY',
      'QUANTITY',
      'UNIT PRICE',
      'AMOUNT',
      'PRICE',
      'EXT PRICE',
      'PRODUCT',
      'ITEM',
    ];

    // Create a set of words to skip from metadata
    final skipSet = <String>{};
    if (merchant != null) {
      skipSet.addAll(merchant.toUpperCase().split(RegExp(r'\s+')));
    }
    if (address != null) {
      skipSet.addAll(address.toUpperCase().split(RegExp(r'[\s,.]+')));
    }
    if (paymentMethod != null) {
      skipSet.addAll(paymentMethod.toUpperCase().split(RegExp(r'\s+')));
    }
    if (receiptNumber != null) {
      skipSet.add(receiptNumber.toUpperCase());
    }

    skipSet.addAll([
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ]);

    String? pendingDescription;
    int skippedSummaryLines = 0;
    bool inItemTable = false;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final text = _normalizeOcrText(line.text);
      final upperLine = text.toUpperCase();

      if (text.length < 2) continue;

      // 1. Detect Table Header
      final headerMatches =
          tableHeaderKeywords.where((kw) => upperLine.contains(kw)).length;
      if (headerMatches >= 2 && !inItemTable) {
        inItemTable = true;
        continue; // Skip the header line itself
      }

      final isSummaryLine = summaryKeywords.any((kw) => upperLine.contains(kw));
      if (isSummaryLine) {
        if (inItemTable) inItemTable = false; // Exit table mode when hitting totals
        skippedSummaryLines++;
        if (items.isNotEmpty || skippedSummaryLines > 2) break;
        pendingDescription = null;
        continue;
      }

      if (metadataKeywords.any((kw) => upperLine.contains(kw))) {
        pendingDescription = null;
        continue;
      }

      if (text.contains('@') ||
          upperLine.contains('WWW.') ||
          upperLine.contains('.COM')) {
        continue;
      }
      if (phone != null && text.contains(phone)) {
        continue;
      }
      if (_looksLikeDateOrTime(text) || _looksLikeContactOrAddressOnly(text)) {
        continue;
      }

      final words = upperLine
          .split(RegExp(r'[\s,.]+'))
          .where((w) => w.length > 2)
          .toList();
      if (words.isNotEmpty) {
        final skipCount = words.where((w) => skipSet.contains(w)).length;
        if (skipCount / words.length > 0.8) {
          continue;
        }
      }

      if (_looksLikeItemDescription(text) && i + 1 < lines.length) {
        final nextText = _normalizeOcrText(lines[i + 1].text);
        final nextAmounts = _extractLineItemAmountsWithMeta(nextText);
        final nextHasDescription = RegExp(r'[A-Za-z]').hasMatch(nextText);
        if (nextAmounts.isNotEmpty && !nextHasDescription) {
          final quantity = _extractQuantity(text);
          final amount = nextAmounts.last.cents;
          items.add(
            ReceiptItem(
              description: _cleanItemDescription(text),
              amount: amount,
              quantity: quantity,
              unitPrice: quantity != null && quantity > 1
                  ? (amount / quantity).round()
                  : null,
            ),
          );
          pendingDescription = null;
          i++;
          continue;
        }
      }

      final amounts = _extractLineItemAmountsWithMeta(text);
      if (amounts.isEmpty) {
        if (_looksLikeItemDescription(text)) {
          pendingDescription = _cleanItemDescription(text);
        }
        continue;
      }

      final amountMatch = _lastAmountMatch(text);
      String description = amountMatch == null
          ? ''
          : text.substring(0, amountMatch.start).trim();

      if ((description.isEmpty || !RegExp(r'[A-Za-z]').hasMatch(description)) &&
          pendingDescription != null) {
        description = pendingDescription;
      }

      description = _stripTrailingItemColumns(
        _cleanItemDescription(description),
      );
      if (description.length < 2 ||
          !RegExp(r'[A-Za-z]').hasMatch(description)) {
        pendingDescription = null;
        continue;
      }

      int amount = amounts.last.cents;
      int? quantity;
      int? unitPrice;

      if (amounts.length >= 2) {
        final decimalAmounts = amounts.where((a) => a.hasDecimals).toList();
        final firstDecimalIdx = amounts.indexWhere((a) => a.hasDecimals);

        if (decimalAmounts.isNotEmpty) {
          // Rule 1: The last decimal is almost always the line total
          amount = decimalAmounts.last.cents;

          // Rule 2: The second-to-last decimal is likely the unit price
          if (decimalAmounts.length >= 2) {
            unitPrice = decimalAmounts[decimalAmounts.length - 2].cents;
          }

          // Rule 3: Any number before the first decimal is likely a quantity
          if (firstDecimalIdx > 0) {
            final qVal = amounts[firstDecimalIdx - 1];
            if (!qVal.hasDecimals && qVal.cents < 100000) {
              quantity = qVal.cents ~/ 100;
            }
          }
        } else {
          // No decimals? Use old logic as fallback
          final last = amounts.last;
          final secondLast = amounts[amounts.length - 2];
          if (secondLast.cents < 10000) {
            quantity = secondLast.cents ~/ 100;
            amount = last.cents;
          }
        }

        // Validate Quantity via calculation if we have unit price but no quantity
        if (quantity == null && unitPrice != null && unitPrice > 0) {
          final double qtyCalc = amount / unitPrice;
          if ((qtyCalc - qtyCalc.round()).abs() < 0.01 && qtyCalc < 100) {
            quantity = qtyCalc.round();
          }
        }
      }

      // Check for 'x' or '@' pattern if still missing quantity
      quantity ??= _extractQuantity(text);

      if (quantity != null && unitPrice == null && quantity > 1 && amount > 0) {
        unitPrice = (amount / quantity).round();
      }

      // 8. Confidence Scoring for the row
      double rowConfidence = 0.5; // Base confidence
      if (amount > 0) rowConfidence += 0.2;
      if (quantity != null && quantity > 0) rowConfidence += 0.1;
      if (unitPrice != null && unitPrice > 0) {
        // Mathematical consistency check
        if ((quantity! * unitPrice - amount).abs() < (amount * 0.05).round() + 5) {
          rowConfidence += 0.2;
        }
      }
      if (description.length > 5) rowConfidence += 0.1;

      items.add(
        ReceiptItem(
          description: description,
          amount: amount,
          quantity: quantity,
          unitPrice: unitPrice,
          confidence: rowConfidence.clamp(0.0, 1.0),
        ),
      );
      pendingDescription = null;
    }

    return items;
  }

  static List<({int cents, bool hasDecimals})> _extractLineItemAmountsWithMeta(String text) {
    if (RegExp(r'^\s*\d+\s*[xX]\s+[A-Za-z]').hasMatch(text) &&
        !RegExp(r'\d+[.,]\d{2}').hasMatch(text)) {
      return [];
    }

    final regex = RegExp(
      r'(?<![\d/])(?:[$€£G]|HTG|USD|CAD|EUR|DOP)?\s*(\d{1,6}(?:[ ,]\d{3})*(?:[.,]\d{2})|\d{1,4})(?![\d/%])',
      caseSensitive: false,
    );
    final matches = regex.allMatches(text);
    final List<({int cents, bool hasDecimals})> amounts = [];

    for (final match in matches) {
      try {
        final token = match.group(1)!;
        final afterMatch = text.substring(match.end).trimLeft();
        
        if (!token.contains('.') &&
            !token.contains(',') &&
            (afterMatch.toUpperCase().startsWith('X ') ||
                afterMatch.startsWith('@'))) {
          continue;
        }
        
        final value = _parseAmountValue(token);
        if (value <= 0 || value > 999999) {
          continue;
        }
        
        final hasDecimals = token.contains('.') || token.contains(',');
        
        if (!hasDecimals && value > 9999) {
          continue;
        }
        
        amounts.add((cents: (value * 100).round(), hasDecimals: hasDecimals));
      } catch (_) {}
    }
    return amounts;
  }

  static int? _findAmountByKeywords(List<OCRLine> lines) {
    final keywords = [
      'GRAND TOTAL',
      'TOTAL DUE',
      'AMOUNT DUE',
      'TOTAL',
      'BALANCE DUE',
      'BALANCE',
      'NET DUE',
      'NET',
    ];
    final weakKeywords = ['SUBTOTAL', 'SUB TOTAL'];
    final negativeContext = [
      'CHANGE',
      'CASH',
      'TENDER',
      'PAID',
      'RECEIVED',
      'CARD',
      'AUTH',
      'APPROVAL',
    ];
    final List<({int amount, double score})> candidates = [];
    final maxY = lines.isEmpty ? 0.0 : lines.last.bottom;
    final maxRight = lines.fold<double>(
      0,
      (max, l) => l.right > max ? l.right : max,
    );

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final upper = line.text.toUpperCase();

      int? foundAmount;
      double baseScore = 0.0;

      for (final kw in keywords) {
        if (!upper.contains(kw)) {
          continue;
        }
        if (upper.contains('DESCRIPTION') ||
            upper.contains('QTY') ||
            upper.contains('UNIT PRICE') ||
            upper.contains('ITEM')) {
          continue;
        }
        if (kw == 'TOTAL' &&
            (upper.contains('SUBTOTAL') || upper.contains('SUB TOTAL'))) {
          continue;
        }
        if (negativeContext.any((bad) => upper.contains(bad)) &&
            !upper.contains('DUE')) {
          continue;
        }

        baseScore += 50.0;
        if (kw == 'GRAND TOTAL') baseScore += 20.0;
        if (kw == 'AMOUNT DUE' || kw == 'TOTAL DUE') baseScore += 15.0;

        foundAmount = _extractAmount(line.text);
        if (foundAmount == null && i < lines.length - 1) {
          final nextLine = lines[i + 1];
          if ((nextLine.top - line.bottom).abs() < 30) {
            foundAmount = _extractAmount(nextLine.text);
            if (foundAmount != null) baseScore += 10.0;
          }
        }
        break;
      }

      if (foundAmount == null) {
        for (final kw in weakKeywords) {
          if (!upper.contains(kw)) continue;
          foundAmount = _extractAmount(line.text);
          if (foundAmount != null) baseScore += 15.0;
          break;
        }
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
    final largestAmount = candidates
        .map((c) => c.amount)
        .reduce((a, b) => a > b ? a : b);
    final List<({int amount, double score})> scoredCandidates = candidates.map((
      c,
    ) {
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
      if (upper.contains('SERVICE') ||
          upper.contains('PRODUCT') ||
          upper.contains('ITEM')) {
        continue;
      }
      if (upper.contains('CHANGE') ||
          upper.contains('CASH') ||
          upper.contains('TENDER')) {
        continue;
      }
      final amount = _extractAmount(text);
      if (amount != null) {
        if (maxAmount == null || amount > maxAmount) maxAmount = amount;
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
      if (text.contains('@') ||
          RegExp(r'(\d[\d\-\s\(\)]{8,}\d)').hasMatch(text)) {
        continue;
      }

      double score = 0.0;
      if (line.top < maxY * 0.1) {
        score += 40.0;
      } else if (line.top < maxY * 0.2) {
        score += 20.0;
      }
      if (RegExp(r'^[A-Z][a-z]+(\s+[A-Z][a-z]+)*$').hasMatch(text)) {
        score += 20.0;
      }
      if (text.length > 30) {
        score -= 20.0;
      }
      if (RegExp(r'^[A-Z\s]+$').hasMatch(text) && text.length <= 12) {
        score += 10.0;
      }

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
      if (RegExp(r'^\s*\d+\s*[xX]\s+[A-Za-z]').hasMatch(text)) {
        continue;
      }
      if (RegExp(r'^\d{4,}$').hasMatch(text)) {
        continue;
      }
      if (text.toUpperCase().contains('RECEIPT') ||
          text.toUpperCase().contains('INVOICE')) {
        continue;
      }
      if (RegExp(r'\d{5}').hasMatch(text) ||
          RegExp(
            r'^\d+\s+[A-Za-z].*\b(ST|STREET|AVE|AVENUE|RD|ROAD|BLVD|DR|DRIVE|LANE|LN|RUE|DELMAS)\b',
            caseSensitive: false,
          ).hasMatch(text) ||
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
        if (match != null) {
          phone = match.group(1);
        }
      }
      if (email == null) {
        final match = RegExp(
          r'([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})',
        ).firstMatch(text);
        if (match != null) {
          email = match.group(1);
        }
      }
    }
    return {'phone': phone, 'email': email};
  }

  static Map<String, int?> _findTaxAndSubtotal(List<OCRLine> lines) {
    final taxCandidates = <int>[];
    int? subtotal;
    final taxKeywords = [
      'SALES TAX',
      'LOCAL TAX',
      'STATE TAX',
      'TAX',
      'VAT',
      'GST',
      'HST',
      'PST',
      'QST',
      'TPS',
      'TVQ',
    ];
    final taxExclusions = [
      'TAX ID',
      'TAX NO',
      'TAX #',
      'TAXABLE',
      'EXEMPT',
      'INCLUDED',
    ];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final upper = line.text.toUpperCase();

      if (taxKeywords.any((kw) => upper.contains(kw)) &&
          !taxExclusions.any((bad) => upper.contains(bad))) {
        int? tax = _extractAmount(line.text);
        if (tax == null &&
            i + 1 < lines.length &&
            (lines[i + 1].top - line.bottom).abs() < 35) {
          tax = _extractAmount(lines[i + 1].text);
        }
        if (tax != null && tax > 0 && !taxCandidates.contains(tax)) {
          taxCandidates.add(tax);
        }
      }

      if (subtotal == null &&
          (upper.contains('SUBTOTAL') || upper.contains('SUB TOTAL'))) {
        subtotal = _extractAmount(line.text);
        if (subtotal == null &&
            i + 1 < lines.length &&
            (lines[i + 1].top - line.bottom).abs() < 35) {
          subtotal = _extractAmount(lines[i + 1].text);
        }
      }
    }

    final tax = taxCandidates.isEmpty
        ? null
        : taxCandidates.fold<int>(0, (sum, amount) => sum + amount);
    return {'tax': tax, 'subtotal': subtotal};
  }

  static String? _findPaymentMethod(List<OCRLine> lines) {
    final keywords = [
      'VISA',
      'MASTERCARD',
      'AMEX',
      'CASH',
      'DEBIT',
      'CREDIT CARD',
      'DISCOVER',
    ];
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
    final keywords = [
      'RECEIPT #',
      'INVOICE #',
      'RECEIPT NO',
      'INVOICE NO',
      'ORDER #',
      'RECEIPT',
      'INVOICE',
    ];
    for (final line in lines) {
      final text = line.text;
      final upper = text.toUpperCase();
      for (final kw in keywords) {
        if (upper.contains(kw)) {
          final numberMatch = RegExp(
            r'#?\s*([A-Z0-9\-]{4,})',
            caseSensitive: false,
          ).firstMatch(text.substring(upper.indexOf(kw) + kw.length));
          if (numberMatch != null) return numberMatch.group(1);
        }
      }
    }
    return null;
  }

  static int? _extractAmount(String text) {
    // Remove percentages like (8.00%) or 8%
    final cleaned = _normalizeOcrText(
      text,
    ).replaceAll(RegExp(r'\d+([.,]\d+)?\s*%'), '');

    final regex = RegExp(
      r'(?:[$€£G]|HTG|USD|CAD|EUR|DOP)?\s*(\d{1,6}(?:[ ,]\d{3})*(?:[.,]\d{2}))(?!\s*%)',
      caseSensitive: false,
    );
    final matches = regex.allMatches(cleaned);
    if (matches.isEmpty) return null;
    try {
      final raw = matches.last.group(1)!;
      final value = _parseAmountValue(raw);
      if (value <= 0 || value > 999999) return null;
      return (value * 100).round();
    } catch (_) {
      return null;
    }
  }

  static double _parseAmountValue(String raw) {
    var clean = raw.trim().replaceAll(' ', '');
    final hasComma = clean.contains(',');
    final hasDot = clean.contains('.');

    if (hasComma && hasDot) {
      final lastComma = clean.lastIndexOf(',');
      final lastDot = clean.lastIndexOf('.');
      if (lastComma > lastDot) {
        clean = clean.replaceAll('.', '').replaceAll(',', '.');
      } else {
        clean = clean.replaceAll(',', '');
      }
    } else if (hasComma) {
      final comma = clean.lastIndexOf(',');
      final decimals = clean.length - comma - 1;
      clean = decimals == 2
          ? clean.replaceAll(',', '.')
          : clean.replaceAll(',', '');
    }

    return double.parse(clean);
  }

  static RegExpMatch? _lastAmountMatch(String text) {
    final regex = RegExp(
      r'(?:[$€£G]|HTG|USD|CAD|EUR|DOP)?\s*(\d{1,6}(?:[ ,]\d{3})*(?:[.,]\d{2})|\d{1,4})(?![\d/%])',
      caseSensitive: false,
    );
    final matches = regex.allMatches(text).toList();
    return matches.isEmpty ? null : matches.last;
  }

  static String _normalizeOcrText(String text) {
    return text
        .replaceAll('€', 'EUR')
        .replaceAll('£', 'GBP')
        .replaceAll(RegExp(r'[|]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static String _cleanItemDescription(String description) {
    return description
        .replaceAll(RegExp(r'^\s*\d+\s*[-.)]\s*'), '')
        .replaceAll(RegExp(r'^\s*\d+\s*[xX@]\s*'), '')
        .replaceAll(RegExp(r'\s+[xX@]\s*\d+(?:[.,]\d{2})?\s*$'), '')
        .replaceAll(
          RegExp(
            r'\b(SKU|UPC|ITEM)\s*[:#]?\s*[A-Z0-9-]+\b',
            caseSensitive: false,
          ),
          '',
        )
        .replaceAll(RegExp(r'[\$€£,:\s]+$'), '')
        .trim();
  }

  static String _stripTrailingItemColumns(String description) {
    return description
        .replaceAll(
          RegExp(
            r'\s+(?:[$€£G]|HTG|USD|CAD|EUR|DOP)?\s*\d{1,6}(?:[ ,]\d{3})*(?:[.,]\d{2})\s*$',
            caseSensitive: false,
          ),
          '',
        )
        .replaceAll(RegExp(r'\s+\d{1,3}\s*$'), '')
        .trim();
  }

  static int? _extractQuantity(String text) {
    final patterns = [
      RegExp(r'^\s*(\d+)\s*[xX]\b'),
      RegExp(r'\bQTY\s*[:xX]?\s*(\d+)\b', caseSensitive: false),
      RegExp(r'\b(\d+)\s*@\s*\d', caseSensitive: false),
    ];
    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) return int.tryParse(match.group(1)!);
    }
    return null;
  }

  static bool _looksLikeItemDescription(String text) {
    final upper = text.toUpperCase();
    if (!RegExp(r'[A-Za-z]').hasMatch(text)) {
      return false;
    }
    if (text.length < 3 || text.length > 80) {
      return false;
    }
    if (_looksLikeDateOrTime(text) || _looksLikeContactOrAddressOnly(text)) {
      return false;
    }
    if (upper.contains('THANK') ||
        upper.contains('WELCOME') ||
        upper.contains('CASHIER')) {
      return false;
    }
    if (upper.contains('TOTAL') ||
        upper.contains('TAX') ||
        upper.contains('BALANCE')) {
      return false;
    }
    return true;
  }

  static bool _looksLikeDateOrTime(String text) {
    return RegExp(r'\b\d{1,2}[/-]\d{1,2}([/-]\d{2,4})?\b').hasMatch(text) ||
        RegExp(r'\b\d{4}-\d{1,2}-\d{1,2}\b').hasMatch(text) ||
        RegExp(
          r'\b(?:jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)[a-z]*\.?\s+\d{1,2},?\s*(?:\d{4})?\b',
          caseSensitive: false,
        ).hasMatch(text) ||
        RegExp(
          r'\b\d{1,2}\s+(?:jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)[a-z]*\.?\s+\d{4}\b',
          caseSensitive: false,
        ).hasMatch(text) ||
        RegExp(
          r'\b\d{1,2}:\d{2}\s*(AM|PM)?\b',
          caseSensitive: false,
        ).hasMatch(text);
  }

  static bool _looksLikeContactOrAddressOnly(String text) {
    final upper = text.toUpperCase();
    if (RegExp(r'^\+?\d[\d\-\s().]{8,}\d$').hasMatch(text)) {
      return true;
    }
    if (RegExp(
      r'^\d+\s+[A-Za-z].*(ST|STREET|AVE|AVENUE|RD|ROAD|BLVD|DELMAS|RUE)\b',
      caseSensitive: false,
    ).hasMatch(text)) {
      return true;
    }
    if (upper.contains('TEL:') || upper.contains('PHONE:')) {
      return true;
    }
    return false;
  }

  static DateTime? _findDate(List<OCRLine> lines) {
    final regexes = [
      RegExp(r'(\d{4})[-/](\d{1,2})[-/](\d{1,2})'),
      RegExp(r'(\d{1,2})[-/](\d{1,2})[-/](\d{2,4})'),
      RegExp(r'(\d{1,2})\s+([A-Za-z]{3,})\s+(\d{4})'),
      RegExp(r'([A-Za-z]{3,})\.?\s+(\d{1,2}),?\s+(\d{4})'),
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
            if (int.tryParse(g1) == null) {
              final month = _monthNumber(g1);
              if (month != null) {
                return DateTime(int.parse(g3), month, int.parse(g2));
              }
            }
            if (int.tryParse(g2) == null) {
              final month = _monthNumber(g2);
              if (month != null) {
                return DateTime(int.parse(g3), month, int.parse(g1));
              }
            }
            final n1 = int.parse(g1);
            final n2 = int.parse(g2);
            final n3 = int.parse(g3);
            if (n1 > 1000) {
              return DateTime(n1, n2, n3);
            }
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

  static int? _monthNumber(String value) {
    const months = [
      'jan',
      'feb',
      'mar',
      'apr',
      'may',
      'jun',
      'jul',
      'aug',
      'sep',
      'oct',
      'nov',
      'dec',
    ];
    final monthIdx = months.indexWhere(
      (m) => value.toLowerCase().startsWith(m),
    );
    return monthIdx == -1 ? null : monthIdx + 1;
  }
}
