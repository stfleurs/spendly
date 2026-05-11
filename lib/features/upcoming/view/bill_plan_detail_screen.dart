import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/shared/themes/app_theme.dart';
import 'package:spendly/shared/widgets/main_card.dart';
import 'package:spendly/core/models/bill.dart';
import 'package:spendly/core/models/bill_template.dart';
import 'package:spendly/core/providers/firebase_providers.dart';
import 'package:spendly/features/upcoming/providers/upcoming_provider.dart';
import 'package:spendly/features/upcoming/view/add_plan_screen.dart';
import 'package:spendly/features/upcoming/view/add_upcoming_screen.dart';
import 'package:spendly/features/upcoming/view/mark_paid_sheet.dart';
import 'package:spendly/features/upcoming/view/upcoming_screen.dart';

class BillPlanDetailScreen extends ConsumerWidget {
  final BillTemplate plan;

  const BillPlanDetailScreen({super.key, required this.plan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(authStateProvider).value?.uid ?? '';
    final billsAsync = ref.watch(billsProvider(userId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: billsAsync.when(
        data: (allBills) {
          final linked = allBills
              .where((b) => b.templateId == plan.id)
              .toList()
            ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

          return _buildBody(context, ref, userId, linked);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    String userId,
    List<Bill> linked,
  ) {
    final totalPaid = linked.fold(0, (sum, b) => sum + b.paidAmount);
    final totalObligation = plan.totalAmount;
    final hasTotal = totalObligation != null && totalObligation > 0;
    final progressValue = hasTotal ? (totalPaid / totalObligation).clamp(0.0, 1.0) : null;
    final remaining = hasTotal ? (totalObligation - totalPaid) : null;

    final history = linked.where((b) => b.paidAmount > 0).toList()
      ..sort((a, b) => b.dueDate.compareTo(a.dueDate));
    final upcoming = linked
        .where((b) => !b.isPaid && b.computedStatus != BillStatus.cancelled)
        .toList();

    // ── Forecast Logic ──────────────────────────────────────────────────────
    String? forecastText;
    if (hasTotal && remaining! > 0) {
      final installment = plan.defaultAmount > 0 ? plan.defaultAmount : 1;
      final remainingPayments = (remaining / installment).ceil();
      
      // Guess frequency (default to monthly if not sure)
      final monthsToAdd = plan.frequency.toLowerCase() == 'yearly' 
          ? remainingPayments * 12 
          : plan.frequency.toLowerCase() == 'weekly'
              ? (remainingPayments / 4).ceil()
              : remainingPayments;

      final now = DateTime.now();
      final estCompletion = DateTime(now.year, now.month + monthsToAdd, now.day);
      final monthName = _monthName(estCompletion.month);
      forecastText = 'Estimated completion: $monthName ${estCompletion.year} ($remainingPayments more payment${remainingPayments > 1 ? 's' : ''})';
    } else if (hasTotal && remaining! <= 0) {
      forecastText = 'Obligation fully settled! 🎉';
    }

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 200,
          backgroundColor: AppColors.primary,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.white),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => AddPlanScreen(existingPlan: plan)),
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, Color(0xFF7C3AED)],
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 50, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    plan.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 26,
                    ),
                  ),
                  if (plan.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      plan.description!,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 13),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Progress Card ──────────────────────────────────────────
                MainCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _statCol(
                              label: 'TOTAL PAID',
                              value: '\$${(totalPaid / 100).toStringAsFixed(0)}',
                              color: AppColors.income,
                            ),
                          ),
                          if (hasTotal) ...[
                            Expanded(
                              child: _statCol(
                                label: 'OBLIGATION',
                                value: '\$${(totalObligation / 100).toStringAsFixed(0)}',
                                color: AppColors.textDark,
                              ),
                            ),
                            Expanded(
                              child: _statCol(
                                label: 'REMAINING',
                                value: '\$${(remaining! / 100).toStringAsFixed(0)}',
                                color: remaining > 0
                                    ? AppColors.expense
                                    : AppColors.income,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (progressValue != null) ...[
                        const SizedBox(height: 24),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progressValue,
                            minHeight: 12,
                            backgroundColor: AppColors.primaryLight,
                            color: progressValue >= 1.0
                                ? AppColors.income
                                : const Color(0xFF7C3AED),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${(progressValue * 100).toStringAsFixed(0)}% Complete',
                              style: const TextStyle(
                                  color: AppColors.textDark,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900),
                            ),
                            if (forecastText != null)
                              Flexible(
                                child: Text(
                                  forecastText,
                                  style: const TextStyle(
                                      color: AppColors.textLight,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ── Action Buttons ─────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => AddUpcomingScreen(
                              prefilledPlanId: plan.id,
                              prefilledAmount: plan.defaultAmount,
                              prefilledCategoryId: plan.categoryId,
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.add_circle_outline, size: 18),
                        label: const Text('ADD INSTALLMENT'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // ── Upcoming ───────────────────────────────────────────────
                if (upcoming.isNotEmpty) ...[
                  _sectionHeader('UPCOMING', AppColors.primary, Icons.upcoming_outlined),
                  const SizedBox(height: 12),
                  ...upcoming.map((b) => _InstallmentRow(bill: b, userId: userId)),
                  const SizedBox(height: 32),
                ],

                // ── History ────────────────────────────────────────────────
                if (history.isNotEmpty) ...[
                  _sectionHeader('PAYMENT HISTORY', AppColors.income, Icons.history_outlined),
                  const SizedBox(height: 12),
                  ...history.map((b) => _InstallmentRow(bill: b, userId: userId)),
                ],

                if (linked.isEmpty) _buildEmpty(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _statCol({required String label, required String value, required Color color}) {
    return Column(
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 18),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
              color: AppColors.textLight,
              fontWeight: FontWeight.w900,
              fontSize: 8,
              letterSpacing: 1.1),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _sectionHeader(String label, Color color, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 14),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w900,
            fontSize: 11,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  String _monthName(int month) {
    const names = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return names[(month - 1) % 12];
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.payments_outlined, size: 48, color: AppColors.textLight.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            const Text('No installments scheduled', style: TextStyle(color: AppColors.textLight, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class _InstallmentRow extends StatelessWidget {
  final Bill bill;
  final String userId;

  const _InstallmentRow({required this.bill, required this.userId});

  @override
  Widget build(BuildContext context) {
    final status = bill.computedStatus;
    final statusColor = status.color;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: MainCard(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            // Date column
            SizedBox(
              width: 45,
              child: Column(
                children: [
                  Text(
                    '${bill.dueDate.day}',
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                  Text(
                    _monthAbbr(bill.dueDate.month),
                    style: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bill.title,
                    style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      status.sectionLabel,
                      style: TextStyle(color: statusColor, fontWeight: FontWeight.w900, fontSize: 8, letterSpacing: 1.0),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${(bill.amount / 100).toStringAsFixed(2)}',
                  style: TextStyle(
                    color: bill.isPaid ? AppColors.income : AppColors.textDark,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                if (!bill.isPaid && status != BillStatus.cancelled)
                  GestureDetector(
                    onTap: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => MarkPaidSheet(bill: bill, userId: userId),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        'PAY NOW',
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.1),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _monthAbbr(int month) {
    const abbrs = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return abbrs[month - 1];
  }
}
