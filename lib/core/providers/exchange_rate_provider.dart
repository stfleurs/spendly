import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/core/providers/app_user_provider.dart';

/// Provides the current exchange rate for a currency pair, scoped to a user.
final ProviderFamily<double, ({String userId, String from, String to})> exchangeRateProvider = Provider.family<double, ({String userId, String from, String to})>((ref, arg) {
  if (arg.from == arg.to) return 1.0;
  
  final user = ref.watch(appUserStreamProvider(arg.userId)).value;
  final userRates = user?.exchangeRates ?? {};

  final key = '${arg.from}_${arg.to}';
  if (userRates.containsKey(key)) return userRates[key]!;

  // Fallback to hardcoded/mock rates if user hasn't defined a custom one
  final mockRates = {
    'USD_HTG': 135.0,
    'HTG_USD': 1 / 135.0,
    'EUR_USD': 1.08,
    'USD_EUR': 1 / 1.08,
    'CAD_USD': 0.74,
    'USD_CAD': 1 / 0.74,
  };

  if (mockRates.containsKey(key)) return mockRates[key]!;

  // Fallback: If we don't have a direct pair, try going through USD as a base
  if (arg.to == 'USD') {
     // No direct rate to USD found in mock or user rates
  } else if (arg.from != 'USD') {
     final rateToUsd = ref.read(exchangeRateProvider((userId: arg.userId, from: arg.from, to: 'USD')));
     final usdToTarget = ref.read(exchangeRateProvider((userId: arg.userId, from: 'USD', to: arg.to)));
     return rateToUsd * usdToTarget;
  }

  return 1.0; // Default fallback
});
