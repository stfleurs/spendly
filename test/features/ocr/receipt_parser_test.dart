import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendly/core/models/receipt.dart';
import 'package:spendly/features/ocr/services/receipt_parser.dart';

void main() {
  group('ReceiptParser Heuristics Tests', () {
    test('Clean Receipt: Should detect merchant and priority amount', () {
      final lines = [
        'Caribbean Supermarket',
        'Delmas 33, Port-au-Prince',
        'Tel: 509 123 4567',
        'Date: 2026-05-05',
        '------------------',
        'Bread      250.00',
        'Milk       1,250.00',
        '------------------',
        'SUBTOTAL:  130.00',
        'Tax (8.00%)  10.40',
        'TOTAL:     140.40',
        '------------------',
        'THANK YOU',
      ];

      final result = ReceiptParser.parseFromLines(_toLines(lines), '', []);

      expect(result.merchant, equals('Caribbean Supermarket'));
      expect(result.total, equals(14040)); // 140.40 * 100
      expect(result.tax, equals(1040));
      expect(result.date!.year, equals(2026));
      expect(result.confidence, greaterThanOrEqualTo(0.5));
    });

    test('Messy Receipt: Should handle random spacing and competing numbers', () {
      final lines = [
        '  CAFE   DES   ARTS  ', // Messy merchant name
        '509-3333-2222', // Phone number (should be filtered)
        'Order #12345', // Numbers in line (should be filtered for merchant)
        'Items: 5',
        'Latte',
        '  450.00  ',
        'Pastry',
        '  350.00  ',
        '10 May 2026', // Different date format (though regex might need update)
        'CASH: 1000.00',
        'TOTAL: 800.00', // Keyword priority
        'CHANGE: 200.00', // Competing number
      ];

      final result = ReceiptParser.parseFromLines(_toLines(lines), '', []);

      expect(result.merchant, equals('CAFE   DES   ARTS'));
      expect(result.total, equals(80000));
      expect(result.confidence, greaterThanOrEqualTo(0.5));
    });

    test('No Keywords Fallback: Should pick largest number', () {
      final lines = ['Market', '20.00', '150.00', '50.00'];

      final result = ReceiptParser.parseFromLines(_toLines(lines), '', []);

      expect(result.total, equals(15000)); // Largest
    });

    test('Date Formats: Should support various formats', () {
      final formats = {
        '2026/05/05': DateTime(2026, 5, 5),
        '05/10/2026': DateTime(2026, 5, 10), // MM/DD/YYYY default
        '25/12/2026': DateTime(2026, 12, 25), // DD/MM/YYYY auto-detected
      };

      formats.forEach((text, expected) {
        final result = ReceiptParser.parseFromLines(
          _toLines(['Receipt', text, 'TOTAL: 10.00']),
          '',
          [],
        );
        expect(result.date!.year, expected.year);
        expect(result.date!.month, expected.month);
        expect(result.date!.day, expected.day);
      });
    });

    test(
      'Compact POS receipt: extracts split-line items and ignores payment metadata',
      () {
        final lines = [
          'CAFE KREYOL',
          'ORDER # A1024',
          'Cashier: Marie',
          'Latte',
          '450.00',
          '2 x Patty',
          '300.00',
          'Subtotal 750.00',
          'Tax 75.00',
          'TOTAL DUE 825.00',
          'CASH 1000.00',
          'CHANGE 175.00',
          'AUTH 123456',
        ];

        final result = ReceiptParser.parseFromLines(_toLines(lines), '', []);

        expect(result.total, equals(82500));
        expect(result.subtotal, equals(75000));
        expect(result.tax, equals(7500));
        expect(
          result.items.map((i) => i.description),
          containsAll(['Latte', 'Patty']),
        );
        expect(
          result.items.firstWhere((i) => i.description == 'Patty').quantity,
          equals(2),
        );
      },
    );

    test(
      'Long grocery receipt: extracts item rows and sums multiple tax lines',
      () {
        final lines = [
          'Fresh Mart',
          '123 Market Street',
          '2026-05-10 14:33',
          'ITEM DESCRIPTION QTY PRICE',
          'SKU 8821 BANANAS 2.50',
          'RICE 10LB 12.99',
          '3x WATER BOTTLE 4.50',
          'SOAP BAR 1.25',
          'SUB TOTAL 21.24',
          'GST 5.00% 1.06',
          'PST 7.00% 1.49',
          'AMOUNT DUE 23.79',
          'VISA **** 4242',
        ];

        final result = ReceiptParser.parseFromLines(_toLines(lines), '', []);

        expect(result.total, equals(2379));
        expect(result.subtotal, equals(2124));
        expect(result.tax, equals(255));
        expect(
          result.items.map((i) => i.description),
          containsAll(['BANANAS', 'RICE 10LB', 'WATER BOTTLE', 'SOAP BAR']),
        );
        expect(
          result.items
              .firstWhere((i) => i.description == 'WATER BOTTLE')
              .quantity,
          equals(3),
        );
      },
    );

    test('Invoice receipt: keeps dates out of line items', () {
      final lines = [
        'RECEIPT',
        'Your Business Name',
        '123 Main Street, Suite 100',
        'Receipt #: 001234',
        'Date: Nov 24, 2025',
        'Payment Date: Nov 24, 2025',
        'Customer: Valued Customer',
        'DESCRIPTION QTY UNIT PRICE AMOUNT',
        'Service / Product A 1 \$50.00 \$50.00',
        'Service / Product B 2 \$25.00 \$50.00',
        'Service / Product C 1 \$30.00 \$30.00',
        'Subtotal \$130.00',
        'Tax (8.00%) \$10.40',
        'TOTAL \$140.40',
      ];

      final result = ReceiptParser.parseFromLines(_toLines(lines), '', []);

      expect(result.date, equals(DateTime(2025, 11, 24)));
      expect(result.total, equals(14040));
      expect(result.subtotal, equals(13000));
      expect(result.tax, equals(1040));
      expect(
        result.items.map((i) => i.description),
        equals([
          'Service / Product A',
          'Service / Product B',
          'Service / Product C',
        ]),
      );
      expect(result.items.map((i) => i.amount), equals([5000, 5000, 3000]));
      expect(result.items.map((i) => i.quantity), equals([1, 2, 1]));
    });
  });
}

List<OCRLine> _toLines(List<String> texts) {
  return texts.asMap().entries.map((e) {
    final i = e.key;
    final text = e.value;
    return OCRLine(
      text: text.trim(),
      bounds: Rect.fromLTWH(0, i * 20.0, 400, 20),
    );
  }).toList();
}
