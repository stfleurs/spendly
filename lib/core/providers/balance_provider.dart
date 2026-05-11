import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/features/accounts/repository/account_repository.dart';
import 'package:spendly/features/transactions/repository/transaction_repository.dart';
import 'package:spendly/core/models/app_transaction.dart';
import 'package:spendly/core/models/monthly_summary.dart';

/// Computes the current balance of an account by summing its transactions relative to its initial balance.
final accountBalanceProvider = Provider.family<int, ({String userId, String accountId})>((ref, arg) {
  final accounts = ref.watch(accountsStreamProvider(arg.userId)).value ?? [];
  
  final accountMatch = accounts.where((a) => a.id == arg.accountId);
  if (accountMatch.isEmpty) return 0;
  
  final account = accountMatch.first;
  
  // Use the pre-calculated snapshot from the Atomic Ledger.
  // Fallback to initial balance if no transactions have been recorded yet.
  return account.currentBalance ?? account.balance;
});

/// Computes the available funds for an account, taking credit limits into account for credit cards.
final availableFundsProvider = Provider.family<int, ({String userId, String accountId})>((ref, arg) {
  final balance = ref.watch(accountBalanceProvider(arg));
  final accounts = ref.watch(accountsStreamProvider(arg.userId)).value ?? [];
  
  final accountMatch = accounts.where((a) => a.id == arg.accountId);
  if (accountMatch.isEmpty) return 0;
  
  final account = accountMatch.first;
  // Use CASE-INSENSITIVE comparison for safety
  if (account.type.toUpperCase() == 'CREDIT CARD') {
    return balance + account.creditLimit;
  }
  return balance;
});

/// Computes the total current net worth across all accounts.
final totalNetWorthProvider = Provider.family<int, String>((ref, userId) {
  final accounts = ref.watch(accountsStreamProvider(userId)).value ?? [];
  int total = 0;
  for (final account in accounts) {
    // Note: Assuming 1:1 for now, normalization to base currency will happen here later
    total += ref.watch(accountBalanceProvider((userId: userId, accountId: account.id)));
  }
  return total;
});

/// Computes a daily cumulative timeline of net worth for a given period.
final netWorthTimelineProvider = FutureProvider.family<List<({DateTime date, int balance})>, ({String userId, int days})>((ref, arg) async {
  // We use the repository directly for a one-time fetch to avoid continuous stream re-computation
  final repo = ref.read(transactionRepositoryProvider);
  final accounts = ref.watch(accountsStreamProvider(arg.userId)).value ?? [];
  
  // For historical data, we still need to fetch transactions, 
  // but we do it as a Future (one-time) and only for the relevant range later.
  // For now, we'll use a one-time get of all transactions to build the baseline.
  final transactions = await repo.getTransactionsPaginated(arg.userId, limit: 1000); // Reasonable cap for trend
  
  if (accounts.isEmpty) return [];

  // 1. Initial Net Worth (sum of initial balances)
  int runningNetWorth = accounts.fold(0, (acc, account) => acc + account.balance);
  
  // 2. Sort ALL transactions by date ASC for cumulative calculation
  final sortedTxs = List<AppTransaction>.from(transactions)..sort((a, b) => a.date.compareTo(b.date));
  
  final now = DateTime.now();
  final startDate = DateTime(now.year, now.month, now.day).subtract(Duration(days: arg.days));
  
  final Map<DateTime, int> dailyCheckpoints = {};
  int currentTotal = runningNetWorth;

  for (final tx in sortedTxs) {
    final type = tx.type.toLowerCase();
    if (type == 'income') {
      currentTotal += tx.amount;
    } else if (type == 'expense') {
      currentTotal -= tx.amount;
    }
    
    final dateKey = DateTime(tx.date.year, tx.date.month, tx.date.day);
    dailyCheckpoints[dateKey] = currentTotal;
  }

  final List<({DateTime date, int balance})> timeline = [];
  int lastKnownBalance = runningNetWorth;

  for (final date in dailyCheckpoints.keys.where((d) => d.isBefore(startDate))) {
     lastKnownBalance = dailyCheckpoints[date]!;
  }

  for (int i = 0; i <= arg.days; i++) {
    final currentDate = startDate.add(Duration(days: i));
    final dateKey = DateTime(currentDate.year, currentDate.month, currentDate.day);
    
    if (dailyCheckpoints.containsKey(dateKey)) {
      lastKnownBalance = dailyCheckpoints[dateKey]!;
    }
    
    timeline.add((date: dateKey, balance: lastKnownBalance));
  }
  
  return timeline;
});

/// Fetches the pre-aggregated summary for a specific month.
final monthlySummaryProvider = StreamProvider.family<MonthlySummary?, ({String userId, DateTime month})>((ref, arg) {
  final monthId = "${arg.month.year}_${arg.month.month.toString().padLeft(2, '0')}";
  return FirebaseFirestore.instance
      .collection('users')
      .doc(arg.userId)
      .collection('monthly_summaries')
      .doc(monthId)
      .snapshots()
      .map((doc) => doc.exists ? MonthlySummary.fromJson({...doc.data()!, 'id': doc.id}) : null);
});

/// Aggregates spending by category for a month (Top 5 + "Other").
final spendingInsightsProvider = Provider.family<Map<String, int>, ({String userId, DateTime month})>((ref, arg) {
  final summaryAsync = ref.watch(monthlySummaryProvider(arg));
  
  return summaryAsync.maybeWhen(
    data: (summary) {
      if (summary == null || summary.categoryTotals.isEmpty) return {};
      
      // categoryTotals already contains net change (negative for expenses)
      // We want absolute values for the "Spending" pie chart/insights
      final Map<String, int> byCategory = {};
      summary.categoryTotals.forEach((catId, total) {
        if (total < 0) {
          byCategory[catId] = total.abs();
        }
      });
      
      if (byCategory.isEmpty) return {};
      
      final sortedEntries = byCategory.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      
      if (sortedEntries.length <= 5) return byCategory;
      
      final top5 = Map.fromEntries(sortedEntries.take(5));
      final otherTotal = sortedEntries.skip(5).fold(0, (acc, entry) => acc + entry.value);
      
      if (otherTotal > 0) {
        top5['other'] = otherTotal;
      }
      
      return top5;
    },
    orElse: () => {},
  );
});

/// Computes aggregate credit utilization across all credit card accounts.
final creditUtilizationProvider = Provider.family<double, String>((ref, userId) {
  final accounts = ref.watch(accountsStreamProvider(userId)).value ?? [];
  int totalLimit = 0;
  int totalUsed = 0;

  for (final acc in accounts) {
    if (acc.type.toUpperCase() == 'CREDIT CARD') {
      totalLimit += acc.creditLimit;
      
      final balance = ref.watch(accountBalanceProvider((userId: userId, accountId: acc.id)));
      // If balance is negative, it means money is owed/spent
      if (balance < 0) {
        totalUsed += balance.abs();
      }
    }
  }

  if (totalLimit <= 0) return 0.0;
  return totalUsed / totalLimit;
});


