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
        
        // Revert all derived ledgers impacted by this transaction
        _updateMonthlySummary(batch, account.userId, tx);
        _updateFinancialSummary(batch, account.userId, tx);
        _updateDailyNetWorth(batch, account.userId, tx);
        _revertEnvelopeImpact(batch, account.userId, tx);
        
        // Delete Transaction
        batch.delete(doc.reference);
      }
      batch.set(_firestore.collection('users').doc(account.userId), {
        'totalTransactionCount': FieldValue.increment(-chunk.length),
      }, SetOptions(merge: true));
      
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

  void _updateFinancialSummary(
    WriteBatch batch,
    String userId,
    AppTransaction transaction,
  ) {
    final summaryRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('financial_summary')
        .doc('main');
    final type = transaction.type.toLowerCase();
    final amount = transaction.amountInBaseCurrency;
    final netWorthDelta = type == 'income' ? -amount : (type == 'expense' ? amount : 0);
    batch.set(summaryRef, {
      'netWorth': FieldValue.increment(netWorthDelta),
      'updatedAt': DateTime.now(),
      'ledgerVersion': FieldValue.increment(1),
      'reconciled': false,
    }, SetOptions(merge: true));
  }

  void _updateDailyNetWorth(
    WriteBatch batch,
    String userId,
    AppTransaction transaction,
  ) {
    final dateId =
        "${transaction.date.year}-${transaction.date.month.toString().padLeft(2, '0')}-${transaction.date.day.toString().padLeft(2, '0')}";
    final dailyRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('daily_net_worth')
        .doc(dateId);
    final type = transaction.type.toLowerCase();
    final amount = transaction.amountInBaseCurrency;
    final netWorthDelta = type == 'income' ? -amount : (type == 'expense' ? amount : 0);
    batch.set(dailyRef, {
      'netWorth': FieldValue.increment(netWorthDelta),
      'date': Timestamp.fromDate(DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      )),
      'ledgerVersion': FieldValue.increment(1),
    }, SetOptions(merge: true));
  }

  void _revertEnvelopeImpact(
    WriteBatch batch,
    String userId,
    AppTransaction transaction,
  ) {
    final type = transaction.type.toLowerCase();
    if (type == 'income') {
      batch.set(_firestore.collection('users').doc(userId), {
        'readyToAssign': FieldValue.increment(-transaction.amountInBaseCurrency),
      }, SetOptions(merge: true));
      return;
    }
    if (type == 'expense' && transaction.categoryId.isNotEmpty) {
      final catRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('categories')
          .doc(transaction.categoryId);
      batch.update(catRef, {
        'availableBalance': FieldValue.increment(transaction.amountInBaseCurrency),
      });
    }
  }

  /// Recalculates the account balance from scratch using the transaction ledger.
  /// This is the "Self-Healing" mechanism to prevent snapshot corruption.
  Future<void> syncAccountBalance(String userId, String accountId) async {
    final accountDoc = await _collection.doc(accountId).get();
    if (!accountDoc.exists) return;
    
    final account = Account.fromJson({...accountDoc.data()!, 'id': accountId});
    
    // 1. Fetch all transactions for this account
    final txsSnapshot = await _firestore
        .collection('transactions')
        .where('accountId', isEqualTo: accountId)
        .get();
        
    int runningBalance = account.balance; // Start with initial balance
    
    for (final doc in txsSnapshot.docs) {
      final tx = AppTransaction.fromJson({...doc.data(), 'id': doc.id});
      final type = tx.type.toLowerCase();
      
      if (type == 'income') {
        runningBalance += tx.amount;
      } else if (type == 'expense') {
        runningBalance -= tx.amount;
      } else if (type == 'transfer') {
        // Transfers are tricky - check if we are 'from' or 'to'
        // But for now, AppTransaction doesn't have from/to, it's just 'transfer' type.
        // Assuming 'transfer' in this context means expense from this account
        runningBalance -= tx.amount;
      }
    }

    // 2. Update the snapshot
    await _collection.doc(accountId).update({
      'currentBalance': runningBalance,
      'lastCalculatedAt': DateTime.now(),
      'ledgerVersion': FieldValue.increment(1),
    });
  }

}

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  return AccountRepository(ref.watch(firestoreProvider));
});

final accountsStreamProvider = StreamProvider.family<List<Account>, String>((ref, userId) {
  return ref.watch(accountRepositoryProvider).watchAccounts(userId);
});
