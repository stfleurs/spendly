import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Service class interfacing with the RevenueCat SDK.
class SubscriptionService {
  /// The entitlement ID configured in the RevenueCat Console.
  static const entitlementId = 'pro';

  bool _isInitialized = false;

  /// Initializes the RevenueCat SDK in anonymous mode.
  Future<void> init() async {
    try {
      if (_isInitialized) return;

      // 1. Configure logging based on build mode
      if (kDebugMode) {
        await Purchases.setLogLevel(LogLevel.debug);
      } else {
        await Purchases.setLogLevel(LogLevel.warn);
      }

      // 2. Configure SDK with the correct platform-specific API key
      final String apiKey = Platform.isAndroid
          ? 'goog_pcGRKvDSqzHaXaJxCZToLKAAPrt' // Google Play key
          : 'appl_REPLACE_WITH_YOUR_IOS_KEY';   // App Store key (TODO)

      if (apiKey.contains('REPLACE_WITH_YOUR')) {
        debugPrint('WARNING: RevenueCat API Key is not configured for this platform.');
        if (!Platform.isAndroid) return; // Prevent crash/errors on iOS if key is missing
      }

      final configuration = PurchasesConfiguration(apiKey);
      await Purchases.configure(configuration);
      _isInitialized = true;
      debugPrint('RevenueCat: Successfully initialized anonymously');

      // 3. Perform initial identity sync if a user is already signed in at startup
      final currentFirebaseUid = FirebaseAuth.instance.currentUser?.uid;
      if (currentFirebaseUid != null) {
        debugPrint('RevenueCat: Syncing initial user identity: $currentFirebaseUid');
        await Purchases.logIn(currentFirebaseUid);
      }
    } catch (e) {
      debugPrint('RevenueCat Initialization Error: $e');
    }
  }

  /// Synchronizes RevenueCat user identity with Firebase Auth UID.
  Future<void> syncUserIdentity(String? uid) async {
    if (!_isInitialized) {
      debugPrint('RevenueCat: Skipping identity sync. SDK not yet initialized.');
      return;
    }
    try {
      final currentAppUserId = await Purchases.appUserID;
      final isAnonymous = await Purchases.isAnonymous;

      if (uid != null) {
        if (currentAppUserId != uid) {
          debugPrint('RevenueCat: Syncing identity to authenticated user: $uid');
          await Purchases.logIn(uid);
        } else {
          debugPrint('RevenueCat: Already authenticated as user: $uid');
        }
      } else {
        if (!isAnonymous) {
          debugPrint('RevenueCat: User signed out, reverting to anonymous identity');
          await Purchases.logOut();
        } else {
          debugPrint('RevenueCat: Already operating in anonymous mode');
        }
      }
    } catch (e) {
      debugPrint('RevenueCat Error syncing user identity: $e');
    }
  }

  /// Purchases a specific package, returning a unified result wrapper.
  Future<PurchaseResult> purchasePackage(Package package) async {
    try {
      final customerInfo = await Purchases.purchasePackage(package);
      final hasPremium = customerInfo.entitlements.all[entitlementId]?.isActive ?? false;
      return PurchaseResult.success(customerInfo, hasPremium);
    } catch (e) {
      if (e is PlatformException) {
        final errorCode = PurchasesErrorHelper.getErrorCode(e);
        if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
          debugPrint('RevenueCat: Purchase flow cancelled by the user');
          return PurchaseResult.cancelled();
        }
      }
      debugPrint('RevenueCat Purchase Error: $e');
      return PurchaseResult.error(e.toString());
    }
  }

  /// Restores active purchases for the user.
  Future<RestoreResult> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      final hasPremium = customerInfo.entitlements.all[entitlementId]?.isActive ?? false;
      return RestoreResult.success(customerInfo, hasPremium);
    } catch (e) {
      debugPrint('RevenueCat Restore Error: $e');
      return RestoreResult.error(e.toString());
    }
  }
}

/// Unified wrapper representing purchase flow results.
class PurchaseResult {
  final bool isSuccess;
  final bool isCancelled;
  final bool hasPremium;
  final String? errorMessage;
  final CustomerInfo? customerInfo;

  PurchaseResult.success(this.customerInfo, this.hasPremium)
      : isSuccess = true,
        isCancelled = false,
        errorMessage = null;

  PurchaseResult.cancelled()
      : isSuccess = false,
        isCancelled = true,
        hasPremium = false,
        errorMessage = null,
        customerInfo = null;

  PurchaseResult.error(this.errorMessage)
      : isSuccess = false,
        isCancelled = false,
        hasPremium = false,
        customerInfo = null;
}

/// Unified wrapper representing purchase restoration results.
class RestoreResult {
  final bool isSuccess;
  final bool hasPremium;
  final String? errorMessage;
  final CustomerInfo? customerInfo;

  RestoreResult.success(this.customerInfo, this.hasPremium)
      : isSuccess = true,
        errorMessage = null;

  RestoreResult.error(this.errorMessage)
      : isSuccess = false,
        hasPremium = false,
        customerInfo = null;
}

// ============================================================================
// Riverpod Providers
// ============================================================================

/// Provider for the SubscriptionService instance.
final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  return SubscriptionService();
});

/// Reactive StreamProvider that streams CustomerInfo.
/// Leverages local cache for offline awareness first, then listens to updates.
final customerInfoProvider = StreamProvider<CustomerInfo>((ref) {
  final controller = StreamController<CustomerInfo>();

  // 1. Emit cached customer info immediately (Offline Cache Awareness)
  Purchases.getCustomerInfo().then((info) {
    if (!controller.isClosed) {
      controller.add(info);
    }
  }).catchError((e) {
    debugPrint('RevenueCat: Error fetching initial customer info: $e');
  });

  // 2. Register listener for real-time SDK state changes (purchases, restores, syncs)
  void listener(CustomerInfo info) {
    if (!controller.isClosed) {
      controller.add(info);
    }
  }
  Purchases.addCustomerInfoUpdateListener(listener);

  // 3. Clean up the listener and stream when provider is disposed
  ref.onDispose(() {
    Purchases.removeCustomerInfoUpdateListener(listener);
    controller.close();
  });

  return controller.stream;
});

/// FutureProvider that fetches available products/offerings from the RevenueCat dashboard.
final offeringsProvider = FutureProvider<Offerings>((ref) async {
  try {
    debugPrint('RevenueCat: Fetching offerings...');
    final offerings = await Purchases.getOfferings();
    
    if (offerings.current == null) {
      debugPrint('RevenueCat WARNING: No "Current" offering is set in the dashboard.');
    } else {
      debugPrint('RevenueCat: Found current offering: ${offerings.current!.identifier}');
      debugPrint('RevenueCat: Available packages: ${offerings.current!.availablePackages.length}');
      for (var package in offerings.current!.availablePackages) {
        debugPrint('  - Package: ${package.identifier} (Product: ${package.storeProduct.identifier})');
      }
    }
    return offerings;
  } catch (e) {
    debugPrint('RevenueCat Error fetching offerings: $e');
    rethrow;
  }
});

/// A robust, future-proof computed boolean provider to check if the user is a Premium subscriber.
/// Rest of the app gates premium features by watching this provider.
final isPremiumProvider = Provider<bool>((ref) {
  final customerInfoAsync = ref.watch(customerInfoProvider);
  return customerInfoAsync.when(
    data: (info) => info.entitlements.all[SubscriptionService.entitlementId]?.isActive ?? false,
    loading: () => false, // fallback to standard tier while loading cache
    error: (e, s) {
      debugPrint('RevenueCat isPremiumProvider error: $e');
      return false;
    },
  );
});
