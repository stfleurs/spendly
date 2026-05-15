import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:spendly/features/accounts/repository/account_repository.dart';
import 'package:spendly/core/models/account.dart';
import 'package:spendly/core/models/app_transaction.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late AccountRepository repository;
  const userId = 'test_user_accounts';

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    repository = AccountRepository(fakeFirestore);
  });

  group('AccountRepository Tests', () {
    test('addAccount should initialize currentBalance from balance', () async {
      final account = Account(
        id: '', // Will be generated
        userId: userId,
        name: 'Savings',
        balance: 500000, // $5,000.00
        type: 'SAVINGS',
        currency: 'USD',
      );

      await repository.addAccount(account);

      final snapshot = await fakeFirestore.collection('accounts').get();
      expect(snapshot.docs.length, 1);
      expect(snapshot.docs.first.data()['currentBalance'], 500000);
      expect(snapshot.docs.first.data()['name'], 'Savings');
    });

    test('syncAccountBalance should repair corrupted currentBalance from ledger', () async {
      // 1. Setup account
      final accRef = await fakeFirestore.collection('accounts').add({
        'userId': userId,
        'name': 'Checking',
        'balance': 100000, // Initial $1,000.00
        'currentBalance': 100000,
        'currency': 'USD',
        'type': 'CHECKING',
      });
      final accountId = accRef.id;

      // 2. Add transactions to ledger
      final now = DateTime.now();
      await fakeFirestore.collection('transactions').add({
        'id': 'tx1',
        'userId': userId,
        'accountId': accountId,
        'amount': 50000,
        'type': 'income',
        'date': now,
        'currency': 'USD',
        'categoryId': 'salary',
      });
      await fakeFirestore.collection('transactions').add({
        'id': 'tx2',
        'userId': userId,
        'accountId': accountId,
        'amount': 20000,
        'type': 'expense',
        'date': now,
        'currency': 'USD',
        'categoryId': 'food',
      });

      // 3. SIMULATE CORRUPTION: Set currentBalance to wrong value
      await accRef.update({'currentBalance': 0});

      // 4. RUN SELF-HEALING SYNC
      await repository.syncAccountBalance(userId, accountId);

      // 5. VERIFY: Balance should be 100000 + 50000 - 20000 = 130000
      final repairedDoc = await accRef.get();
      expect(repairedDoc.data()!['currentBalance'], 130000);
      expect(repairedDoc.data()!['lastCalculatedAt'], isNotNull);
    });

    test('deleteAccount should revert impact on monthly summaries', () async {
      final accountId = 'del_acc';
      await fakeFirestore.collection('accounts').doc(accountId).set({
        'userId': userId,
        'name': 'To Delete',
        'balance': 0,
        'currentBalance': 5000,
        'currency': 'USD',
      });

      final now = DateTime(2026, 5, 10);
      final tx = AppTransaction(
        id: 'tx_to_del',
        userId: userId,
        accountId: accountId,
        amount: 5000,
        type: 'income',
        date: now,
        currency: 'USD',
        amountInBaseCurrency: 5000,
        categoryId: 'misc',
      );

      // Create the transaction and summary manually (simulating existing state)
      await fakeFirestore.collection('transactions').doc(tx.id).set(tx.toJson());
      
      final summaryId = '2026_05';
      await fakeFirestore.collection('users').doc(userId).collection('monthly_summaries').doc(summaryId).set({
        'income': 5000,
        'expenses': 0,
        'transactionCount': 1,
      });

      // 1. DELETE ACCOUNT
      final account = Account.fromJson({'id': accountId, 'userId': userId, 'name': 'To Delete', 'balance': 0, 'currency': 'USD', 'type': 'CHECKING'});
      await repository.deleteAccount(account);

      // 2. VERIFY: Account is gone
      final accDoc = await fakeFirestore.collection('accounts').doc(accountId).get();
      expect(accDoc.exists, false);

      // 3. VERIFY: Transaction is gone
      final txDoc = await fakeFirestore.collection('transactions').doc(tx.id).get();
      expect(txDoc.exists, false);

      // 4. VERIFY: Summary is reverted
      final summaryDoc = await fakeFirestore.collection('users').doc(userId).collection('monthly_summaries').doc(summaryId).get();
      expect(summaryDoc.data()!['income'], 0);
      expect(summaryDoc.data()!['transactionCount'], 0);
    });
  });
}
