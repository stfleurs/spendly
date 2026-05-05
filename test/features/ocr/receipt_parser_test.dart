import 'package:flutter_test/flutter_test.dart';
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
        'SUBTOTAL:  1,500.00',
        'TAX:       150.00',
        'TOTAL:     1,650.00',
        '------------------',
        'THANK YOU',
      ];

      final result = ReceiptParser.parseFromLines(lines);

      expect(result.merchant, equals('Caribbean Supermarket'));
      expect(result.total, equals(165000)); // 1,650.00 * 100
      expect(result.date!.year, equals(2026));
      expect(result.confidence, greaterThanOrEqualTo(0.5));
    });

    test('Messy Receipt: Should handle random spacing and competing numbers', () {
      final lines = [
        '  CAFE   DES   ARTS  ', // Messy merchant name
        '509-3333-2222',         // Phone number (should be filtered)
        'Order #12345',         // Numbers in line (should be filtered for merchant)
        'Items: 5',
        'Latte',
        '  450.00  ',
        'Pastry',
        '  350.00  ',
        '10 May 2026',          // Different date format (though regex might need update)
        'CASH: 1000.00',
        'TOTAL: 800.00',        // Keyword priority
        'CHANGE: 200.00',       // Competing number
      ];

      final result = ReceiptParser.parseFromLines(lines);

      expect(result.merchant, equals('CAFE   DES   ARTS'));
      expect(result.total, equals(80000));
      expect(result.confidence, greaterThanOrEqualTo(0.5));
    });

    test('No Keywords Fallback: Should pick largest number', () {
      final lines = [
        'Market',
        '20.00',
        '150.00',
        '50.00',
      ];

      final result = ReceiptParser.parseFromLines(lines);

      expect(result.total, equals(15000)); // Largest
    });

    test('Date Formats: Should support various formats', () {
      final formats = {
        '2026/05/05': DateTime(2026, 5, 5),
        '05/10/2026': DateTime(2026, 5, 10), // MM/DD/YYYY default
        '25/12/2026': DateTime(2026, 12, 25), // DD/MM/YYYY auto-detected
      };

      formats.forEach((text, expected) {
        final result = ReceiptParser.parseFromLines(['Receipt', text, 'TOTAL: 10.00']);
        expect(result.date!.year, expected.year);
        expect(result.date!.month, expected.month);
        expect(result.date!.day, expected.day);
      });
    });
  });
}
