import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleState {
  final Locale locale;
  final bool isDeviceDefault;

  const LocaleState({required this.locale, required this.isDeviceDefault});
}

final localeProvider = StateNotifierProvider<LocaleNotifier, LocaleState>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<LocaleState> {
  LocaleNotifier() : super(const LocaleState(locale: Locale('en'), isDeviceDefault: true)) {
    _loadLocale();
  }

  Locale _deviceLocale() {
    final deviceLocale = PlatformDispatcher.instance.locale;
    const supported = ['en', 'fr', 'ht'];
    final code = deviceLocale.languageCode;
    return supported.contains(code) ? Locale(code) : const Locale('en');
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString('language_code');
    if (savedCode != null) {
      state = LocaleState(locale: Locale(savedCode), isDeviceDefault: false);
    } else {
      state = LocaleState(locale: _deviceLocale(), isDeviceDefault: true);
    }
  }

  Future<void> setLocale(Locale locale) async {
    state = LocaleState(locale: locale, isDeviceDefault: false);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
  }

  Future<void> resetToDeviceLocale() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('language_code');
    state = LocaleState(locale: _deviceLocale(), isDeviceDefault: true);
  }
}
