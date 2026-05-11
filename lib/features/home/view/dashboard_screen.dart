import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:spendly/shared/widgets/app_header.dart';
import 'package:spendly/shared/widgets/main_card.dart';
import 'package:spendly/shared/themes/app_theme.dart';
import 'package:spendly/core/providers/firebase_providers.dart';
import 'package:spendly/core/providers/balance_provider.dart';
import 'package:spendly/features/budget/providers/budget_provider.dart';
import 'package:spendly/features/budget/view/budget_screen.dart';
import 'package:spendly/features/reports/view/reports_screen.dart';
import 'package:spendly/features/ocr/view/receipt_scanner_screen.dart';
import 'package:spendly/features/upcoming/providers/upcoming_provider.dart';
import 'package:spendly/features/upcoming/view/upcoming_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedDays = 30;

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(authStateProvider).value?.uid ?? '';
    final totalNetWorth = ref.watch(totalNetWorthProvider(userId));
    final timeline = ref.watch(netWorthTimelineProvider((userId: userId, days: _selectedDays)));
    final budgetAsync = ref.watch(budgetProvider(userId));

    return CustomScrollView(
      slivers: [
        const SliverAppHeader(title: 'Dashboard'),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Net Worth Card
                MainCard(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      const Text(
                        'TOTAL NET WORTH',
                        style: TextStyle(
                          color: AppColors.textLight,
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '\$${(totalNetWorth / 100).toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Trend Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'NET WORTH TREND',
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        letterSpacing: 1.5,
                      ),
                    ),
                    _buildTimeframeSelector(),
                  ],
                ),
                const SizedBox(height: 16),
                
                MainCard(
                  padding: const EdgeInsets.only(top: 32, right: 24, left: 8, bottom: 8),
                  child: SizedBox(
                    height: 200,
                    child: timeline.when(
                      data: (data) => data.isEmpty 
                        ? const Center(child: Text('No data for this period'))
                        : _buildTrendChart(data),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, s) => Center(child: Text('Error: $e')),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // ── Upcoming Payments Card ─────────────────────────────
                _buildUpcomingCard(context, ref, userId),

                const SizedBox(height: 32),

                // Quick Actions
                Row(
                  children: [
                    Expanded(
                      child: _buildDashboardSmallCard(
                        'SCAN RECEIPT',
                        Icons.qr_code_scanner,
                        'Snap a Photo',
                        () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const ReceiptScannerScreen()),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDashboardSmallCard(
                        'ADD MANUAL',
                        Icons.add_circle_outline,
                        'Enter Details',
                        () => Navigator.pushNamed(context, '/new_transaction'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Budget & Insights Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildDashboardSmallCard(
                        'MONTHLY BUDGET',
                        Icons.donut_large,
                        'View Details',
                        () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const MyBudgetScreen()),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDashboardSmallCard(
                        'TOP SPENDING',
                        Icons.shopping_bag_outlined,
                        'View Report',
                        () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const ReportsScreen()),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
                
                // Quick Insights
                const Text(
                  'QUICK INSIGHTS',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                budgetAsync.when(
                  data: (state) {
                    final totalBudget = state.items.fold(0, (sum, item) => sum + (item.category.monthlyTarget ?? 0));
                    final totalSpent = state.items.fold(0, (sum, item) => sum + item.spentAmount);
                    final remaining = totalBudget - totalSpent;
                    
                    return _buildInsightCard(
                      'Budget Status', 
                      remaining >= 0 
                        ? 'You have \$${(remaining / 100).toStringAsFixed(2)} left to spend this month.'
                        : 'You are over budget by \$${(remaining.abs() / 100).toStringAsFixed(2)}!', 
                      Icons.check_circle_outline,
                      remaining >= 0 ? AppColors.income : AppColors.expense,
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 12),
                Consumer(
                  builder: (context, ref, child) {
                    final utilization = ref.watch(creditUtilizationProvider(userId));
                    return _buildInsightCard(
                      'Credit Utilization', 
                      'Your card usage is at ${(utilization * 100).toStringAsFixed(1)}%. ${utilization > 0.3 ? "Try to keep it under 30%." : "Keep it up!"}', 
                      Icons.credit_card,
                      utilization > 0.3 ? AppColors.expense : AppColors.primary,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingCard(BuildContext context, WidgetRef ref, String userId) {
    final stats = ref.watch(upcomingBillsStatsProvider(userId));
    final upcomingTotal = stats['upcomingTotal'] as int;
    final overdueTotal = stats['overdueTotal'] as int;
    final overdueCount = stats['overdueCount'] as int;
    final dueSoonCount = stats['dueSoonCount'] as int;

    final hasOverdue = overdueCount > 0;
    final Color headerColor = hasOverdue ? AppColors.expense : AppColors.primary;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const UpcomingScreen()),
      ),
      child: MainCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header bar
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
                    'UPCOMING PAYMENTS',
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

            // Stats row
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  _upcomingStat(
                    label: 'UPCOMING',
                    value: '\$${(upcomingTotal / 100).toStringAsFixed(0)}',
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 1),
                  Container(width: 1, height: 40, color: AppColors.primaryLight),
                  const SizedBox(width: 1),
                  _upcomingStat(
                    label: 'OVERDUE',
                    value: overdueCount == 0
                        ? 'None'
                        : '\$${(overdueTotal / 100).toStringAsFixed(0)}',
                    color: overdueCount > 0 ? AppColors.expense : AppColors.income,
                  ),
                  const SizedBox(width: 1),
                  Container(width: 1, height: 40, color: AppColors.primaryLight),
                  const SizedBox(width: 1),
                  _upcomingStat(
                    label: 'DUE SOON',
                    value: dueSoonCount == 0
                        ? 'None'
                        : '$dueSoonCount item${dueSoonCount > 1 ? 's' : ''}',
                    color: dueSoonCount > 0
                        ? const Color(0xFFF59E0B)
                        : AppColors.income,
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

  Widget _buildDashboardSmallCard(String title, IconData icon, String action, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: MainCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textLight,
                fontWeight: FontWeight.w900,
                fontSize: 10,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              action,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeframeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _buildTimeframeItem('7D', 7),
          _buildTimeframeItem('30D', 30),
          _buildTimeframeItem('90D', 90),
        ],
      ),
    );
  }

  Widget _buildTimeframeItem(String label, int days) {
    final isSelected = _selectedDays == days;
    return GestureDetector(
      onTap: () => setState(() => _selectedDays = days),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textLight,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTrendChart(List<({DateTime date, int balance})> timeline) {
    if (timeline.isEmpty) return const SizedBox.shrink();

    final spots = timeline.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.balance / 100.0);
    }).toList();

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            preventCurveOverShooting: true,
            color: AppColors.primary,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primary.withValues(alpha: 0.1),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColors.primary,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final date = timeline[spot.x.toInt()].date;
                return LineTooltipItem(
                  '${date.day}/${date.month}\n\$${spot.y.toStringAsFixed(2)}',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                );
              }).toList();
            },
          ),
        ),
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
}
