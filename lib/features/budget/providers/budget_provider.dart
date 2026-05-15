import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/core/models/category.dart';
import 'package:spendly/features/budget/repository/category_repository.dart';
import 'package:spendly/core/providers/app_user_provider.dart';

class CategoryBudgetItem {
  final Category category;

  CategoryBudgetItem({required this.category});

  int get availableBalance => category.availableBalance;
}

class BudgetState {
  final List<CategoryBudgetItem> items;
  final int readyToAssign;
  final String baseCurrency;

  BudgetState({
    required this.items,
    required this.readyToAssign,
    required this.baseCurrency,
  });
}

final budgetProvider = Provider.family<AsyncValue<BudgetState>, String>((ref, userId) {
  final categoriesAsync = ref.watch(categoriesStreamProvider(userId));
  final appUserAsync = ref.watch(appUserStreamProvider(userId));

  if (categoriesAsync is AsyncLoading || appUserAsync is AsyncLoading) {
    return const AsyncValue.loading();
  }

  if (categoriesAsync is AsyncError) {
    return AsyncValue.error(categoriesAsync.error!, categoriesAsync.stackTrace!);
  }

  if (appUserAsync is AsyncError) {
    return AsyncValue.error(appUserAsync.error!, appUserAsync.stackTrace!);
  }

  final categories = categoriesAsync.value ?? [];
  final appUser = appUserAsync.value;

  final List<CategoryBudgetItem> items = categories.map((c) => CategoryBudgetItem(category: c)).toList();

  return AsyncValue.data(BudgetState(
    items: items,
    readyToAssign: appUser?.readyToAssign ?? 0,
    baseCurrency: appUser?.baseCurrency ?? 'USD',
  ));
});
