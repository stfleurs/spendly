import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/shared/widgets/app_header.dart';
import 'package:spendly/shared/widgets/main_card.dart';
import 'package:spendly/shared/themes/app_theme.dart';
import 'package:spendly/features/budget/providers/budget_provider.dart';
import 'package:spendly/features/budget/view/category_form_bottom_sheet.dart';
import 'package:spendly/core/providers/firebase_providers.dart';
import 'package:spendly/features/home/providers/insights_provider.dart';
import 'package:spendly/generated/l10n/app_localizations.dart';

class MyBudgetScreen extends ConsumerWidget {
  const MyBudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(authStateProvider).value?.uid ?? '';
    final budgetAsync = ref.watch(budgetProvider(userId));

    final l10n = AppLocalizations.of(context)!;

    return CustomScrollView(
      slivers: [
        SliverAppHeader(title: l10n.myBudget),
        SliverToBoxAdapter(
          child: Column(
            children: [
              const SizedBox(height: 24),
              
              // Category Budgets
              budgetAsync.when(
                data: (state) {
                  return Column(
                    children: [
                      MainCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 24, top: 24, right: 24, bottom: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    l10n.spendingByCategory,
                                    style: const TextStyle(
                                      color: AppColors.textLight,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 12,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  Text(
                                    '${state.items.length} ACTIVE',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 10,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (state.items.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(40.0),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Icon(Icons.pie_chart_outline, color: AppColors.primaryLight, size: 48),
                                      SizedBox(height: 16),
                                      Text(
                                        'No budget categories yet.\nTap below to set up your first one!',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: AppColors.textLight, height: 1.5, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ...state.items.map((item) => _CategoryBudgetItemWidget(item: item, userId: userId)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Permanent Add Category Button
                      _buildAddCategoryButton(context),
                    ],
                  );
                },
                loading: () => Column(
                  children: [
                    const MainCard(child: Center(child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(),
                    ))),
                    const SizedBox(height: 16),
                    _buildAddCategoryButton(context),
                  ],
                ),
                error: (e, s) => Column(
                  children: [
                    MainCard(child: Center(child: Text('Error: $e'))),
                    const SizedBox(height: 16),
                    _buildAddCategoryButton(context),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddCategoryButton(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return MainCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => const CategoryFormBottomSheet(category: null),
        ),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_circle_outline, color: AppColors.primary),
              const SizedBox(width: 12),
              Text(
                l10n.category.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryBudgetItemWidget extends ConsumerWidget {
  final CategoryBudgetItem item;
  final String userId;

  const _CategoryBudgetItemWidget({
    required this.item,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final category = item.category;

    String currencySymbol = '\$';
    if (category.currency == 'HTG') currencySymbol = 'G';
    if (category.currency == 'EUR') currencySymbol = '€';

    final spentStr = '$currencySymbol${(item.spentAmount / 100).toStringAsFixed(2)}';

    String assignedStr = 'No limit';
    bool hasTarget = category.monthlyTarget != null && category.monthlyTarget! > 0;
    bool isTrendingHigh = false;

    if (hasTarget) {
      assignedStr = '$currencySymbol${(category.monthlyTarget! / 100).toStringAsFixed(2)}';
    }

    final comparisonAsync = ref.watch(monthlyComparisonProvider((
      userId: userId,
      categoryId: category.id,
      categoryName: category.name,
    )));

    return InkWell(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => CategoryFormBottomSheet(category: category),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Name & Spent
            Row(
              children: [
                Expanded(
                  child: Text(
                    category.name,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  spentStr,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Row 2: Target & Trend
            comparisonAsync.when(
              data: (comparison) {
                if (comparison == null) {
                  return Text(
                    hasTarget ? '${l10n.assigned}: $assignedStr' : 'No set target',
                    style: const TextStyle(
                      color: AppColors.textLight,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }

                isTrendingHigh = comparison.percentageChange > 10;
                final trendColor = isTrendingHigh ? const Color(0xFFECA00A) : AppColors.primary;

                return Row(
                  children: [
                    if (hasTarget) ...[
                      Text(
                        '${l10n.assigned}: $assignedStr',
                        style: const TextStyle(
                          color: AppColors.textLight,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Text(
                        comparison.trendMessage,
                        style: TextStyle(
                          color: trendColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Text('Loading trends...', style: TextStyle(color: AppColors.textLight, fontSize: 12)),
              error: (e, s) => const SizedBox.shrink(),
            ),

            // Row 3: Soft Progress Bar
            if (hasTarget) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: item.progress > 1.0 ? 1.0 : item.progress,
                  backgroundColor: AppColors.primaryLight.withValues(alpha: 0.3),
                  color: isTrendingHigh ? const Color(0xFFECA00A) : AppColors.primary,
                  minHeight: 6,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
