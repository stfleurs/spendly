import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/core/models/account.dart';
import 'package:spendly/core/providers/firebase_providers.dart';

class AccountRepository {
  final FirebaseFirestore _firestore;

  AccountRepository(this._firestore);

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('accounts');

  Stream<List<Account>> watchAccounts(String userId) {
    return _collection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Account.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();
    });
  }

  Future<void> addAccount(Account account) async {
    final data = account.toJson();
    data.remove('id');
    await _collection.add(data);
  }

  Future<void> updateAccount(Account account) async {
    final data = account.toJson();
    data.remove('id');
    await _collection.doc(account.id).update(data);
  }

  Future<void> deleteAccount(String id) async {
    final batch = _firestore.batch();
    
    // 1. Delete all transactions associated with this account
    final txsSnapshot = await _firestore.collection('transactions').where('accountId', isEqualTo: id).get();
    for (var doc in txsSnapshot.docs) {
      batch.delete(doc.reference);
    }
    
    // 2. Delete the account itself
    batch.delete(_collection.doc(id));
    
    // Commit the batch operation
    await batch.commit();
  }
}

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  return AccountRepository(ref.watch(firestoreProvider));
});

final accountsStreamProvider = StreamProvider.family<List<Account>, String>((ref, userId) {
  return ref.watch(accountRepositoryProvider).watchAccounts(userId);
});
