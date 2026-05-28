import 'dart:ui' show PlatformDispatcher;

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
import 'package:spendly/core/providers/app_user_provider.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:spendly/core/providers/security_provider.dart';
import 'package:spendly/core/services/subscription_service.dart';
import 'package:spendly/features/settings/view/premium_paywall_screen.dart';
import 'package:spendly/core/services/firebase_observability_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialize RevenueCat SDK immediately in anonymous mode asynchronously at app startup
  final subService = SubscriptionService();
  await subService.init(); // Wait for initialization to complete before app starts

  final sharedPrefs = await SharedPreferences.getInstance();

  // Create observability service and set up global error handlers.
  // Errors before Crashlytics is ready are queued and flushed later.
  final observabilityService = FirebaseObservabilityService();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    observabilityService.recordError(
      details.exception,
      details.stack ?? StackTrace.current,
      reason: details.context?.toString(),
    );
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    observabilityService.recordError(error, stack,
        reason: 'PlatformDispatcher error');
    return true;
  };

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPrefs),
        subscriptionServiceProvider.overrideWithValue(subService),
        firebaseObservabilityServiceProvider
            .overrideWithValue(observabilityService),
      ],
      child: const SpendlyApp(),
    ),
  );

  // Deferred initialization after first frame — avoids blocking startup.
  Future.microtask(() async {
    await Future.delayed(const Duration(milliseconds: 100));
    await observabilityService.initCrashlytics();
    await observabilityService.initPerformance();
  });
}

class SpendlyApp extends ConsumerWidget {
  const SpendlyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Keep RevenueCat user identity dynamically synced with Firebase Auth state
    ref.listen(authStateProvider, (previous, next) {
      final user = next.value;
      ref.read(subscriptionServiceProvider).syncUserIdentity(user?.uid);
      ref
          .read(firebaseObservabilityServiceProvider)
          .setUserId(user?.uid);
    });
    ref.listen(customerInfoProvider, (previous, next) {
      final prevInfo = previous?.valueOrNull;
      final nextInfo = next.valueOrNull;
      final prevEntitlement =
          prevInfo?.entitlements.all[SubscriptionService.entitlementId];
      final nextEntitlement =
          nextInfo?.entitlements.all[SubscriptionService.entitlementId];
      final prevActive = prevEntitlement?.isActive ?? false;
      final nextActive = nextEntitlement?.isActive ?? false;
      final prevPeriodType = prevEntitlement?.periodType.name;
      final nextPeriodType = nextEntitlement?.periodType.name;
      final wasTrialOrIntro =
          prevPeriodType == 'trial' || prevPeriodType == 'intro';
      final isNowNormal = nextPeriodType == 'normal';
      if (prevActive && nextActive && wasTrialOrIntro && isNowNormal) {
        ref.read(firebaseObservabilityServiceProvider).logEvent('trial_converted');
      }
    });

    final locale = ref.watch(localeProvider);
    final observers = ref.watch(navigatorObserversProvider);

    return MaterialApp(
      title: 'Receet Pro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: locale,
      navigatorObservers: observers,
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
  static const int _paywallTriggerTransactionCount = 3;
  static const String _softPaywallPromptKeyPrefix = 'soft_paywall_prompt_shown_v1_';
  bool _isUnlocked = false;
  bool _isShowingSoftPaywall = false;
  bool? _lastPremiumState;

  Future<void> _maybeShowSoftPaywallPrompt(String userId) async {
    if (_isShowingSoftPaywall) return;
    final prefs = ref.read(sharedPreferencesProvider);
    final key = '$_softPaywallPromptKeyPrefix$userId';
    final alreadyShown = prefs.getBool(key) ?? false;
    if (alreadyShown || !mounted) return;

    _isShowingSoftPaywall = true;
    await prefs.setBool(key, true);
    ref.read(firebaseObservabilityServiceProvider).logEvent(
      'paywall_shown',
      parameters: {
        'user_id': userId,
        'surface': 'soft_modal_after_threshold',
      },
    );
    if (!mounted) {
      _isShowingSoftPaywall = false;
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.94,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: const PremiumPaywallScreen(),
        ),
      ),
    );
    _isShowingSoftPaywall = false;
  }

  @override
  Widget build(BuildContext context) {
    final security = ref.watch(securityProvider);
    final userId = ref.watch(authStateProvider).value?.uid;
    final isPremium = ref.watch(isPremiumProvider);
    if (_lastPremiumState != null) {
      if (_lastPremiumState == true && isPremium == false) {
        ref.read(firebaseObservabilityServiceProvider).logEvent('subscription_cancelled');
      }
    }
    _lastPremiumState = isPremium;

    if (userId == null) return const LoginScreen();

    // If security is disabled or already unlocked, show the app
    if (!security.isPinEnabled || _isUnlocked) {
      final totalTxCountAsync = ref.watch(userTotalTransactionCountProvider(userId));
      final appUserAsync = ref.watch(appUserStreamProvider(userId));
      final accountsAsync = ref.watch(accountsStreamProvider(userId));
      return accountsAsync.when(
        data: (accounts) {
          if (accounts.isEmpty) return const OnboardingScreen();
          final totalTransactions = totalTxCountAsync.value ?? 0;
          final hasEngagedEnoughForPaywall =
              totalTransactions >= _paywallTriggerTransactionCount;
          final hasCompletedOnboardingData = appUserAsync.value != null;
          if (!isPremium && hasCompletedOnboardingData && hasEngagedEnoughForPaywall) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _maybeShowSoftPaywallPrompt(userId);
            });
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

    // Show lock screen
    return LockScreen(
      onAuthenticated: () {
        setState(() => _isUnlocked = true);
      },
    );
  }
}

// MainScreen has been moved to lib/features/home/view/main_screen.dart
