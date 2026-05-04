import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/shared/widgets/app_header.dart';
import 'package:spendly/shared/widgets/main_card.dart';
import 'package:spendly/shared/themes/app_theme.dart';
import 'package:spendly/core/providers/firebase_providers.dart';
import 'package:spendly/core/providers/date_provider.dart';
import 'package:spendly/features/transactions/repository/transaction_repository.dart';
import 'package:spendly/features/budget/repository/category_repository.dart';
import 'package:spendly/core/models/category.dart';
import 'package:spendly/generated/l10n/app_localizations.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(authStateProvider).value?.uid ?? '';
    final selectedDate = ref.watch(selectedDateProvider);
    final transactionsAsync = ref.watch(transactionsStreamProvider(userId));
    final categoriesAsync = ref.watch(categoriesStreamProvider(userId));

    final l10n = AppLocalizations.of(context)!;

    return CustomScrollView(
      slivers: [
        SliverAppHeader(title: l10n.reports),
        SliverToBoxAdapter(
          child: transactionsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, s) => Padding(
              padding: const EdgeInsets.all(24),
              child: Center(child: Text('Error: $e')),
            ),
            data: (allTransactions) {
              // Filter to selected month
              final transactions = allTransactions.where((t) {
                return t.date.year == selectedDate.year &&
                    t.date.month == selectedDate.month;
              }).toList();

              // Calculate totals
              int totalIncome = 0;
              int totalExpense = 0;
              final Map<String, int> spentByCategory = {};

              for (final t in transactions) {
                if (t.type.toLowerCase() == 'income') {
                  totalIncome += t.amount;
                } else if (t.type.toLowerCase() == 'expense') {
                  totalExpense += t.amount;
                  spentByCategory[t.categoryId] =
                      (spentByCategory[t.categoryId] ?? 0) + t.amount;
                }
              }

              final net = totalIncome - totalExpense;
              final maxSpend = spentByCategory.values.fold(0, (a, b) => a > b ? a : b);

              return Column(
                children: [
                  const SizedBox(height: 24),

                  // Summary Card
                  MainCard(
                    child: Column(
                      children: [
                        _buildSummaryItem(l10n.income, totalIncome, AppColors.income, Icons.trending_up),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Divider(color: AppColors.primaryLight, height: 1),
                        ),
                        _buildSummaryItem(l10n.expense, totalExpense, AppColors.expense, Icons.trending_down),
                        const SizedBox(height: 32),

                        // Net Amount Box
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          decoration: BoxDecoration(
                            color: net >= 0 ? const Color(0xFFD4F7E2) : const Color(0xFFFFE5E5),
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: Column(
                            children: [
                              Text(
                                l10n.net,
                                style: const TextStyle(
                                  color: AppColors.textDark,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 11,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${net < 0 ? '-' : ''}\$${(net.abs() / 100).toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: net >= 0 ? AppColors.income : AppColors.expense,
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Spending by Category Card
                  if (spentByCategory.isNotEmpty)
                    categoriesAsync.when(
                      loading: () => const MainCard(child: Center(child: CircularProgressIndicator())),
                      error: (e, s) => const SizedBox.shrink(),
                      data: (categories) {
                        final Map<String, Category> catMap = {
                          for (final c in categories) c.id: c
                        };

                        // Sort by most spent descending
                        final sortedEntries = spentByCategory.entries.toList()
                          ..sort((a, b) => b.value.compareTo(a.value));

                        return MainCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.spendingByCategory,
                                style: const TextStyle(
                                  color: AppColors.textLight,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 11,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 24),
                              ...sortedEntries.map((entry) {
                                final cat = catMap[entry.key];
                                final name = cat?.name ?? 'Unknown';
                                final progress = maxSpend > 0 ? entry.value / maxSpend : 0.0;
                                final amountStr = '\$${(entry.value / 100).toStringAsFixed(2)}';
                                return _buildCategoryItem(name, amountStr, progress);
                              }),
                            ],
                          ),
                        );
                      },
                    ),

                  // No transactions state
                  if (transactions.isEmpty)
                    MainCard(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.bar_chart_outlined, color: AppColors.textLight, size: 48),
                              const SizedBox(height: 16),
                              Text(
                                l10n.noTransactionsMonth,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: AppColors.textLight, height: 1.5),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 40),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(String label, int amountCents, Color color, IconData icon) {
    final formatted = '\$${(amountCents / 100).toStringAsFixed(2)}';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textLight,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              formatted,
              style: TextStyle(
                color: color,
                fontSize: 32,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        Icon(icon, color: color, size: 32),
      ],
    );
  }

  Widget _buildCategoryItem(String label, String amount, double progress) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                amount,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.primaryLight,
              color: AppColors.primary,
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }
}
