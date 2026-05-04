import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

/// A custom MaterialLocalizations delegate for Haitian Creole (ht)
/// that falls back to English for Material-specific strings.
class HtMaterialLocalizationsDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  const HtMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ht';

  @override
  Future<MaterialLocalizations> load(Locale locale) async {
    return SynchronousFuture<MaterialLocalizations>(const HtMaterialLocalizations());
  }

  @override
  bool shouldReload(HtMaterialLocalizationsDelegate old) => false;
}

class HtMaterialLocalizations extends DefaultMaterialLocalizations {
  const HtMaterialLocalizations();
}

/// A custom CupertinoLocalizations delegate for Haitian Creole (ht)
/// that falls back to English for Cupertino-specific strings.
class HtCupertinoLocalizationsDelegate extends LocalizationsDelegate<CupertinoLocalizations> {
  const HtCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ht';

  @override
  Future<CupertinoLocalizations> load(Locale locale) async {
    return SynchronousFuture<CupertinoLocalizations>(const HtCupertinoLocalizations());
  }

  @override
  bool shouldReload(HtCupertinoLocalizationsDelegate old) => false;
}

class HtCupertinoLocalizations extends DefaultCupertinoLocalizations {
  const HtCupertinoLocalizations();
}
