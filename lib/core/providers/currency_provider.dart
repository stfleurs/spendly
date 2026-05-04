import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final currencyProvider = StateNotifierProvider<CurrencyNotifier, String>((ref) {
  return CurrencyNotifier();
});

class CurrencyNotifier extends StateNotifier<String> {
  CurrencyNotifier() : super('USD') {
    _loadCurrency();
  }

  Future<void> _loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString('base_currency') ?? 'USD';
  }

  Future<void> setCurrency(String currency) async {
    state = currency;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('base_currency', currency);
  }
}
