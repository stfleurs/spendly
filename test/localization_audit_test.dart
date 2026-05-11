import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Localization Audit: All keys in English must exist in French and Creole', () {
    final enFile = File('lib/l10n/app_en.arb');
    final frFile = File('lib/l10n/app_fr.arb');
    final htFile = File('lib/l10n/app_ht.arb');

    if (!enFile.existsSync()) fail('English localization file missing');
    if (!frFile.existsSync()) fail('French localization file missing');
    if (!htFile.existsSync()) fail('Creole localization file missing');

    final enJson = jsonDecode(enFile.readAsStringSync()) as Map<String, dynamic>;
    final frJson = jsonDecode(frFile.readAsStringSync()) as Map<String, dynamic>;
    final htJson = jsonDecode(htFile.readAsStringSync()) as Map<String, dynamic>;

    // Filter out metadata keys starting with @
    final enKeys = enJson.keys.where((k) => !k.startsWith('@')).toSet();
    final frKeys = frJson.keys.where((k) => !k.startsWith('@')).toSet();
    final htKeys = htJson.keys.where((k) => !k.startsWith('@')).toSet();

    final missingInFr = enKeys.difference(frKeys);
    final missingInHt = enKeys.difference(htKeys);

    final extraInFr = frKeys.difference(enKeys);
    final extraInHt = htKeys.difference(enKeys);

    bool hasErrors = false;

    if (missingInFr.isNotEmpty) {
      hasErrors = true;
      debugPrint('\n❌ Missing translations in French (app_fr.arb):');
      for (final key in missingInFr) {
        debugPrint('  - $key: "${enJson[key]}"');
      }
    }

    if (missingInHt.isNotEmpty) {
      hasErrors = true;
      debugPrint('\n❌ Missing translations in Creole (app_ht.arb):');
      for (final key in missingInHt) {
        debugPrint('  - $key: "${enJson[key]}"');
      }
    }
    
    if (extraInFr.isNotEmpty) {
       debugPrint('\n⚠️ Extra keys in French (not in English): ${extraInFr.join(", ")}');
    }

    if (extraInHt.isNotEmpty) {
       debugPrint('\n⚠️ Extra keys in Creole (not in English): ${extraInHt.join(", ")}');
    }

    expect(hasErrors, isFalse, reason: 'Localization files are out of sync. See console output for details.');
  });
}
