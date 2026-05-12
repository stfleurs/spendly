import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/core/providers/balance_provider.dart';

/// Computes the average spending for a given category over the last 3 months.
final realityBudgetSuggestionProvider = FutureProvider.family<int, ({String userId, String categoryId})>((ref, arg) async {
  final now = DateTime.now();
  int totalSpend = 0;
  int monthsWithData = 0;

  // We look back at the previous 3 completed months
  for (int i = 1; i <= 3; i++) {
    final targetMonth = DateTime(now.year, now.month - i);
    // Use the stream provider to get the latest snapshot
    final summaryAsync = ref.read(monthlySummaryProvider((userId: arg.userId, month: targetMonth)));
    
    // We may need to wait for it if it's not loaded, but since it's a stream, we can read the future
    // Actually, ref.read on a StreamProvider gives the AsyncValue. If it's not ready, it might be loading.
    // Let's use a FutureProvider approach or just await the stream's first value.
    try {
      final summary = await ref.read(monthlySummaryProvider((userId: arg.userId, month: targetMonth)).future);
      if (summary != null) {
        final categoryTotal = summary.categoryTotals[arg.categoryId] ?? 0;
        // Expenses are stored as negative numbers in categoryTotals
        if (categoryTotal < 0) {
          totalSpend += categoryTotal.abs();
          monthsWithData++;
        }
      }
    } catch (e) {
      // Ignore if no data for that month
    }
  }

  if (monthsWithData == 0) return 0;
  return (totalSpend / monthsWithData).round();
});

class MonthlyComparison {
  final int currentMonthSpend;
  final int lastMonthSpend;
  final double percentageChange; // Positive means spent more, negative means spent less
  final String trendMessage;

  MonthlyComparison({
    required this.currentMonthSpend,
    required this.lastMonthSpend,
    required this.percentageChange,
    required this.trendMessage,
  });
}

/// Compares the current month's spending to last month's spending for a given category.
final monthlyComparisonProvider = FutureProvider.family<MonthlyComparison?, ({String userId, String categoryId, String categoryName})>((ref, arg) async {
  final now = DateTime.now();
  final lastMonthDate = DateTime(now.year, now.month - 1);

  try {
    final currentSummary = await ref.read(monthlySummaryProvider((userId: arg.userId, month: now)).future);
    final lastMonthSummary = await ref.read(monthlySummaryProvider((userId: arg.userId, month: lastMonthDate)).future);

    final currentTotal = (currentSummary?.categoryTotals[arg.categoryId] ?? 0) < 0 
        ? (currentSummary?.categoryTotals[arg.categoryId] ?? 0).abs() 
        : 0;
        
    final lastTotal = (lastMonthSummary?.categoryTotals[arg.categoryId] ?? 0) < 0 
        ? (lastMonthSummary?.categoryTotals[arg.categoryId] ?? 0).abs() 
        : 0;

    if (lastTotal == 0 && currentTotal == 0) {
      return null;
    }

    if (lastTotal == 0) {
      return MonthlyComparison(
        currentMonthSpend: currentTotal,
        lastMonthSpend: 0,
        percentageChange: 100.0,
        trendMessage: 'New spending this month.',
      );
    }

    final change = ((currentTotal - lastTotal) / lastTotal) * 100;
    
    String message = '';
    if (change > 20) {
      message = '${arg.categoryName} spending is ${change.toStringAsFixed(0)}% higher this month.';
    } else if (change > 5) {
      message = 'Trending slightly above average.';
    } else if (change < -20) {
      message = 'Great job! Spending is ${change.abs().toStringAsFixed(0)}% lower.';
    } else if (change < -5) {
      message = 'Trending slightly below average.';
    } else {
      message = 'On track with last month.';
    }

    return MonthlyComparison(
      currentMonthSpend: currentTotal,
      lastMonthSpend: lastTotal,
      percentageChange: change,
      trendMessage: message,
    );
  } catch (e) {
    return null;
  }
});
