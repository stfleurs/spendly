import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:spendly/shared/widgets/app_header.dart';
import 'package:spendly/shared/widgets/main_card.dart';
import 'package:spendly/shared/themes/app_theme.dart';
import 'package:spendly/core/providers/firebase_providers.dart';
import 'package:spendly/core/providers/balance_provider.dart';
import 'package:spendly/features/transactions/repository/transaction_repository.dart';
import 'package:spendly/features/upcoming/providers/upcoming_provider.dart';
import 'package:spendly/features/upcoming/view/upcoming_screen.dart';
import 'package:spendly/core/providers/date_provider.dart';
import 'package:spendly/core/providers/app_user_provider.dart';
import 'package:spendly/features/budget/view/allocation_bottom_sheet.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(authStateProvider).value?.uid ?? '';
    final selectedDate = ref.watch(selectedDateProvider);
    final monthlySummaryAsync = ref.watch(monthlySummaryProvider((userId: userId, month: selectedDate)));
    final transactionsAsync = ref.watch(transactionsStreamProvider(userId));
    final appUserAsync = ref.watch(appUserStreamProvider(userId));

    return CustomScrollView(
      slivers: [
        const SliverAppHeader(title: 'Household Overview'),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Ready To Assign (New) ──────────────────────────
                appUserAsync.when(
                  data: (user) {
                    final amount = user?.readyToAssign ?? 0;
                    if (amount == 0) return const SizedBox.shrink();
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, color: Colors.white70, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'READY TO ASSIGN',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 10,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  Text(
                                    user?.baseCurrency == 'HTG' 
                                        ? '${(amount / 100).toStringAsFixed(2)} G' 
                                        : '\$${(amount / 100).toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 24,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) => const AllocationBottomSheet(),
                                );
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.white.withValues(alpha: 0.2),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text(
                                'ASSIGN',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (e, s) => const SizedBox.shrink(),
                ),
                // ── Top Area: Current Month Snapshot ──────────────────────
                monthlySummaryAsync.when(
                  data: (summary) {
                    final spent = (summary?.expenses ?? 0).abs();
                    final income = summary?.income ?? 0;
                    
                    return MainCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'THIS MONTH',
                            style: TextStyle(
                              color: AppColors.textLight,
                              fontWeight: FontWeight.w900,
                              fontSize: 11,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _formatCurrency(spent, appUserAsync.value?.baseCurrency ?? 'USD', decimal: 0),
                                style: const TextStyle(
                                  color: AppColors.textDark,
                                  fontSize: 42,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(bottom: 8.0, left: 8.0),
                                child: Text(
                                  'spent',
                                  style: TextStyle(
                                    color: AppColors.textLight,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildMiniStat('INCOME', _formatCurrency(income, appUserAsync.value?.baseCurrency ?? 'USD', decimal: 0), AppColors.income),
                              _buildMiniStat('SAVINGS EST.', _formatCurrency(income - spent, appUserAsync.value?.baseCurrency ?? 'USD', decimal: 0), AppColors.primary),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => const SizedBox.shrink(),
                ),

                const SizedBox(height: 24),
                _buildUpcomingCard(context, ref, userId),

                const SizedBox(height: 32),

                // ── Middle Area: Insights & Breakdown ─────────────────────────
                const Text(
                  'MONTHLY INSIGHTS',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Spending Breakdown Chart
                MainCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Spending Breakdown',
                        style: TextStyle(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 200,
                        child: Consumer(
                          builder: (context, ref, child) {
                            final insights = ref.watch(spendingInsightsProvider((userId: userId, month: selectedDate)));
                            if (insights.isEmpty) {
                              return const Center(child: Text('No spending this month.'));
                            }
                            return _buildSpendingPieChart(insights);
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Recent unusual spending / Trend Warnings
                // Just an example insight card using hardcoded call to the insights provider
                Consumer(
                  builder: (context, ref, child) {
                    return _buildInsightCard(
                      'Financial Health',
                      'Your spending pace is calm and steady this week.',
                      Icons.spa_outlined,
                      AppColors.primary,
                    );
                  },
                ),

                const SizedBox(height: 32),

                // ── Bottom Area: Household Timeline ───────────────────────────
                const Text(
                  'HOUSEHOLD TIMELINE',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 16),

                transactionsAsync.when(
                  data: (transactions) {
                    if (transactions.isEmpty) {
                      return const MainCard(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Center(child: Text('No recent activity.')),
                        ),
                      );
                    }
                    final recentTxs = transactions.take(10).toList();
                    return MainCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: recentTxs.map((tx) {
                          final isExpense = tx.type.toLowerCase() == 'expense';
                          final color = isExpense ? AppColors.textDark : AppColors.income;
                          final dateStr = DateFormat('MMM d').format(tx.date);

                          return ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                isExpense ? Icons.shopping_bag_outlined : Icons.account_balance_wallet_outlined,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              tx.note?.isNotEmpty == true ? tx.note! : 'Transaction',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            subtitle: Text(
                              dateStr,
                              style: const TextStyle(color: AppColors.textLight, fontSize: 12),
                            ),
                            trailing: Text(
                              _formatCurrency(tx.amount, tx.currency, showSign: true),
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => const SizedBox.shrink(),
                ),

                const SizedBox(height: 40),

                // ── Optional/Demoted Net Worth ────────────────────────────────
                Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    title: const Text(
                      'Total Financial Position',
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        letterSpacing: 1.5,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Consumer(
                          builder: (context, ref, child) {
                            final totalNetWorth = ref.watch(totalNetWorthProvider(userId));
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total Assets & Balances', style: TextStyle(color: AppColors.textDark)),
                                Text(
                                  _formatCurrency(totalNetWorth, appUserAsync.value?.baseCurrency ?? 'USD'),
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 80), // Padding for FAB
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textLight,
            fontWeight: FontWeight.w900,
            fontSize: 10,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingCard(BuildContext context, WidgetRef ref, String userId) {
    final stats = ref.watch(upcomingBillsStatsProvider(userId));
    final upcomingTotal = stats['upcomingTotal'] as int;
    final overdueCount = stats['overdueCount'] as int;
    final dueSoonCount = stats['dueSoonCount'] as int;
    final baseCurrency = ref.watch(appUserStreamProvider(userId)).value?.baseCurrency ?? 'USD';

    final hasOverdue = overdueCount > 0;
    final Color headerColor = hasOverdue ? AppColors.expense : AppColors.primary;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const UpcomingScreen(showBackButton: true),
        ),
      ),
      child: MainCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: headerColor.withValues(alpha: 0.08),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.upcoming_outlined, color: headerColor, size: 18),
                  const SizedBox(width: 10),
                  Text(
                    'UPCOMING BILLS',
                    style: TextStyle(
                      color: headerColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.chevron_right, color: headerColor, size: 18),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  _upcomingStat(
                    label: 'TOTAL',
                    value: _formatCurrency(upcomingTotal, baseCurrency, decimal: 0),
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 1),
                  Container(width: 1, height: 40, color: AppColors.primaryLight),
                  const SizedBox(width: 1),
                  _upcomingStat(
                    label: 'DUE SOON',
                    value: dueSoonCount == 0 ? 'None' : '$dueSoonCount item${dueSoonCount > 1 ? 's' : ''}',
                    color: dueSoonCount > 0 ? const Color(0xFFF59E0B) : AppColors.income,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _upcomingStat({required String label, required String value, required Color color}) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 15,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textLight,
              fontWeight: FontWeight.w900,
              fontSize: 9,
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(String title, String description, IconData icon, Color color) {
    return MainCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingPieChart(Map<String, int> insights) {
    final colors = [
      AppColors.primary,
      const Color(0xFFD946EF),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFF3B82F6),
      AppColors.textLight,
    ];

    int colorIdx = 0;
    int total = insights.values.fold(0, (sum, val) => sum + val);

    final sections = insights.entries.map((entry) {
      final percentage = (entry.value / total) * 100;
      final color = colors[colorIdx % colors.length];
      colorIdx++;

      return PieChartSectionData(
        color: color,
        value: entry.value.toDouble(),
        title: '${percentage.toStringAsFixed(0)}%',
        radius: 50,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: sections,
      ),
    );
  }

  String _formatCurrency(int amountInCents, String currencyCode, {bool showSign = false, int decimal = 2}) {
    String symbol = '\$';
    if (currencyCode == 'HTG') symbol = 'G';
    if (currencyCode == 'EUR') symbol = '€';
    
    final isNegative = amountInCents < 0;
    final absAmount = amountInCents.abs() / 100;
    final formatted = absAmount.toStringAsFixed(decimal);
    
    final sign = isNegative ? '-' : (showSign ? '+' : '');
    
    if (currencyCode == 'HTG') return '$sign$formatted $symbol';
    return '$sign$symbol$formatted';
  }
}
