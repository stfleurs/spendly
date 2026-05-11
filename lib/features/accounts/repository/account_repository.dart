import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/core/models/account.dart';
import 'package:spendly/core/models/app_transaction.dart';
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
    final batch = _firestore.batch();
    final docRef = _collection.doc();
    final data = account.copyWith(
      id: docRef.id,
      currentBalance: account.balance,
    ).toJson();
    data.remove('id');
    batch.set(docRef, data);
    await batch.commit();
  }

  Future<void> updateAccount(Account account) async {
    final batch = _firestore.batch();
    final data = account.toJson();
    data.remove('id');
    batch.update(_collection.doc(account.id), data);
    await batch.commit();
  }

  Future<void> deleteAccount(Account account) async {
    // 1. Fetch all transactions for this account
    // We need the data to update monthly summaries before deleting
    final txsSnapshot = await _firestore
        .collection('transactions')
        .where('accountId', isEqualTo: account.id)
        .get();

    // Firestore batch limit is 500. We'll process in chunks if necessary.
    // For account deletion, we'll use a transaction or multiple batches.
    
    final chunks = _chunkList(txsSnapshot.docs, 450); // Leave room for account & summaries

    for (final chunk in chunks) {
      final batch = _firestore.batch();
      
      for (final doc in chunk) {
        final tx = AppTransaction.fromJson({...doc.data(), 'id': doc.id});
        
        // Update Monthly Summary (Revert the transaction's impact)
        _updateMonthlySummary(batch, account.userId, tx);
        
        // Delete Transaction
        batch.delete(doc.reference);
      }
      
      // If this is the last chunk, also delete the account
      if (chunk == chunks.last) {
        batch.delete(_collection.doc(account.id));
      }
      
      await batch.commit();
    }
    
    // If there were no transactions, we still need to delete the account
    if (txsSnapshot.docs.isEmpty) {
      await _collection.doc(account.id).delete();
    }
  }

  List<List<T>> _chunkList<T>(List<T> list, int chunkSize) {
    List<List<T>> chunks = [];
    for (var i = 0; i < list.length; i += chunkSize) {
      chunks.add(list.sublist(i, i + chunkSize > list.length ? list.length : i + chunkSize));
    }
    return chunks;
  }

  void _updateMonthlySummary(
    WriteBatch batch,
    String userId,
    AppTransaction transaction,
  ) {
    final monthId =
        "${transaction.date.year}_${transaction.date.month.toString().padLeft(2, '0')}";
    final summaryRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('monthly_summaries')
        .doc(monthId);

    final isExpense = transaction.type.toLowerCase() == 'expense';
    final isIncome = transaction.type.toLowerCase() == 'income';
    final typeKey = isIncome ? 'income' : 'expense';

    int incomeDelta = 0;
    int expenseDelta = 0;
    int netChangeDelta = 0;
    
    final normalizedAmount = transaction.amountInBaseCurrency;
    final rawAmount = transaction.amount;

    if (isIncome) {
      incomeDelta = -normalizedAmount;
      netChangeDelta = incomeDelta;
    } else if (isExpense) {
      expenseDelta = -normalizedAmount;
      netChangeDelta = -expenseDelta;
    }

    final updates = {
      'income': FieldValue.increment(incomeDelta),
      'expenses': FieldValue.increment(expenseDelta),
      'netChange': FieldValue.increment(netChangeDelta),
      'transactionCount': FieldValue.increment(-1),
      'lastUpdatedAt': DateTime.now(),
      'categoryTotals.${transaction.categoryId}':
          FieldValue.increment(netChangeDelta), 
      'accountTotals.${transaction.accountId}':
          FieldValue.increment(netChangeDelta),
      'currencyBreakdown.$typeKey.${transaction.currency}':
          FieldValue.increment(-rawAmount),
    };


    batch.set(summaryRef, updates, SetOptions(merge: true));
  }

}

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  return AccountRepository(ref.watch(firestoreProvider));
});

final accountsStreamProvider = StreamProvider.family<List<Account>, String>((ref, userId) {
  return ref.watch(accountRepositoryProvider).watchAccounts(userId);
});
