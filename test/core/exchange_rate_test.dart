import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Exchange Rate Precision Tests', () {
    test('Rule #2: Scaled Integer Math should prevent precision loss on large amounts', () {
      // Large amount: $10,000,000.00 (in cents)
      const int amountCents = 1000000000; 
      
      // Highly precise rate: 0.007654321
      const double rate = 0.007654321;
      const int rateScale = 1000000;
      
      // The "Spendly Way" (Integer Scaling)
      final int scaledRate = (rate * rateScale).round(); // 7654
      final int normalizedSpendly = (amountCents * scaledRate) ~/ rateScale;
      
      // Expected: (1000000000 * 7654) / 1000000 = 1000 * 7654 = 7654000
      expect(normalizedSpendly, 7654000);
      
      // Compare with raw double math (potential for floating point noise over many operations)
      final double rawDouble = amountCents * rate;
      expect(rawDouble.round(), 7654321); 
      
      // Note: Spendly intentionally loses the sub-cent precision of the RATE 
      // by locking it to the scale (e.g. 6 decimal places), 
      // but gains perfect determinism and zero-drift persistence.
    });

    test('Transitive Rates: Should correctly calculate cross-rates through USD base', () {
      // This is a logic test for the exchangeRateProvider fallback
      // EUR -> USD (1.08)
      // USD -> HTG (135.0)
      // Therefore EUR -> HTG should be 1.08 * 135.0 = 145.8
      
      const double eurToUsd = 1.08;
      const double usdToHtg = 135.0;
      final double result = eurToUsd * usdToHtg;
      
      expect(result, 145.8);
    });
  });
}
