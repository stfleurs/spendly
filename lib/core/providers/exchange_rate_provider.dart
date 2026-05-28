import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/core/providers/app_user_provider.dart';

/// Provides the current exchange rate for a currency pair, scoped to a user.
final ProviderFamily<double, ({String userId, String from, String to})> exchangeRateProvider = Provider.family<double, ({String userId, String from, String to})>((ref, arg) {
  if (arg.from == arg.to) return 1.0;
  
  final user = ref.watch(appUserStreamProvider(arg.userId)).value;
  final userRates = user?.exchangeRates ?? {};

  final key = '${arg.from}_${arg.to}';
  final inverseKey = '${arg.to}_${arg.from}';
  if (userRates.containsKey(key)) return userRates[key]!;
  if (userRates.containsKey(inverseKey)) return 1 / userRates[inverseKey]!;

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
  if (mockRates.containsKey(inverseKey)) return 1 / mockRates[inverseKey]!;

  // Fallback: If we don't have a direct pair, try going through USD as a base
  if (arg.from != 'USD' && arg.to != 'USD') {
    final toUsd = '${arg.from}_USD';
    final fromUsd = 'USD_${arg.from}';
    final usdToTargetKey = 'USD_${arg.to}';
    final targetToUsdKey = '${arg.to}_USD';
    final rateToUsd =
        userRates[toUsd] ??
        (userRates[fromUsd] != null ? 1 / userRates[fromUsd]! : null) ??
        mockRates[toUsd] ??
        (mockRates[fromUsd] != null ? 1 / mockRates[fromUsd]! : null);
    final usdToTarget =
        userRates[usdToTargetKey] ??
        (userRates[targetToUsdKey] != null ? 1 / userRates[targetToUsdKey]! : null) ??
        mockRates[usdToTargetKey] ??
        (mockRates[targetToUsdKey] != null ? 1 / mockRates[targetToUsdKey]! : null);
    if (rateToUsd != null && usdToTarget != null) {
      return rateToUsd * usdToTarget;
    }
  }

  throw StateError('Missing exchange rate for ${arg.from} -> ${arg.to}');
});
