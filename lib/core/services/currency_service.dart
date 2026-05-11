import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/core/models/money.dart';

final currencyServiceProvider = Provider((ref) => CurrencyService());

class CurrencyService {
  static const int rateScale = 1000000;

  /// Converts Money to a base currency using scaled integer math.
  /// baseAmount = (amount * scaledRate) ~/ rateScale
  int convertToBase(int amount, double rate) {
    final int scaledRate = (rate * rateScale).round();
    return (amount * scaledRate) ~/ rateScale;
  }

  /// Creates a NormalizedMoney object by locking in the rate and base amount.
  NormalizedMoney normalize(Money money, String baseCurrency, double rate, {String source = 'manual'}) {
    final scaledRate = (rate * rateScale).round();
    final baseAmount = (money.amount * scaledRate) ~/ rateScale;
    
    return NormalizedMoney(
      original: money,
      baseAmount: baseAmount,
      baseCurrency: baseCurrency,
      exchangeRate: rate,
      rateSource: source,
    );
  }
}
