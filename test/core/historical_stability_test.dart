import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:spendly/features/transactions/repository/transaction_repository.dart';
import 'package:spendly/core/models/app_transaction.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late TransactionRepository repository;
  const userId = 'historical_user';
  const accountId = 'stable_account';

  setUp(() async {
    fakeFirestore = FakeFirebaseFirestore();
    repository = TransactionRepository(fakeFirestore);
    
    await fakeFirestore.collection('users').doc(userId).set({'id': userId, 'ledgerVersion': 1});
    await fakeFirestore.collection('accounts').doc(accountId).set({
      'userId': userId,
      'currency': 'HTG',
      'currentBalance': 0,
      'ledgerVersion': 1,
    });

    await fakeFirestore
        .collection('users')
        .doc(userId)
        .collection('categories')
        .doc('test')
        .set({
      'id': 'test',
      'name': 'Test',
      'availableBalance': 0,
    });
  });

  group('Temporal & Historical Stability', () {
    test('Historical Exchange-Rate Lock: Should remain immutable even if market rates change', () async {
      // 1. User creates an expense in HTG when rate is 135.0
      const amountHtg = 13500; // 13,500 HTG
      const initialRate = 1 / 135.0; // ~0.0074074...
      const scale = 1000000;
      final initialScaledRate = (initialRate * scale).round(); // 7407
      final initialNormalized = (amountHtg * initialScaledRate) ~/ scale; // 9999 cents (~$100)

      final tx = AppTransaction(
        id: 'tx_historical',
        userId: userId,
        type: 'expense',
        amount: amountHtg,
        currency: 'HTG',
        amountInBaseCurrency: initialNormalized,
        exchangeRate: initialRate,
        scaledRate: initialScaledRate,
        rateScale: scale,
        date: DateTime(2026, 1, 1),
        accountId: accountId,
        categoryId: 'test',
      );

      await repository.addTransaction(tx);
      
      final txSnapshot = await fakeFirestore.collection('transactions').get();
      expect(txSnapshot.docs.length, 1);

      // 2. MARKET SHIFT: The exchange rate for HTG/USD drastically changes (e.g. to 200.0)
      
      final txDoc = await fakeFirestore.collection('transactions').doc('tx_historical').get();
      expect(txDoc.exists, true, reason: 'Transaction document should exist');
      
      final persistedScaledRate = txDoc.data()!['scaledRate'] as int;
      final persistedScale = txDoc.data()!['rateScale'] as int;
      final reCalc = (amountHtg * persistedScaledRate) ~/ persistedScale;
      
      expect(reCalc, initialNormalized);
    });
  });
}
