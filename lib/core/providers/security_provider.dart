import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';

class SecurityState {
  final bool isPinEnabled;
  final bool isBiometricEnabled;
  final String? pin;

  SecurityState({
    this.isPinEnabled = false,
    this.isBiometricEnabled = false,
    this.pin,
  });

  SecurityState copyWith({
    bool? isPinEnabled,
    bool? isBiometricEnabled,
    String? pin,
  }) {
    return SecurityState(
      isPinEnabled: isPinEnabled ?? this.isPinEnabled,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      pin: pin ?? this.pin,
    );
  }
}

class SecurityNotifier extends StateNotifier<SecurityState> {
  final SharedPreferences _prefs;
  final LocalAuthentication _auth = LocalAuthentication();

  SecurityNotifier(this._prefs) : super(SecurityState()) {
    _loadSettings();
  }

  void _loadSettings() {
    state = SecurityState(
      isPinEnabled: _prefs.getBool('pin_enabled') ?? false,
      isBiometricEnabled: _prefs.getBool('biometric_enabled') ?? false,
      pin: _prefs.getString('app_pin'),
    );
  }

  Future<void> setPin(String pin) async {
    await _prefs.setString('app_pin', pin);
    await _prefs.setBool('pin_enabled', true);
    state = state.copyWith(pin: pin, isPinEnabled: true);
  }

  Future<void> disablePin() async {
    await _prefs.remove('app_pin');
    await _prefs.setBool('pin_enabled', false);
    state = state.copyWith(pin: null, isPinEnabled: false);
  }

  Future<void> toggleBiometric(bool enabled) async {
    final canAuthWithBiometrics = await _auth.canCheckBiometrics;
    final canAuth = canAuthWithBiometrics || await _auth.isDeviceSupported();
    
    if (enabled && !canAuth) {
      throw Exception('Biometric authentication not available on this device');
    }

    await _prefs.setBool('biometric_enabled', enabled);
    state = state.copyWith(isBiometricEnabled: enabled);
  }

  Future<bool> authenticate() async {
    if (!state.isPinEnabled && !state.isBiometricEnabled) return true;

    if (state.isBiometricEnabled) {
      try {
        // Using flat parameters for compatibility with local_auth 3.0.1
        return await _auth.authenticate(
          localizedReason: 'Please authenticate to access Receet Pro',
          persistAcrossBackgrounding: true,
          biometricOnly: true,
        );
      } catch (e) {
        return false;
      }
    }
    return false; 
  }



}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(); // Should be overridden in main.dart
});

final securityProvider = StateNotifierProvider<SecurityNotifier, SecurityState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SecurityNotifier(prefs);
});
