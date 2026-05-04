import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/core/models/app_transaction.dart';
import 'package:spendly/core/providers/firebase_providers.dart';

class TransactionRepository {
  final FirebaseFirestore _firestore;

  TransactionRepository(this._firestore);

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('transactions');

  Stream<List<AppTransaction>> watchTransactions(String userId) {
    return _collection
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AppTransaction.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();
    });
  }

  Future<void> addTransaction(AppTransaction transaction) async {
    // Exclude id from the map when adding to Firestore as doc id will be generated
    final data = transaction.toJson();
    data.remove('id');
    await _collection.add(data);
  }

  Future<void> updateTransaction(AppTransaction transaction) async {
    final data = transaction.toJson();
    data.remove('id');
    await _collection.doc(transaction.id).update(data);
  }

  Future<void> deleteTransaction(String id) async {
    await _collection.doc(id).delete();
  }
}

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository(ref.watch(firestoreProvider));
});

final transactionsStreamProvider = StreamProvider.family<List<AppTransaction>, String>((ref, userId) {
  return ref.watch(transactionRepositoryProvider).watchTransactions(userId);
});
