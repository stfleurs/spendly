import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/core/models/app_transaction.dart';
import 'package:spendly/core/models/account.dart';
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

  Future<bool> isDuplicate(String sourceHash) async {
    final snapshot =
        await _collection.where('sourceHash', isEqualTo: sourceHash).limit(1).get();
    return snapshot.docs.isNotEmpty;
  }

  Future<void> addTransaction(AppTransaction transaction) async {
    // Prevent duplicates if sourceHash is present
    if (transaction.sourceHash != null) {
      final exists = await isDuplicate(transaction.sourceHash!);
      if (exists) {
        debugPrint('Spendly: Skipping duplicate transaction: ${transaction.sourceHash}');
        return;
      }
    }

    if (transaction.type.toLowerCase() == 'expense') {
      await _validateBalance(transaction.accountId, transaction.amount);
    }
    // Exclude id from the map when adding to Firestore as doc id will be generated
    final data = transaction.toJson();
    data.remove('id');
    await _collection.add(data);
  }

  Future<void> updateTransaction(AppTransaction transaction) async {
    if (transaction.type.toLowerCase() == 'expense') {
      await _validateBalance(transaction.accountId, transaction.amount, excludeTransactionId: transaction.id);
    }
    final data = transaction.toJson();
    data.remove('id');
    await _collection.doc(transaction.id).update(data);
  }

  Future<void> _validateBalance(String accountId, int amount, {String? excludeTransactionId}) async {
    final accountDoc = await _firestore.collection('accounts').doc(accountId).get();
    if (!accountDoc.exists) throw Exception('Account not found');
    
    final account = Account.fromJson({...accountDoc.data()!, 'id': accountDoc.id});
    
    final txsSnapshot = await _collection.where('accountId', isEqualTo: accountId).get();
    
    // IMPORTANT: Derived balance logic
    // currentBalance = initialBalance (account.balance) + sum(transactions)
    int currentBalance = account.balance; 
    
    for (var doc in txsSnapshot.docs) {
      if (doc.id == excludeTransactionId) continue;
      final type = doc.data()['type'].toString().toLowerCase();
      final txAmount = doc.data()['amount'] as int;
      if (type == 'income') {
        currentBalance += txAmount;
      } else if (type == 'expense') {
        currentBalance -= txAmount;
      }
    }
    
    int available = currentBalance;
    if (account.type.toUpperCase() == 'CREDIT CARD') {
      available += account.creditLimit;
    }
    
    if (amount > available) {
      throw Exception('Insufficient funds (Available: ${available / 100})');
    }
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
