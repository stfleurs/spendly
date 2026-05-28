import 'package:intl/intl.dart';

const Map<String, _CurrencyConfig> _currencyConfigs = {
  'USD': _CurrencyConfig(symbol: r'$', isPrefix: true),
  'EUR': _CurrencyConfig(symbol: '€', isPrefix: true),
  'HTG': _CurrencyConfig(symbol: 'G', isPrefix: false),
  'CAD': _CurrencyConfig(symbol: r'$', isPrefix: true),
};

class _CurrencyConfig {
  final String symbol;
  final bool isPrefix;
  const _CurrencyConfig({required this.symbol, required this.isPrefix});
}

const int _compactThresholdCents = 100000000; // $1M in cents

/// Formats a cents amount into a locale-aware currency string.
///
/// For values ≥ \$1M (100,000,000 cents), uses compact notation ("\$1.2M").
/// For values below threshold, uses standard grouping separators ("\$1,234.56").
String formatCents(
  int cents,
  String currencyCode, {
  bool showSign = false,
  int? decimalDigits,
  String locale = 'en',
}) {
  final config =
      _currencyConfigs[currencyCode] ??
      const _CurrencyConfig(symbol: r'$', isPrefix: true);

  final isNegative = cents < 0;
  final absCents = cents.abs();

  String sign;
  if (isNegative) {
    sign = '-';
  } else if (showSign) {
    sign = '+';
  } else {
    sign = '';
  }

  final dollars = absCents / 100.0;

  if (absCents >= _compactThresholdCents) {
    final compact = NumberFormat.compact(locale: locale);
    compact.minimumFractionDigits = 1;
    compact.maximumFractionDigits = 1;
    final number = compact.format(dollars);
    if (config.isPrefix) return '$sign${config.symbol}$number';
    return '$sign$number ${config.symbol}';
  }

  final decimals = decimalDigits ?? 2;
  final pattern = decimals > 0 ? '#,##0.${'0' * decimals}' : '#,##0';
  final numberFormat = NumberFormat(pattern, locale);
  final number = numberFormat.format(dollars);
  if (config.isPrefix) return '$sign${config.symbol}$number';
  return '$sign$number ${config.symbol}';
}
