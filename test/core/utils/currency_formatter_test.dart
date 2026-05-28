import 'package:flutter_test/flutter_test.dart';
import 'package:spendly/core/utils/currency_formatter.dart';

void main() {
  group('formatCents - Standard', () {
    test('formats USD with grouping separators', () {
      expect(formatCents(150000, 'USD', locale: 'en'), r'$1,500.00');
    });

    test('formats small USD without grouping', () {
      expect(formatCents(5000, 'USD', locale: 'en'), r'$50.00');
    });

    test('formats negative USD', () {
      expect(formatCents(-150000, 'USD', locale: 'en'), r'-$1,500.00');
    });

    test('shows + sign for positive when showSign=true', () {
      expect(formatCents(150000, 'USD', showSign: true, locale: 'en'), r'+$1,500.00');
    });

    test('formats HTG with suffix', () {
      expect(formatCents(50000, 'HTG', locale: 'en'), '500.00 G');
    });

    test('formats negative HTG', () {
      expect(formatCents(-50000, 'HTG', locale: 'en'), '-500.00 G');
    });

    test('formats EUR with euro symbol', () {
      expect(formatCents(200000, 'EUR', locale: 'en'), '€2,000.00');
    });

    test('formats CAD with dollar symbol', () {
      expect(formatCents(150000, 'CAD', locale: 'en'), r'$1,500.00');
    });

    test('formats zero', () {
      expect(formatCents(0, 'USD', locale: 'en'), r'$0.00');
    });

    test('decimal override', () {
      expect(formatCents(150000, 'USD', decimalDigits: 0, locale: 'en'), r'$1,500');
    });
  });

  group('formatCents - Compact', () {
    test('uses compact for values over 1M', () {
      final result = formatCents(100000000, 'USD', locale: 'en');
      expect(result, r'$1.0M');
    });

    test('does not compact below threshold', () {
      expect(formatCents(99999999, 'USD', locale: 'en'), r'$999,999.99');
    });

    test('compact with negative', () {
      final result = formatCents(-200000000, 'USD', locale: 'en');
      expect(result, r'-$2.0M');
    });

    test('compact HTG', () {
      final result = formatCents(100000000, 'HTG', locale: 'en');
      expect(result, contains('M'));
      expect(result, contains('G'));
    });
  });

  group('formatCents - Locale awareness', () {
    test('French locale with decimals', () {
      // French uses non-breaking space as grouping separator and comma as decimal
      final result = formatCents(150000, 'USD', locale: 'fr');
      expect(result, contains(','));
      expect(result, contains(r'$'));
    });
  });

  group('formatCents - Edge cases', () {
    test('large negative with showSign', () {
      final result = formatCents(-100, 'USD', showSign: true, locale: 'en');
      expect(result, r'-$1.00');
    });

    test('single cent', () {
      expect(formatCents(1, 'USD', locale: 'en'), r'$0.01');
    });

    test('unknown currency falls back to \$', () {
      expect(formatCents(10000, 'GBP', locale: 'en'), r'$100.00');
    });
  });
}
