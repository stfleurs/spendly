import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:spendly/features/transactions/repository/transaction_repository.dart';
import 'package:spendly/core/models/app_transaction.dart';
import 'package:spendly/core/models/account.dart';
import 'package:spendly/core/models/monthly_summary.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late TransactionRepository repository;
  const userId = 'test_user_123';
  const accountId = 'htg_checking_account';

  setUp(() async {
    fakeFirestore = FakeFirebaseFirestore();
    repository = TransactionRepository(fakeFirestore);

    await fakeFirestore.collection('accounts').doc(accountId).set({
      'id': accountId,
      'userId': userId,
      'name': 'SogeBank HTG',
      'balance': 1000000, // 10,000.00 HTG
      'currentBalance': 1000000,
      'type': 'CHECKING',
      'currency': 'HTG',
      'transactionCount': 0,
      'ledgerVersion': 1,
      'lastTransactionAt': DateTime(2026, 1, 1),
      'lastCalculatedAt': DateTime(2026, 1, 1),
    });

    // 1. Setup User document (required for ledgerVersion update)
    await fakeFirestore.collection('users').doc(userId).set({
      'id': userId,
      'ledgerVersion': 1,
    });

    // 2. Setup Category document (required for expense allocation)
    await fakeFirestore
        .collection('users')
        .doc(userId)
        .collection('categories')
        .doc('food')
        .set({
      'id': 'food',
      'name': 'Food',
      'availableBalance': 500000,
    });

    await fakeFirestore
        .collection('users')
        .doc(userId)
        .collection('categories')
        .doc('salary')
        .set({
      'id': 'salary',
      'name': 'Salary',
      'availableBalance': 0,
    });
  });

  test('Adding an HTG expense should update native balance and USD summary with namespaced metadata', () async {
    const rawAmount = 250000; // 2,500.00 HTG
    const rate = 0.0076; 
    const scale = 1000000;
    final scaledRate = (rate * scale).round();
    final normalizedAmount = (rawAmount * scaledRate) ~/ scale; // 1900 cents
    
    final tx = AppTransaction(
      id: 'tx_123',
      userId: userId,
      type: 'expense',
      amount: rawAmount,
      currency: 'HTG',
      amountInBaseCurrency: normalizedAmount,
      baseCurrency: 'USD',
      exchangeRate: rate,
      scaledRate: scaledRate,
      rateScale: scale,
      rateSource: 'manual',
      rateBaseCurrency: 'USD',
      rateQuoteCurrency: 'HTG',
      date: DateTime(2026, 5, 10),
      accountId: accountId,
      categoryId: 'food',
      note: 'Groceries in HTG',
    );

    final result = await repository.addTransaction(tx);
    expect(result, TransactionInsertResult.success);

    // 1. Verify Account Native Balance
    final accDoc = await fakeFirestore.collection('accounts').doc(accountId).get();
    final account = Account.fromJson({...accDoc.data()!, 'id': accDoc.id});
    expect(account.currentBalance, 750000); 

    // 2. Verify Monthly Summary (USD)
    final summaryDoc = await fakeFirestore
        .collection('users')
        .doc(userId)
        .collection('monthly_summaries')
        .doc('2026_05')
        .get();
    
    final summary = MonthlySummary.fromJson({...summaryDoc.data()!, 'id': summaryDoc.id});
    expect(summary.expenses, normalizedAmount); 
    
    // 3. Verify Rule #5: Namespaced Metadata
    final breakdown = summaryDoc.data()!['currencyBreakdown'] as Map;
    expect(breakdown['expense']['HTG'], rawAmount);
    expect(breakdown['income']?['HTG'], isNull);
  });

  test('Reversing a transaction should revert namespaced metadata correctly', () async {
    const rawAmount = 500000;
    const normalizedAmount = 3800;
    
    final tx = AppTransaction(
      id: 'tx_reversal',
      userId: userId,
      type: 'income',
      amount: rawAmount,
      currency: 'HTG',
      amountInBaseCurrency: normalizedAmount,
      baseCurrency: 'USD',
      exchangeRate: 0.0076,
      scaledRate: 7600,
      rateScale: 1000000,
      rateBaseCurrency: 'USD',
      rateQuoteCurrency: 'HTG',
      date: DateTime(2026, 5, 15),
      accountId: accountId,
      categoryId: 'salary',
    );

    await repository.addTransaction(tx);
    await repository.deleteTransaction(tx);

    final summaryDoc = await fakeFirestore
        .collection('users')
        .doc(userId)
        .collection('monthly_summaries')
        .doc('2026_05')
        .get();
    
    final breakdown = summaryDoc.data()!['currencyBreakdown'] as Map;
    expect(breakdown['income']['HTG'], 0);
  });
}
