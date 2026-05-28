import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:spendly/shared/widgets/app_header.dart';
import 'package:spendly/shared/widgets/main_card.dart';
import 'package:spendly/shared/themes/app_theme.dart';
import 'package:spendly/core/providers/firebase_providers.dart';
import 'package:spendly/core/providers/date_provider.dart';
import 'package:spendly/features/transactions/repository/transaction_repository.dart';
import 'package:spendly/features/budget/repository/category_repository.dart';
import 'package:spendly/core/models/category.dart' as model;
import 'package:spendly/generated/l10n/app_localizations.dart';
import 'package:spendly/core/utils/currency_formatter.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(authStateProvider).value?.uid ?? '';
    final selectedDate = ref.watch(selectedDateProvider);
    final transactionsAsync = ref.watch(transactionsByMonthProvider((userId: userId, month: selectedDate)));
    final categoriesAsync = ref.watch(categoriesStreamProvider(userId));

    final l10n = AppLocalizations.of(context)!;
    final locale = l10n.localeName;

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
            data: (transactions) {

              // Calculate totals
              int totalIncome = 0;
              int totalExpense = 0;
              final Map<String, int> spentByCategory = {};

              for (final t in transactions) {
                if (t.type.toLowerCase() == 'income') {
                  totalIncome += t.amount;
                } else if (t.type.toLowerCase() == 'expense' && t.type.toLowerCase() != 'transfer') {
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
                        _buildSummaryItem(l10n.income, totalIncome, AppColors.income, Icons.trending_up, locale),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Divider(color: AppColors.primaryLight, height: 1),
                        ),
                        _buildSummaryItem(l10n.expense, totalExpense, AppColors.expense, Icons.trending_down, locale),
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
                                formatCents(net, 'USD', showSign: true, locale: locale),
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

                  // Spending Breakdown (Pie Chart)
                  if (spentByCategory.isNotEmpty)
                    MainCard(
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
                          const SizedBox(height: 32),
                          SizedBox(
                            height: 200,
                            child: _buildPieChart(spentByCategory, categoriesAsync),
                          ),
                          const SizedBox(height: 32),
                          // Legend
                          _buildLegend(spentByCategory, categoriesAsync),
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
                        final Map<String, model.Category> catMap = {
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
                                final amountStr = formatCents(entry.value, 'USD', locale: locale);
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

  Widget _buildPieChart(Map<String, int> spentByCategory, AsyncValue<List<model.Category>> categoriesAsync) {
    return categoriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => const SizedBox.shrink(),
      data: (categories) {
        final Map<String, model.Category> catMap = {for (final c in categories) c.id: c};
        final sortedEntries = spentByCategory.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

        final List<Color> sectionColors = [
          AppColors.primary,
          const Color(0xFFF6C022),
          const Color(0xFF4FD1C5),
          const Color(0xFF63B3ED),
          const Color(0xFFB794F4),
          const Color(0xFFCBD5E0),
        ];

        return PieChart(
          PieChartData(
            sectionsSpace: 4,
            centerSpaceRadius: 40,
            sections: sortedEntries.asMap().entries.map((entry) {
              final index = entry.key;
              final categoryId = entry.value.key;
              final amount = entry.value.value;
              final cat = catMap[categoryId];

              return PieChartSectionData(
                color: sectionColors[index % sectionColors.length],
                value: amount.toDouble(),
                title: '', // Hide title on segments
                radius: 60,
                badgeWidget: index < 5 ? _buildPieBadge(cat?.name ?? '?') : null,
                badgePositionPercentageOffset: 1.3,
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildLegend(Map<String, int> spentByCategory, AsyncValue<List<model.Category>> categoriesAsync) {
    return categoriesAsync.maybeWhen(
      data: (categories) {
        final Map<String, model.Category> catMap = {for (final c in categories) c.id: c};
        final sortedEntries = spentByCategory.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

        final List<Color> sectionColors = [
          AppColors.primary,
          const Color(0xFFF6C022),
          const Color(0xFF4FD1C5),
          const Color(0xFF63B3ED),
          const Color(0xFFB794F4),
          const Color(0xFFCBD5E0),
        ];

        return Wrap(
          spacing: 16,
          runSpacing: 12,
          children: sortedEntries.asMap().entries.map((entry) {
            final index = entry.key;
            final cat = catMap[entry.value.key];
            final color = sectionColors[index % sectionColors.length];

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text(
                  cat?.name ?? '?',
                  style: const TextStyle(fontSize: 12, color: AppColors.textDark, fontWeight: FontWeight.bold),
                ),
              ],
            );
          }).toList(),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _buildPieBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textDark,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, int amountCents, Color color, IconData icon, String locale) {
    final formatted = formatCents(amountCents, 'USD', locale: locale);
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
