import 'package:flutter/foundation.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';

/// Centralized service for Firebase Analytics, Crashlytics, and Performance.
///
/// Design decisions:
/// - Analytics needs no separate init — it's usable immediately after
///   [Firebase.initializeApp].
/// - Crashlytics and Performance are initialized deferredly via [initCrashlytics]
///   and [initPerformance] to avoid blocking startup. Errors that occur before
///   Crashlytics is ready are queued and flushed once it is initialized.
/// - The error queue is capped at 50 entries to prevent unbounded memory growth.
class FirebaseObservabilityService {
  // ── Analytics ─────────────────────────────────────────────────────

  /// Analytics is usable immediately after [Firebase.initializeApp].
  FirebaseAnalytics get analytics => FirebaseAnalytics.instance;

  void logEvent(String name, {Map<String, Object>? parameters}) {
    analytics.logEvent(name: name, parameters: parameters);
  }

  void setUserProperty(String name, String value) {
    analytics.setUserProperty(name: name, value: value);
  }

  Future<void> setUserId(String? id) async {
    await analytics.setUserId(id: id);
  }

  // ── Crashlytics ───────────────────────────────────────────────────

  bool _crashlyticsReady = false;

  /// Queue for errors that occur before Crashlytics is initialized.
  final List<_QueuedError> _errorQueue = [];
  static const int _maxQueueSize = 50;

  /// Initializes Crashlytics. Call this after [runApp], typically from a
  /// post-frame callback. Safe to call multiple times.
  Future<void> initCrashlytics() async {
    if (_crashlyticsReady) return;

    final crashlytics = FirebaseCrashlytics.instance;

    if (kDebugMode) {
      await crashlytics.setCrashlyticsCollectionEnabled(false);
    } else {
      await crashlytics.setCrashlyticsCollectionEnabled(true);
    }

    _crashlyticsReady = true;
    _flushErrorQueue();

    debugPrint('FirebaseObservabilityService: Crashlytics initialized');
  }

  /// Records a non-fatal error to Crashlytics, or queues it if not yet ready.
  void recordError(
    Object exception,
    StackTrace stack, {
    String? reason,
  }) {
    if (_crashlyticsReady) {
      FirebaseCrashlytics.instance.recordError(exception, stack,
          reason: reason);
    } else {
      _enqueueError(exception, stack, reason: reason);
    }
  }

  /// Logs a message to the Crashlytics breadcrumb trail.
  void log(String message) {
    if (_crashlyticsReady) {
      FirebaseCrashlytics.instance.log(message);
    }
  }

  void setCustomKey(String key, Object value) {
    if (_crashlyticsReady) {
      FirebaseCrashlytics.instance.setCustomKey(key, value);
    }
  }

  void _enqueueError(Object exception, StackTrace stack, {String? reason}) {
    if (_errorQueue.length >= _maxQueueSize) {
      _errorQueue.removeAt(0);
    }
    _errorQueue.add(_QueuedError(
      exception: exception,
      stack: stack,
      reason: reason,
    ));
  }

  void _flushErrorQueue() {
    if (_errorQueue.isEmpty) return;
    final batch = List<_QueuedError>.from(_errorQueue);
    _errorQueue.clear();
    for (final queued in batch) {
      FirebaseCrashlytics.instance.recordError(
        queued.exception,
        queued.stack,
        reason: queued.reason,
      );
    }
    debugPrint(
      'FirebaseObservabilityService: Flushed ${batch.length} queued errors',
    );
  }

  // ── Performance ───────────────────────────────────────────────────

  bool _performanceReady = false;

  /// Initializes Performance monitoring. Call this after [runApp], typically
  /// from a post-frame callback. Safe to call multiple times.
  Future<void> initPerformance() async {
    if (_performanceReady) return;

    final performance = FirebasePerformance.instance;

    if (kDebugMode) {
      await performance.setPerformanceCollectionEnabled(false);
    } else {
      await performance.setPerformanceCollectionEnabled(true);
    }

    _performanceReady = true;

    debugPrint('FirebaseObservabilityService: Performance initialized');
  }

  /// Starts an HTTP metric trace. Returns null if performance isn't ready.
  HttpMetric? startHttpMetric(String url, HttpMethod method) {
    if (!_performanceReady) return null;
    return FirebasePerformance.instance.newHttpMetric(url, method);
  }
}

class _QueuedError {
  final Object exception;
  final StackTrace stack;
  final String? reason;

  _QueuedError({
    required this.exception,
    required this.stack,
    this.reason,
  });
}
