import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/features/accounts/repository/account_repository.dart';
import 'package:spendly/features/transactions/repository/transaction_repository.dart';
import 'package:spendly/core/models/app_transaction.dart';

/// Computes the current balance of an account by summing its transactions relative to its initial balance.
final accountBalanceProvider = Provider.family<int, ({String userId, String accountId})>((ref, arg) {
  final accounts = ref.watch(accountsStreamProvider(arg.userId)).value ?? [];
  final transactions = ref.watch(transactionsStreamProvider(arg.userId)).value ?? [];

  final accountMatch = accounts.where((a) => a.id == arg.accountId);
  if (accountMatch.isEmpty) return 0;
  
  final account = accountMatch.first;
  final accountTransactions = transactions.where((t) => t.accountId == arg.accountId);
  
  int balance = account.balance;
  for (final t in accountTransactions) {
    final type = t.type.toLowerCase();
    if (type == 'income') {
      balance += t.amount;
    } else if (type == 'expense') {
      balance -= t.amount;
    }
  }
  return balance;
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
final netWorthTimelineProvider = Provider.family<List<({DateTime date, int balance})>, ({String userId, int days})>((ref, arg) {
  final accounts = ref.watch(accountsStreamProvider(arg.userId)).value ?? [];
  final transactions = ref.watch(transactionsStreamProvider(arg.userId)).value ?? [];
  
  if (accounts.isEmpty) return [];

  // 1. Initial Net Worth (sum of initial balances)
  int runningNetWorth = accounts.fold(0, (sum, acc) => sum + acc.balance);
  
  // 2. Sort ALL transactions by date ASC for cumulative calculation
  final sortedTxs = List<AppTransaction>.from(transactions)..sort((a, b) => a.date.compareTo(b.date));
  
  final now = DateTime.now();
  final startDate = DateTime(now.year, now.month, now.day).subtract(Duration(days: arg.days));
  
  final Map<DateTime, int> dailyCheckpoints = {};
  int currentTotal = runningNetWorth;

  // Single-pass running total calculation
  for (final tx in sortedTxs) {
    final type = tx.type.toLowerCase();
    if (type == 'income') {
      currentTotal += tx.amount;
    } else if (type == 'expense') {
      currentTotal -= tx.amount;
    }
    // Explicitly ignore 'transfer' type for net worth as it's value-neutral
    
    final dateKey = DateTime(tx.date.year, tx.date.month, tx.date.day);
    dailyCheckpoints[dateKey] = currentTotal;
  }

  // 3. Generate the timeline with carry-forward logic
  final List<({DateTime date, int balance})> timeline = [];
  int lastKnownBalance = runningNetWorth;

  // Find the balance at the start of our window
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

/// Aggregates spending by category for a month (Top 5 + "Other").
final spendingInsightsProvider = Provider.family<Map<String, int>, ({String userId, DateTime month})>((ref, arg) {
  final transactions = ref.watch(transactionsStreamProvider(arg.userId)).value ?? [];
  
  final filtered = transactions.where((t) => 
    t.type.toLowerCase() == 'expense' && 
    // Ensure we exclude transfers even if they are categorized as expenses
    t.type.toLowerCase() != 'transfer' &&
    t.date.year == arg.month.year && 
    t.date.month == arg.month.month
  );
  
  final Map<String, int> byCategory = {};
  for (final t in filtered) {
    byCategory[t.categoryId] = (byCategory[t.categoryId] ?? 0) + t.amount;
  }
  
  if (byCategory.isEmpty) return {};
  
  final sortedEntries = byCategory.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
  
  if (sortedEntries.length <= 5) return byCategory;
  
  final top5 = Map.fromEntries(sortedEntries.take(5));
  final otherTotal = sortedEntries.skip(5).fold(0, (sum, entry) => sum + entry.value);
  
  if (otherTotal > 0) {
    top5['other'] = otherTotal;
  }
  
  return top5;
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


