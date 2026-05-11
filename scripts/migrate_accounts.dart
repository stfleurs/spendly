import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

Future<void> migrateAccountsToSnapshots(FirebaseFirestore firestore) async {
  final accounts = await firestore.collection('accounts').get();
  final batch = firestore.batch();
  int count = 0;

  for (final doc in accounts.docs) {
    final data = doc.data();
    if (!data.containsKey('currentBalance')) {
      batch.update(doc.reference, {
        'currentBalance': data['balance'] ?? 0,
        'transactionCount': 0,
        'ledgerVersion': 1,
        'lastCalculatedAt': FieldValue.serverTimestamp(),
      });
      count++;
    }
  }

  if (count > 0) {
    await batch.commit();
    debugPrint('Migrated $count accounts.');
  } else {
    debugPrint('No accounts needed migration.');
  }
}
