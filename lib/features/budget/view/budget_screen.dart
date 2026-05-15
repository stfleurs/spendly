import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/shared/widgets/app_header.dart';
import 'package:spendly/shared/widgets/main_card.dart';
import 'package:spendly/shared/themes/app_theme.dart';
import 'package:spendly/features/budget/providers/budget_provider.dart';
import 'package:spendly/features/budget/view/category_form_bottom_sheet.dart';
import 'package:spendly/features/budget/view/allocation_bottom_sheet.dart';
import 'package:spendly/core/providers/firebase_providers.dart';
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
              
              budgetAsync.when(
                data: (state) {
                  return Column(
                    children: [
                      // Ready To Assign Banner
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              )
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'READY TO ASSIGN',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _formatCurrency(state.readyToAssign, state.baseCurrency),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 36,
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: 140,
                                child: ElevatedButton(
                                  onPressed: () => showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (context) => const AllocationBottomSheet(),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: const Text('ASSIGN', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Envelope List
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
                                  const Text(
                                    'ENVELOPES',
                                    style: TextStyle(
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
                                      Icon(Icons.account_balance_wallet_outlined, color: AppColors.primaryLight, size: 48),
                                      SizedBox(height: 16),
                                      Text(
                                        'No envelopes yet.\nTap below to set up your first one!',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: AppColors.textLight, height: 1.5, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ...state.items.map((item) => _CategoryBudgetItemWidget(item: item, baseCurrency: state.baseCurrency)),
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

  String _formatCurrency(int amountInCents, String currencyCode) {
    String symbol = '\$';
    if (currencyCode == 'HTG') symbol = 'G';
    if (currencyCode == 'EUR') symbol = '€';
    
    final isNegative = amountInCents < 0;
    final absAmount = amountInCents.abs() / 100;
    final formatted = absAmount.toStringAsFixed(2);
    
    if (currencyCode == 'HTG') return '${isNegative ? '-' : ''}$formatted $symbol';
    if (isNegative) return '-$symbol$formatted';
    return '$symbol$formatted';
  }

  Widget _buildAddCategoryButton(BuildContext context) {
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
              const Text(
                'NEW ENVELOPE',
                style: TextStyle(
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

class _CategoryBudgetItemWidget extends StatelessWidget {
  final CategoryBudgetItem item;
  final String baseCurrency;

  const _CategoryBudgetItemWidget({
    required this.item,
    required this.baseCurrency,
  });

  String _formatCurrency(int amountInCents) {
    String symbol = '\$';
    if (baseCurrency == 'HTG') symbol = 'G';
    if (baseCurrency == 'EUR') symbol = '€';
    
    final isNegative = amountInCents < 0;
    final absAmount = amountInCents.abs() / 100;
    final formatted = absAmount.toStringAsFixed(2);
    
    if (baseCurrency == 'HTG') return '${isNegative ? '-' : ''}$formatted $symbol';
    if (isNegative) return '-$symbol$formatted';
    return '$symbol$formatted';
  }

  @override
  Widget build(BuildContext context) {
    final category = item.category;
    final available = item.availableBalance;
    final isNegative = available < 0;
    
    final amountColor = isNegative ? Colors.red.shade400 : AppColors.textDark;
    final amountStr = _formatCurrency(available);

    return InkWell(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => AllocationBottomSheet(initialTarget: category),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                      IconButton(
                        icon: const Icon(Icons.settings_outlined, size: 16, color: AppColors.textLight),
                        onPressed: () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => CategoryFormBottomSheet(category: category),
                        ),
                      ),
                    ],
                  ),
                  if (category.monthlyTarget != null && category.monthlyTarget! > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Goal: ${_formatCurrency(category.monthlyTarget!)}',
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ]
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amountStr,
                  style: TextStyle(
                    color: amountColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                Text(
                  isNegative ? 'overspent' : 'available',
                  style: TextStyle(
                    color: isNegative ? Colors.red.shade300 : AppColors.textLight,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
