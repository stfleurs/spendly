import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/core/models/category.dart';
import 'package:spendly/features/budget/repository/category_repository.dart';
import 'package:spendly/features/transactions/repository/transaction_repository.dart';
import 'package:spendly/core/providers/date_provider.dart';

class CategoryBudgetItem {
  final Category category;
  final int spentAmount; // in cents

  CategoryBudgetItem({required this.category, required this.spentAmount});

  double get progress => (category.monthlyTarget ?? 0) > 0 
      ? (spentAmount / category.monthlyTarget!).clamp(0.0, 1.0) 
      : 0.0;
}

class BudgetState {
  final List<CategoryBudgetItem> items;

  BudgetState({
    required this.items,
  });
}

final budgetProvider = Provider.family<AsyncValue<BudgetState>, String>((ref, userId) {
  final categoriesAsync = ref.watch(categoriesStreamProvider(userId));
  final transactionsAsync = ref.watch(transactionsStreamProvider(userId));

  if (categoriesAsync is AsyncLoading || transactionsAsync is AsyncLoading) {
    return const AsyncValue.loading();
  }

  if (categoriesAsync is AsyncError) {
    return AsyncValue.error(categoriesAsync.error!, categoriesAsync.stackTrace!);
  }

  if (transactionsAsync is AsyncError) {
    return AsyncValue.error(transactionsAsync.error!, transactionsAsync.stackTrace!);
  }

  final categories = categoriesAsync.value ?? [];
  final transactions = transactionsAsync.value ?? [];

  final now = ref.watch(selectedDateProvider);
  final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
  final startOfWeekDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
  final startOfMonth = DateTime(now.year, now.month, 1);
  final startOfYear = DateTime(now.year, 1, 1);
  
  // Only consider expenses
  final expenseTransactions = transactions.where((t) => t.type.toLowerCase() == 'expense').toList();

  final List<CategoryBudgetItem> items = [];

  for (final category in categories) {
    // Determine the start date for this category's recurrence
    DateTime startDate;
    DateTime endDate;
    switch (category.recurrence.toLowerCase()) {
      case 'weekly':
        startDate = startOfWeekDate;
        endDate = startDate.add(const Duration(days: 7));
        break;
      case 'yearly':
        startDate = startOfYear;
        endDate = DateTime(now.year + 1, 1, 1);
        break;
      case 'monthly':
      default:
        startDate = startOfMonth;
        endDate = DateTime(now.year, now.month + 1, 1);
        break;
    }

    // Filter transactions for this category within the recurrence window
    int spentAmount = 0;
    for (final t in expenseTransactions) {
      if (t.categoryId == category.id && 
          !t.date.isBefore(startDate) && 
          t.date.isBefore(endDate)) {
        spentAmount += t.amount;
      }
    }

    items.add(CategoryBudgetItem(
      category: category,
      spentAmount: spentAmount,
    ));
  }

  return AsyncValue.data(BudgetState(
    items: items,
  ));
});
