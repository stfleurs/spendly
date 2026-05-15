import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/core/models/financial_summary.dart';
import 'package:spendly/core/models/daily_net_worth.dart';
import 'package:spendly/core/providers/firebase_providers.dart';

final financialSummaryProvider = StreamProvider.family<FinancialSummary?, String>((ref, userId) {
  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection('users')
      .doc(userId)
      .collection('financial_summary')
      .doc('main')
      .snapshots()
      .map((doc) => doc.exists ? FinancialSummary.fromJson({...doc.data()!, 'userId': userId}) : null);
});

final dailyNetWorthProvider = StreamProvider.family<List<DailyNetWorth>, ({String userId, int days})>((ref, arg) {
  final firestore = ref.watch(firestoreProvider);
  final now = DateTime.now();
  final startDate = DateTime(now.year, now.month, now.day).subtract(Duration(days: arg.days));
  
  return firestore
      .collection('users')
      .doc(arg.userId)
      .collection('daily_net_worth')
      .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
      .orderBy('date', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => DailyNetWorth.fromJson({...doc.data(), 'id': doc.id}))
          .toList());
});
