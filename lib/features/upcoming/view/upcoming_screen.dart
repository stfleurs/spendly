import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/shared/themes/app_theme.dart';
import 'package:spendly/shared/widgets/app_header.dart';
import 'package:spendly/shared/widgets/main_card.dart';
import 'package:spendly/core/models/bill.dart';
import 'package:spendly/core/models/bill_template.dart';
import 'package:spendly/core/providers/firebase_providers.dart';
import 'package:spendly/features/upcoming/providers/upcoming_provider.dart';
import 'package:spendly/features/upcoming/view/add_upcoming_screen.dart';
import 'package:spendly/features/upcoming/view/bill_plan_detail_screen.dart';
import 'package:spendly/features/upcoming/view/mark_paid_sheet.dart';

// ─────────────────────────────────────────────────────────────
// Helpers: colour + label resolved from a single BillStatus
// ─────────────────────────────────────────────────────────────

extension BillStatusUI on BillStatus {
  Color get color => switch (this) {
        BillStatus.overdue => AppColors.expense,
        BillStatus.dueSoon => const Color(0xFFF59E0B),
        BillStatus.partiallyPaid => const Color(0xFF7C3AED),
        BillStatus.paid => AppColors.income,
        BillStatus.cancelled => AppColors.textLight,
        BillStatus.upcoming => AppColors.primary,
      };

  IconData get icon => switch (this) {
        BillStatus.overdue => Icons.warning_amber_rounded,
        BillStatus.dueSoon => Icons.schedule_outlined,
        BillStatus.partiallyPaid => Icons.incomplete_circle,
        BillStatus.paid => Icons.check_circle_outline,
        BillStatus.cancelled => Icons.cancel_outlined,
        BillStatus.upcoming => Icons.upcoming_outlined,
      };

  String get sectionLabel => switch (this) {
        BillStatus.overdue => 'OVERDUE',
        BillStatus.dueSoon => 'DUE SOON',
        BillStatus.partiallyPaid => 'PARTIALLY PAID',
        BillStatus.paid => 'PAID',
        BillStatus.cancelled => 'CANCELLED',
        BillStatus.upcoming => 'UPCOMING',
      };

  /// Display priority — lower renders first
  int get sortOrder => switch (this) {
        BillStatus.overdue => 0,
        BillStatus.dueSoon => 1,
        BillStatus.partiallyPaid => 2,
        BillStatus.upcoming => 3,
        BillStatus.paid => 4,
        BillStatus.cancelled => 5,
      };
}

// ─────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────

class UpcomingScreen extends ConsumerWidget {
  final bool showBackButton;

  const UpcomingScreen({
    super.key,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(authStateProvider).value?.uid ?? '';
    final billsAsync = ref.watch(billsProvider(userId));

    return CustomScrollView(
      slivers: [
        SliverAppHeader(
          title: 'Upcoming',
          showDatePicker: false,
          showBackButton: showBackButton,
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
            child: billsAsync.when(
              data: (bills) => _buildContent(context, ref, userId, bills),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    String userId,
    List<Bill> bills,
  ) {
    // We always call _buildWithPlans which handles both cases (empty/non-empty)
    return _buildWithPlans(context, ref, userId, bills);
  }

  Widget _buildWithPlans(
    BuildContext context,
    WidgetRef ref,
    String userId,
    List<Bill> bills,
  ) {
    final plansAsync = ref.watch(billTemplatesProvider(userId));

    return plansAsync.when(
      data: (plans) {
        // Standalone bills have no templateId
        final standaloneBills =
            bills.where((b) => b.templateId == null).toList();

        if (plans.isEmpty && standaloneBills.isEmpty) {
          return _buildEmptyState(context);
        }

        // Group standalone bills by computedStatus
        final Map<BillStatus, List<Bill>> grouped = {};
        for (final bill in standaloneBills) {
          grouped.putIfAbsent(bill.computedStatus, () => []).add(bill);
        }
        final orderedStatuses = grouped.keys.toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Plans section ───────────────────────────────────────
            if (plans.isNotEmpty) ...[
              _buildSectionHeader(null,
                  label: 'PAYMENT PLANS',
                  color: const Color(0xFF7C3AED),
                  icon: Icons.account_tree_outlined),
              const SizedBox(height: 12),
              ...plans.map((p) =>
                  _PlanCard(plan: p, bills: bills, userId: userId)),
              const SizedBox(height: 28),
            ],

            // ── Standalone bills ─────────────────────────────────────
            for (final status in orderedStatuses) ...[
              _buildSectionHeader(status),
              const SizedBox(height: 12),
              ...grouped[status]!
                  .map((b) => _BillCard(bill: b, userId: userId)),
              const SizedBox(height: 24),
            ],
          ],
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 80),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (e, _) => Center(child: Text('Error loading plans: $e')),
    );
  }

  Widget _buildSectionHeader(
    BillStatus? status, {
    String? label,
    Color? color,
    IconData? icon,
  }) {
    final c = color ?? status!.color;
    final i = icon ?? status!.icon;
    final l = label ?? status!.sectionLabel;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: c.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(i, color: c, size: 14),
        ),
        const SizedBox(width: 10),
        Text(
          l,
          style: TextStyle(
            color: c,
            fontWeight: FontWeight.w900,
            fontSize: 11,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 80),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.upcoming_outlined,
                size: 52,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Nothing upcoming',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add tuition, rent, utilities and other\nplanned payments to track them here.',
              style: TextStyle(color: AppColors.textLight, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddUpcomingScreen()),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Add Payment'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Bill Card
// ─────────────────────────────────────────────────────────────

class _BillCard extends ConsumerWidget {
  final Bill bill;
  final String userId;
  const _BillCard({required this.bill, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = bill.computedStatus;
    final statusColor = status.color;

    final daysLabel = _daysLabel(bill, status);
    final canPay = status != BillStatus.paid && status != BillStatus.cancelled;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: MainCard(
        padding: EdgeInsets.zero,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _openDetail(context, ref),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Status bar
                Container(
                  width: 4,
                  height: 56,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title + amount
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              bill.title,
                              style: const TextStyle(
                                color: AppColors.textDark,
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$${(bill.amount / 100).toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: status == BillStatus.paid
                                      ? AppColors.income
                                      : AppColors.textDark,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                              // Expected vs actual delta when partially paid
                              if (status == BillStatus.partiallyPaid)
                                Text(
                                  'paid \$${(bill.paidAmount / 100).toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: AppColors.textLight,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Status label + linked badge
                      Row(
                        children: [
                          Text(
                            daysLabel,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                              letterSpacing: 1.1,
                            ),
                          ),
                          if (bill.linkedTransactionId != null) ...[
                            const SizedBox(width: 10),
                            Row(
                              children: const [
                                Icon(Icons.link, color: AppColors.income, size: 11),
                                SizedBox(width: 3),
                                Text(
                                  'LINKED',
                                  style: TextStyle(
                                    color: AppColors.income,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 9,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),

                      // Partial payment progress bar
                      if (status == BillStatus.partiallyPaid) ...[
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: bill.paidAmount / bill.amount,
                            backgroundColor: AppColors.primaryLight,
                            color: statusColor,
                            minHeight: 4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Pay button
                if (canPay) ...[
                  const SizedBox(width: 12),
                  _PayButton(bill: bill, userId: userId),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _daysLabel(Bill bill, BillStatus status) {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final daysRemaining = bill.dueDate.difference(todayOnly).inDays;

    return switch (status) {
      BillStatus.paid => 'PAID',
      BillStatus.cancelled => 'CANCELLED',
      BillStatus.overdue =>
        '${daysRemaining.abs()} DAY${daysRemaining.abs() == 1 ? '' : 'S'} OVERDUE',
      BillStatus.dueSoon =>
        daysRemaining == 0 ? 'DUE TODAY' : 'DUE IN $daysRemaining DAY${daysRemaining == 1 ? '' : 'S'}',
      BillStatus.partiallyPaid =>
        'REMAINING \$${(bill.remainingAmount / 100).toStringAsFixed(2)}',
      BillStatus.upcoming =>
        'DUE ${bill.dueDate.day}/${bill.dueDate.month}/${bill.dueDate.year}',
    };
  }

  void _openDetail(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BillDetailSheet(bill: bill, userId: userId),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Pay Button
// ─────────────────────────────────────────────────────────────

class _PayButton extends StatelessWidget {
  final Bill bill;
  final String userId;
  const _PayButton({required this.bill, required this.userId});

  @override
  Widget build(BuildContext context) {
    final isPartial = bill.computedStatus == BillStatus.partiallyPaid;
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => MarkPaidSheet(bill: bill, userId: userId),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isPartial
              ? const Color(0xFF7C3AED)
              : AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          isPartial ? 'PAY MORE' : 'PAY',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 11,
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Bill Detail Sheet
// ─────────────────────────────────────────────────────────────

class _BillDetailSheet extends ConsumerWidget {
  final Bill bill;
  final String userId;
  const _BillDetailSheet({required this.bill, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(upcomingRepositoryProvider);
    final status = bill.computedStatus;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textLight.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Status chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: status.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(status.icon, color: status.color, size: 12),
                  const SizedBox(width: 6),
                  Text(
                    status.sectionLabel,
                    style: TextStyle(
                      color: status.color,
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Text(
              bill.title,
              style: const TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w900,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 6),

            // Expected vs actual amounts
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${(bill.amount / 100).toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                    fontSize: 32,
                  ),
                ),
                if (bill.paidAmount > 0) ...[
                  const SizedBox(width: 10),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      '(\$${(bill.paidAmount / 100).toStringAsFixed(2)} paid)',
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 20),
            _detailRow(Icons.calendar_today_outlined, 'Due Date',
                '${bill.dueDate.day}/${bill.dueDate.month}/${bill.dueDate.year}'),
            if (bill.remainingAmount > 0 && !bill.isPaid)
              _detailRow(Icons.payments_outlined, 'Remaining',
                  '\$${(bill.remainingAmount / 100).toStringAsFixed(2)}'),
            if (bill.notes != null)
              _detailRow(Icons.notes_outlined, 'Notes', bill.notes!),
            if (bill.linkedTransactionId != null)
              _detailRow(
                  Icons.link, 'Linked Tx', bill.linkedTransactionId!),
            if (bill.receiptId != null)
              _detailRow(
                  Icons.receipt_outlined, 'Receipt', bill.receiptId!),

            const SizedBox(height: 24),

            // Action row
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmDelete(context, ref, repo),
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: const Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.expense,
                      side: const BorderSide(color: AppColors.expense),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) =>
                              AddUpcomingScreen(existingBill: bill)),
                    ),
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),

            // Cancel button (only for non-cancelled bills)
            if (status != BillStatus.cancelled && status != BillStatus.paid) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => _cancelBill(context, ref, repo),
                  child: const Text(
                    'Cancel this payment',
                    style: TextStyle(color: AppColors.textLight),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textLight, size: 18),
          const SizedBox(width: 12),
          Text('$label: ',
              style: const TextStyle(color: AppColors.textLight, fontSize: 13)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _cancelBill(BuildContext context, WidgetRef ref, dynamic repo) async {
    final updated = bill.copyWith(status: BillStatus.cancelled);
    await repo.updateBill(updated);
    if (context.mounted) Navigator.pop(context);
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, dynamic repo) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Payment?'),
        content: Text('Are you sure you want to delete "${bill.title}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await repo.deleteBill(userId, bill.id);
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
              }
            },
            child: const Text('Delete',
                style: TextStyle(color: AppColors.expense)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Plan Summary Card
// ─────────────────────────────────────────────────────────────

class _PlanCard extends StatelessWidget {
  final BillTemplate plan;
  final List<Bill> bills;
  final String userId;

  const _PlanCard({
    required this.plan,
    required this.bills,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final linked = bills.where((b) => b.templateId == plan.id).toList();
    final totalPaid = linked.fold(0, (sum, b) => sum + b.paidAmount);
    final totalObligation = plan.totalAmount;
    final hasTotal = totalObligation != null && totalObligation > 0;
    final progress = hasTotal ? (totalPaid / totalObligation).clamp(0.0, 1.0) : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: MainCard(
        padding: EdgeInsets.zero,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BillPlanDetailScreen(plan: plan),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        plan.title,
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.textLight, size: 20),
                  ],
                ),
                if (plan.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    plan.description!,
                    style: const TextStyle(color: AppColors.textLight, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 16),
                
                // Progress
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${(totalPaid / 100).toStringAsFixed(0)} paid',
                      style: const TextStyle(
                        color: AppColors.income,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                    if (hasTotal)
                      Text(
                        'of \$${(totalObligation / 100).toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: AppColors.textLight,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
                if (hasTotal) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: AppColors.primaryLight,
                      color: progress >= 1.0 ? AppColors.income : const Color(0xFF7C3AED),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

