import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/core/models/app_transaction.dart';
import 'package:spendly/core/models/bill.dart';
import 'package:spendly/core/providers/firebase_providers.dart';

enum TransactionSource { manual, import, sync, reconciliation }

enum TransactionInsertResult { success, duplicate, error }

class TransactionRepository {
  final FirebaseFirestore _firestore;

  TransactionRepository(this._firestore);

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('transactions');

  Stream<List<AppTransaction>> watchTransactions(
    String userId, {
    int limit = 50,
  }) {
    return _collection
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .orderBy(FieldPath.documentId, descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) => AppTransaction.fromJson({...doc.data(), 'id': doc.id}),
              )
              .toList();
        });
  }

  Stream<List<AppTransaction>> watchPlanTransactions(String userId, String templateId) {
    return _collection
        .where('userId', isEqualTo: userId)
        .where('templateId', isEqualTo: templateId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppTransaction.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  Stream<List<AppTransaction>> watchTransactionsByMonth(String userId, DateTime month) {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    return _collection
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppTransaction.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  Future<List<AppTransaction>> getTransactionsPaginated(
    String userId, {
    DateTime? startAfterDate,
    String? startAfterId,
    int limit = 50,
  }) async {
    var query = _collection
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .orderBy(FieldPath.documentId, descending: true)
        .limit(limit);

    if (startAfterDate != null && startAfterId != null) {
      query = query.startAfter([startAfterDate, startAfterId]);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => AppTransaction.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  Future<bool> isDuplicate(String accountId, String sourceHash) async {
    final snapshot = await _collection
        .where('accountId', isEqualTo: accountId)
        .where('sourceHash', isEqualTo: sourceHash)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  Future<TransactionInsertResult> addTransaction(
    AppTransaction transaction, {
    TransactionSource source = TransactionSource.manual,
  }) async {
    try {
      if (transaction.sourceHash != null) {
        if (await isDuplicate(transaction.accountId, transaction.sourceHash!)) {
          return TransactionInsertResult.duplicate;
        }
      }

      final batch = _firestore.batch();

      // 1. Transaction Doc
      final txData = transaction.toJson();
      txData.remove('id');
      final txRef = _collection.doc();
      batch.set(txRef, txData);

      // 2. Account Update (O(1) Snapshot Update)
      final isExpense = transaction.type.toLowerCase() == 'expense';
      final isIncome = transaction.type.toLowerCase() == 'income';
      int delta = 0;
      if (isIncome) {
        delta = transaction.amount;
      } else if (isExpense) {
        delta = -transaction.amount;
      }

      final accRef = _firestore
          .collection('accounts')
          .doc(transaction.accountId);

      batch.update(accRef, {
        'currentBalance': FieldValue.increment(delta),
        'transactionCount': FieldValue.increment(1),
        'lastTransactionAt': transaction.date,
        'ledgerVersion': FieldValue.increment(1),
        'lastCalculatedAt': DateTime.now(),
        'lastLedgerMutationId': txRef.id,
      });

      // 3. Update Monthly Summary
      _updateMonthlySummary(batch, transaction.userId, transaction);

      await batch.commit();
      return TransactionInsertResult.success;
    } catch (e) {
      debugPrint('Spendly: Error adding transaction: $e');
      rethrow;
    }
  }

  Future<void> updateTransaction(AppTransaction transaction) async {
    final batch = _firestore.batch();

    // 1. Get the OLD transaction to calculate balance delta
    final oldTxDoc = await _collection.doc(transaction.id).get();
    if (!oldTxDoc.exists) throw Exception('Transaction not found');
    final oldTx = AppTransaction.fromJson({
      ...oldTxDoc.data()!,
      'id': oldTxDoc.id,
    });

    // 2. Calculate Balance Delta
    int delta = 0;

    // Reverse old
    if (oldTx.type.toLowerCase() == 'income') {
      delta -= oldTx.amount;
    } else if (oldTx.type.toLowerCase() == 'expense') {
      delta += oldTx.amount;
    }

    // Apply new
    if (transaction.type.toLowerCase() == 'income') {
      delta += transaction.amount;
    } else if (transaction.type.toLowerCase() == 'expense') {
      delta -= transaction.amount;
    }

    // 3. Update Transaction Doc (Strict Batch)
    final data = transaction.toJson();
    data.remove('id');
    batch.update(_collection.doc(transaction.id), data);

    // 4. Update Account Snapshot
    final accRef = _firestore.collection('accounts').doc(transaction.accountId);
    batch.update(accRef, {
      'currentBalance': FieldValue.increment(delta),
      'lastTransactionAt': transaction.date,
      'ledgerVersion': FieldValue.increment(1),
      'lastCalculatedAt': DateTime.now(),
      'lastLedgerMutationId': transaction.id,
    });

    // 5. Update Monthly Summary
    _updateMonthlySummary(batch, transaction.userId, oldTx, isDelete: true);
    _updateMonthlySummary(batch, transaction.userId, transaction);

    await batch.commit();
  }

  Future<void> deleteTransaction(AppTransaction transaction) async {
    final batch = _firestore.batch();

    // 1. Delete Transaction
    batch.delete(_collection.doc(transaction.id));

    // 2. Revert Account Balance
    final isExpense = transaction.type.toLowerCase() == 'expense';
    final isIncome = transaction.type.toLowerCase() == 'income';
    int delta = 0;
    if (isIncome) {
      delta = -transaction.amount;
    } else if (isExpense) {
      delta = transaction.amount;
    }

    final accRef = _firestore.collection('accounts').doc(transaction.accountId);
    batch.update(accRef, {
      'currentBalance': FieldValue.increment(delta),
      'transactionCount': FieldValue.increment(-1),
      'ledgerVersion': FieldValue.increment(1),
      'lastCalculatedAt': DateTime.now(),
      'lastLedgerMutationId': 'delete_${transaction.id}',
    });

    // 3. Update Monthly Summary
    _updateMonthlySummary(batch, transaction.userId, transaction, isDelete: true);

    await batch.commit();
  }

  Future<void> payBill({
    required AppTransaction transaction,
    required Bill bill,
    required int amountCents,
  }) async {
    await _firestore.runTransaction((tx) async {
      // 1. Get current bill state
      final billRef = _firestore
          .collection('users')
          .doc(bill.userId)
          .collection('bills')
          .doc(bill.id);
      final billDoc = await tx.get(billRef);
      if (!billDoc.exists) throw Exception('Bill not found');
      
      final currentPaid = billDoc.data()?['paidAmount'] as int? ?? 0;
      final totalAmount = billDoc.data()?['amount'] as int? ?? bill.amount;

      // 2. Create Transaction
      final txData = transaction.copyWith(
        billId: bill.id,
        templateId: bill.templateId,
      ).toJson();
      txData.remove('id');
      final txRef = _firestore.collection('transactions').doc();
      tx.set(txRef, txData);

      // 3. Update Bill
      final newPaid = currentPaid + amountCents;
      final String newStatus = newPaid >= totalAmount ? 'paid' : 'partiallyPaid';

      tx.update(billRef, {
        'paidAmount': newPaid,
        'status': newStatus,
        'linkedTransactionId': txRef.id,
      });

      // 4. Update Account
      final accRef = _firestore.collection('accounts').doc(transaction.accountId);
      tx.update(accRef, {
        'currentBalance': FieldValue.increment(-amountCents),
        'transactionCount': FieldValue.increment(1),
        'lastTransactionAt': transaction.date,
        'ledgerVersion': FieldValue.increment(1),
        'lastCalculatedAt': DateTime.now(),
        'lastLedgerMutationId': txRef.id,
      });

      // 5. Update Monthly Summary
      _updateMonthlySummaryInTransaction(tx, transaction.userId, transaction);
    });
  }

  void _updateMonthlySummaryInTransaction(
    Transaction tx,
    String userId,
    AppTransaction transaction, {
    bool isDelete = false,
  }) {
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
    int txCountDelta = isDelete ? -1 : 1;

    final normalizedAmount = transaction.amountInBaseCurrency;
    final rawAmount = transaction.amount;

    if (isIncome) {
      incomeDelta = isDelete ? -normalizedAmount : normalizedAmount;
      netChangeDelta = incomeDelta;
    } else if (isExpense) {
      expenseDelta = isDelete ? -normalizedAmount : normalizedAmount;
      netChangeDelta = -expenseDelta;
    }

    final updates = {
      'userId': userId,
      'income': FieldValue.increment(incomeDelta),
      'expenses': FieldValue.increment(expenseDelta),
      'netChange': FieldValue.increment(netChangeDelta),
      'transactionCount': FieldValue.increment(txCountDelta),
      'lastUpdatedAt': DateTime.now(),
      'categoryTotals.${transaction.categoryId}':
          FieldValue.increment(netChangeDelta),
      'accountTotals.${transaction.accountId}':
          FieldValue.increment(netChangeDelta),
      'currencyBreakdown.$typeKey.${transaction.currency}':
          FieldValue.increment(isDelete ? -rawAmount : rawAmount),
    };

    tx.set(summaryRef, updates, SetOptions(merge: true));
  }


  void _updateMonthlySummary(
    WriteBatch batch,
    String userId,
    AppTransaction transaction, {
    bool isDelete = false,
  }) {
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
    int txCountDelta = isDelete ? -1 : 1;

    final normalizedAmount = transaction.amountInBaseCurrency;
    final rawAmount = transaction.amount;

    if (isIncome) {
      incomeDelta = isDelete ? -normalizedAmount : normalizedAmount;
      netChangeDelta = incomeDelta;
    } else if (isExpense) {
      expenseDelta = isDelete ? -normalizedAmount : normalizedAmount;
      netChangeDelta = -expenseDelta;
    }

    final updates = {
      'userId': userId,
      'income': FieldValue.increment(incomeDelta),
      'expenses': FieldValue.increment(expenseDelta),
      'netChange': FieldValue.increment(netChangeDelta),
      'transactionCount': FieldValue.increment(txCountDelta),
      'lastUpdatedAt': DateTime.now(),
      'categoryTotals.${transaction.categoryId}':
          FieldValue.increment(netChangeDelta),
      'accountTotals.${transaction.accountId}':
          FieldValue.increment(netChangeDelta),
      // Rule #5: Namespaced currency breakdown
      'currencyBreakdown.$typeKey.${transaction.currency}':
          FieldValue.increment(isDelete ? -rawAmount : rawAmount),
    };

    batch.set(summaryRef, updates, SetOptions(merge: true));
  }
}

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository(ref.watch(firestoreProvider));
});

final transactionsStreamProvider =
    StreamProvider.family<List<AppTransaction>, String>((ref, userId) {
      return ref.watch(transactionRepositoryProvider).watchTransactions(userId);
    });

final transactionsByMonthProvider = StreamProvider.family<List<AppTransaction>, ({String userId, DateTime month})>((ref, arg) {
  return ref.watch(transactionRepositoryProvider).watchTransactionsByMonth(arg.userId, arg.month);
});

final planTransactionsProvider = StreamProvider.family<List<AppTransaction>, ({String userId, String templateId})>((ref, arg) { return ref.read(transactionRepositoryProvider).watchPlanTransactions(arg.userId, arg.templateId); });
