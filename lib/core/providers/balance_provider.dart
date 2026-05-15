import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/features/accounts/repository/account_repository.dart';
import 'package:spendly/core/models/monthly_summary.dart';
import 'package:spendly/core/providers/app_user_provider.dart';
import 'package:spendly/core/providers/exchange_rate_provider.dart';
import 'package:spendly/core/providers/financial_summary_provider.dart';

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
/// Optimistically uses the FinancialSummary snapshot, with fallback to manual calculation if unavailable.
final totalNetWorthProvider = Provider.family<int, String>((ref, userId) {
  final summaryAsync = ref.watch(financialSummaryProvider(userId));
  
  return summaryAsync.when(
    data: (summary) {
      if (summary != null && summary.reconciled) {
        return summary.netWorth;
      }
      
      // Fallback: Manual calculation if summary is missing or unreconciled
      final accounts = ref.watch(accountsStreamProvider(userId)).value ?? [];
      final user = ref.watch(appUserStreamProvider(userId)).value;
      if (user == null) return 0;
      
      final baseCurrency = user.baseCurrency;
      int total = 0;
      for (final account in accounts) {
        final balance = ref.watch(accountBalanceProvider((userId: userId, accountId: account.id)));
        
        if (account.currency == baseCurrency) {
          total += balance;
        } else {
          final rate = ref.watch(exchangeRateProvider((userId: userId, from: account.currency, to: baseCurrency)));
          total += (balance * rate).round();
        }
      }
      return total;
    },
    loading: () => 0,
    error: (_, _) => 0,
  );
});

/// Computes a daily cumulative timeline of net worth for a given period.
/// Preferentially uses daily snapshots for O(1) rendering.
final netWorthTimelineProvider = StreamProvider.family<List<({DateTime date, int balance})>, ({String userId, int days})>((ref, arg) {
  final dailyAsync = ref.watch(dailyNetWorthProvider(arg));
  
  return dailyAsync.when(
    data: (snapshots) => Stream.value(snapshots
        .map((s) => (date: s.date, balance: s.netWorth))
        .toList()
        .reversed
        .toList()),
    loading: () => const Stream.empty(),
    error: (e, st) => Stream.error(e, st),
  );
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


