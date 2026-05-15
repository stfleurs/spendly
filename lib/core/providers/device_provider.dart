import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final deviceIdProvider = FutureProvider<String>((ref) async {
  final deviceInfo = DeviceInfoPlugin();
  if (Platform.isAndroid) {
    final androidInfo = await deviceInfo.androidInfo;
    return androidInfo.id; // Unique ID on Android
  } else if (Platform.isIOS) {
    final iosInfo = await deviceInfo.iosInfo;
    return iosInfo.identifierForVendor ?? 'ios_unknown';
  } else if (Platform.isMacOS) {
    final macInfo = await deviceInfo.macOsInfo;
    return macInfo.systemGUID ?? 'macos_unknown';
  } else if (Platform.isWindows) {
    final winInfo = await deviceInfo.windowsInfo;
    return winInfo.deviceId;
  }
  return 'unknown_device';
});

final mutationSequenceProvider = StateNotifierProvider<MutationSequenceNotifier, int>((ref) {
  return MutationSequenceNotifier();
});

class MutationSequenceNotifier extends StateNotifier<int> {
  MutationSequenceNotifier() : super(0) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getInt('mutation_sequence') ?? 0;
  }

  Future<int> increment() async {
    final prefs = await SharedPreferences.getInstance();
    final next = state + 1;
    await prefs.setInt('mutation_sequence', next);
    state = next;
    return next;
  }
}
