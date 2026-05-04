import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/shared/widgets/app_header.dart';
import 'package:spendly/shared/widgets/main_card.dart';
import 'package:spendly/shared/themes/app_theme.dart';
import 'package:spendly/features/budget/providers/budget_provider.dart';
import 'package:spendly/features/budget/view/category_form_bottom_sheet.dart';
import 'package:spendly/core/providers/firebase_providers.dart';
import 'package:spendly/core/models/category.dart';
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
                  return MainCard(
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
                            padding: EdgeInsets.all(32.0),
                            child: Center(
                              child: Text(
                                'No categories yet. Tap the button below to create your first budget category!',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppColors.textLight, height: 1.5),
                              ),
                            ),
                          ),
                        ...state.items.map((item) => _buildBudgetItem(context, item)),
                        
                        // Add Category Button
                        InkWell(
                          onTap: () => _showCategoryForm(context, null),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: const BoxDecoration(
                              border: Border(top: BorderSide(color: AppColors.primaryLight, width: 1)),
                            ),
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
                      ],
                    ),
                  );
                },
                loading: () => const MainCard(child: Center(child: CircularProgressIndicator())),
                error: (e, s) => MainCard(child: Center(child: Text('Error: $e'))),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }

  void _showCategoryForm(BuildContext context, Category? category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CategoryFormBottomSheet(category: category),
    );
  }

  Widget _buildBudgetItem(BuildContext context, CategoryBudgetItem item) {
    final l10n = AppLocalizations.of(context)!;
    final category = item.category;
    
    String currencySymbol = '\$';
    if (category.currency == 'HTG') currencySymbol = 'G';
    if (category.currency == 'EUR') currencySymbol = '€';
    
    final spentStr = '$currencySymbol${(item.spentAmount / 100).toStringAsFixed(2)}';
    
    String assignedStr = 'No limit';
    int leftToSpend = 0;
    bool hasTarget = category.monthlyTarget != null && category.monthlyTarget! > 0;
    bool isOverspent = false;

    if (hasTarget) {
      assignedStr = '$currencySymbol${(category.monthlyTarget! / 100).toStringAsFixed(2)}';
      leftToSpend = category.monthlyTarget! - item.spentAmount;
      if (leftToSpend < 0) isOverspent = true;
    }
    
    final pillText = hasTarget 
        ? '$currencySymbol${(leftToSpend.abs() / 100).toStringAsFixed(2)}'
        : spentStr;
    
    final pillColor = hasTarget 
        ? (isOverspent ? const Color(0xFFFFE5E5) : const Color(0xFFD4F7E2)) 
        : const Color(0xFFE2E8F0); // Neutral color if no target
    final pillTextColor = hasTarget 
        ? (isOverspent ? AppColors.expense : AppColors.income) 
        : AppColors.textDark;

    return InkWell(
      onTap: () => _showCategoryForm(context, category),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Name, Overspent Badge, Pill
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
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
                      if (isOverspent) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2E5FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            l10n.overspent,
                            style: const TextStyle(
                              color: Color(0xFF5A67D8),
                              fontWeight: FontWeight.w900,
                              fontSize: 9,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: pillColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    pillText,
                    style: TextStyle(
                      color: pillTextColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Row 2: Assigned & Spent
            Row(
              children: [
                Text(
                  '${l10n.assigned.toUpperCase()}: $assignedStr',
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${l10n.spent.toUpperCase()}: $spentStr',
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),

            // Row 3: Progress Bar
            if (hasTarget) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: item.progress,
                  backgroundColor: AppColors.primaryLight,
                  color: isOverspent ? AppColors.expense : const Color(0xFFF6C022),
                  minHeight: 8,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
