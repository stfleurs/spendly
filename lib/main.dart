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
import 'package:spendly/shared/widgets/lock_screen.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:spendly/core/providers/security_provider.dart';
import 'package:spendly/core/services/subscription_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Initialize RevenueCat SDK immediately in anonymous mode asynchronously at app startup
  final subService = SubscriptionService();
  subService.init(); // Run in background to prevent blocking main thread / VM timeouts
  
  final sharedPrefs = await SharedPreferences.getInstance();
  
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPrefs),
        subscriptionServiceProvider.overrideWithValue(subService),
      ],
      child: const SpendlyApp(),
    ),
  );
}

class SpendlyApp extends ConsumerWidget {
  const SpendlyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Keep RevenueCat user identity dynamically synced with Firebase Auth state safely via ref.listen
    ref.listen(authStateProvider, (previous, next) {
      final user = next.value;
      ref.read(subscriptionServiceProvider).syncUserIdentity(user?.uid);
    });
    
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'Receet Pro',
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
          return const SecurityGate();
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

class SecurityGate extends ConsumerStatefulWidget {
  const SecurityGate({super.key});

  @override
  ConsumerState<SecurityGate> createState() => _SecurityGateState();
}

class _SecurityGateState extends ConsumerState<SecurityGate> {
  bool _isUnlocked = false;

  @override
  Widget build(BuildContext context) {
    final security = ref.watch(securityProvider);
    final userId = ref.watch(authStateProvider).value?.uid;

    if (userId == null) return const LoginScreen();

    // If security is disabled or already unlocked, show the app
    if (!security.isPinEnabled || _isUnlocked) {
      final accountsAsync = ref.watch(accountsStreamProvider(userId));
      return accountsAsync.when(
        data: (accounts) {
          if (accounts.isEmpty) return const OnboardingScreen();
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

    // Show lock screen
    return LockScreen(
      onAuthenticated: () {
        setState(() => _isUnlocked = true);
      },
    );
  }
}

// MainScreen has been moved to lib/features/home/view/main_screen.dart
