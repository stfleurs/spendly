import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides the current exchange rate for a currency pair.
/// In a production app, this would fetch from an external API and cache results.
final ProviderFamily<double, ({String from, String to})> exchangeRateProvider = Provider.family<double, ({String from, String to})>((ref, arg) {
  if (arg.from == arg.to) return 1.0;
  
  // Mock rates for common pairs in this app
  final rates = {
    'USD_HTG': 135.0,
    'HTG_USD': 1 / 135.0,
    'EUR_USD': 1.08,
    'USD_EUR': 1 / 1.08,
    'CAD_USD': 0.74,
    'USD_CAD': 1 / 0.74,
  };

  final key = '${arg.from}_${arg.to}';
  if (rates.containsKey(key)) return rates[key]!;

  // Fallback: If we don't have a direct pair, try going through USD as a base
  if (arg.to == 'USD') {
     // We already checked above, but just in case
  } else if (arg.from != 'USD') {
     final rateToUsd = ref.read(exchangeRateProvider((from: arg.from, to: 'USD')));
     final usdToTarget = ref.read(exchangeRateProvider((from: 'USD', to: arg.to)));
     return rateToUsd * usdToTarget;
  }

  return 1.0; // Default fallback
});
