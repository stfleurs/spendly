import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:spendly/features/transactions/repository/transaction_repository.dart';
import 'package:spendly/core/models/app_transaction.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late TransactionRepository repository;
  const userId = 'resilience_user';
  const accountId = 'resilience_account';

  setUp(() async {
    fakeFirestore = FakeFirebaseFirestore();
    repository = TransactionRepository(fakeFirestore);

    await fakeFirestore.collection('accounts').doc(accountId).set({
      'id': accountId,
      'userId': userId,
      'name': 'Resilience Account',
      'currentBalance': 100000, // $1,000.00
      'ledgerVersion': 1,
    });

    await fakeFirestore.collection('users').doc(userId).set({
      'id': userId,
      'ledgerVersion': 1,
    });

    // Setup required category for tests
    await fakeFirestore
        .collection('users')
        .doc(userId)
        .collection('categories')
        .doc('test_cat')
        .set({
      'id': 'test_cat',
      'name': 'Test Category',
      'availableBalance': 1000000,
    });
  });

  group('Failure Simulation & Idempotency', () {
    test('Duplicate Mutation Replay: Should NOT double-apply transaction if same idempotencyKey is used', () async {
      final tx = AppTransaction(
        id: 'tx_original',
        idempotencyKey: 'intent_unique_123',
        userId: userId,
        type: 'expense',
        amount: 10000, // $100.00
        currency: 'USD',
        amountInBaseCurrency: 10000,
        baseCurrency: 'USD',
        date: DateTime.now(),
        accountId: accountId,
        categoryId: 'test_cat',
      );

      // First attempt
      final result1 = await repository.addTransaction(tx);
      expect(result1, TransactionInsertResult.success);

      // Verify balance after first attempt
      final accDoc1 = await fakeFirestore.collection('accounts').doc(accountId).get();
      expect(accDoc1.data()!['currentBalance'], 90000); // 100000 - 10000

      // Second attempt (Replay / Retry)
      final result2 = await repository.addTransaction(tx);
      expect(result2, TransactionInsertResult.duplicate);

      // Verify balance is STILL 90000 (No double deduction!)
      final accDoc2 = await fakeFirestore.collection('accounts').doc(accountId).get();
      expect(accDoc2.data()!['currentBalance'], 90000);
    });

    test('Drift Detection Simulation: Identify when projected balances disagree with ledger sum', () async {
      // 1. Add two legitimate transactions
      final tx1 = AppTransaction(
        id: 'tx_1',
        userId: userId,
        type: 'income',
        amount: 50000,
        currency: 'USD',
        amountInBaseCurrency: 50000,
        accountId: accountId,
        categoryId: 'test_cat',
        date: DateTime.now(),
      );
      final tx2 = AppTransaction(
        id: 'tx_2',
        userId: userId,
        type: 'expense',
        amount: 20000,
        currency: 'USD',
        amountInBaseCurrency: 20000,
        accountId: accountId,
        categoryId: 'test_cat',
        date: DateTime.now(),
      );

      await repository.addTransaction(tx1);
      await repository.addTransaction(tx2);

      // Initial balance was 100000. 100000 + 50000 - 20000 = 130000
      final accDoc = await fakeFirestore.collection('accounts').doc(accountId).get();
      expect(accDoc.data()!['currentBalance'], 130000);

      // 2. SIMULATE CORRUPTION: Directly mutate the projection (Snapshot) without using the ledger
      await fakeFirestore.collection('accounts').doc(accountId).update({
        'currentBalance': 999999, // Intentional drift!
      });

      // 3. RECONCILIATION LOGIC (Simplified): Sum the ledger and compare
      final txs = await fakeFirestore.collection('transactions')
          .where('accountId', isEqualTo: accountId)
          .get();
      
      int ledgerSum = 100000; // Starting balance constant for this test
      for (var doc in txs.docs) {
        final type = doc.data()['type'];
        final amount = doc.data()['amount'];
        if (type == 'income') {
          ledgerSum += amount as int;
        } else {
          ledgerSum -= amount as int;
        }
      }

      final corruptedAcc = await fakeFirestore.collection('accounts').doc(accountId).get();
      final currentBalance = corruptedAcc.data()!['currentBalance'] as int;

      expect(currentBalance, isNot(ledgerSum));
    });
  });
}
