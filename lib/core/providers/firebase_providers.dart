import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/core/services/firebase_observability_service.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final storageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

// ── Firebase Observability ──────────────────────────────────────────

final firebaseObservabilityServiceProvider =
    Provider<FirebaseObservabilityService>((ref) {
  return FirebaseObservabilityService();
});

final analyticsProvider = Provider<FirebaseAnalytics>((ref) {
  return ref.watch(firebaseObservabilityServiceProvider).analytics;
});

final analyticsObserverProvider = Provider<FirebaseAnalyticsObserver>((ref) {
  final analytics = ref.watch(analyticsProvider);
  return FirebaseAnalyticsObserver(analytics: analytics);
});

final navigatorObserversProvider = Provider<List<NavigatorObserver>>((ref) {
  final analyticsObserver = ref.watch(analyticsObserverProvider);
  return [analyticsObserver];
});
