import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/features/auth/view/login_screen.dart';
import 'package:spendly/shared/themes/app_theme.dart';
import 'package:spendly/core/providers/firebase_providers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:spendly/generated/l10n/app_localizations.dart';
import 'package:spendly/core/providers/locale_provider.dart';
import 'package:spendly/core/localization/ht_localizations.dart';
import 'package:spendly/features/auth/view/onboarding_screen.dart';
import 'package:spendly/features/home/view/main_screen.dart';
import 'package:spendly/features/accounts/repository/account_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ProviderScope(child: SpendlyApp()));
}

class SpendlyApp extends ConsumerWidget {
  const SpendlyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'Spendly',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        HtMaterialLocalizationsDelegate(),
        HtCupertinoLocalizationsDelegate(),
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
        Locale('ht'),
      ],
      home: const AuthGate(),
      builder: (context, child) {
        return Material(child: child!);
      },
    );
  }
}

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          final accountsAsync = ref.watch(accountsStreamProvider(user.uid));
          return accountsAsync.when(
            data: (accounts) {
              if (accounts.isEmpty) {
                return const OnboardingScreen();
              }
              return const MainScreen();
            },
            loading: () => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
            error: (e, s) => Scaffold(
              body: Center(child: Text('Error: $e')),
            ),
          );
        }
        return const LoginScreen();
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, s) => Scaffold(
        body: Center(child: Text('Error: $e')),
      ),
    );
  }
}

// MainScreen has been moved to lib/features/home/view/main_screen.dart
