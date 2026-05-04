import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/shared/widgets/app_header.dart';
import 'package:spendly/shared/widgets/main_card.dart';
import 'package:spendly/shared/themes/app_theme.dart';
import 'package:spendly/core/providers/firebase_providers.dart';
import 'package:spendly/core/providers/date_provider.dart';
import 'package:spendly/features/transactions/repository/transaction_repository.dart';
import 'package:spendly/features/budget/repository/category_repository.dart';
import 'package:spendly/core/models/app_transaction.dart';
import 'package:spendly/core/models/category.dart';
import 'package:spendly/features/transactions/view/new_transaction_screen.dart';
import 'package:spendly/generated/l10n/app_localizations.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(authStateProvider).value?.uid ?? '';
    final selectedDate = ref.watch(selectedDateProvider);
    final transactionsAsync = ref.watch(transactionsStreamProvider(userId));
    final categoriesAsync = ref.watch(categoriesStreamProvider(userId));

    final l10n = AppLocalizations.of(context)!;

    return CustomScrollView(
      slivers: [
        SliverAppHeader(title: l10n.activity),
        SliverToBoxAdapter(
          child: transactionsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, s) => Padding(
              padding: const EdgeInsets.all(24),
              child: Center(child: Text('Error loading transactions: $e')),
            ),
            data: (allTransactions) {
              // Filter to selected month
              final transactions = allTransactions.where((t) {
                return t.date.year == selectedDate.year &&
                    t.date.month == selectedDate.month;
              }).toList();

              if (transactions.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.receipt_long_outlined, color: AppColors.textLight, size: 56),
                        const SizedBox(height: 16),
                        Text(
                          l10n.noTransactions,
                          style: const TextStyle(
                            color: AppColors.textLight,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.tapToAdd,
                          style: const TextStyle(color: AppColors.textLight),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final categories = categoriesAsync.value ?? [];
              final Map<String, Category> catMap = {
                for (final c in categories) c.id: c
              };

              return Column(
                children: [
                  const SizedBox(height: 24),
                  MainCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: transactions.map((t) {
                        return _buildTransactionItem(context, ref, t, catMap);
                      }).toList(),
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

  void _openEditScreen(BuildContext context, AppTransaction transaction) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NewTransactionScreen(transaction: transaction),
      ),
    );
  }

  Widget _buildTransactionItem(
    BuildContext context,
    WidgetRef ref,
    AppTransaction transaction,
    Map<String, Category> catMap,
  ) {
    final isExpense = transaction.type.toLowerCase() == 'expense';
    final isIncome = transaction.type.toLowerCase() == 'income';
    final categoryName = catMap[transaction.categoryId]?.name ?? transaction.type.toUpperCase();
    final amountStr = '${isExpense ? '-' : isIncome ? '+' : ''}${transaction.currency == 'HTG' ? 'G' : transaction.currency == 'EUR' ? '€' : '\$'}${(transaction.amount / 100).toStringAsFixed(2)}';

    final l10n = AppLocalizations.of(context)!;
    final day = transaction.date.day.toString().padLeft(2, '0');
    final monthNames = [
      l10n.jan, l10n.feb, l10n.mar, l10n.apr, l10n.may, l10n.jun,
      l10n.jul, l10n.aug, l10n.sep, l10n.oct, l10n.nov, l10n.dec
    ];
    final dateStr = '${monthNames[transaction.date.month - 1]} $day • ${categoryName.toUpperCase()}';

    final amountColor = isExpense ? AppColors.expense : isIncome ? AppColors.income : AppColors.textDark;
    final iconBg = isExpense ? AppColors.expense.withValues(alpha: 0.1) : isIncome ? AppColors.income.withValues(alpha: 0.1) : AppColors.primaryLight;
    final iconColor = isExpense ? AppColors.expense : isIncome ? AppColors.income : AppColors.textLight;

    return InkWell(
      onTap: () => _openEditScreen(context, transaction),
      child: Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.primaryLight, width: 1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isExpense ? Icons.arrow_upward : isIncome ? Icons.arrow_downward : Icons.swap_horiz,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.note?.isNotEmpty == true ? transaction.note! : categoryName,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  dateStr,
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                    letterSpacing: 1.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            amountStr,
            style: TextStyle(
              color: amountColor,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: AppColors.textLight, size: 20),
        ],
      ),
    ));
  }
}
