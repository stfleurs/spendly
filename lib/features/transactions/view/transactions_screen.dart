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
import 'package:spendly/features/ocr/view/receipt_viewer_screen.dart';
import 'package:spendly/generated/l10n/app_localizations.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showOnlyReceipts = false;
  String _selectedType = 'All'; // All, Expense, Income

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              final categories = categoriesAsync.value ?? [];
              final Map<String, Category> catMap = {for (final c in categories) c.id: c};

              // Apply Filters
              final transactions = allTransactions.where((t) {
                // Month Filter
                final isSameMonth = t.date.year == selectedDate.year && t.date.month == selectedDate.month;
                if (!isSameMonth) return false;

                // Type Filter
                if (_selectedType != 'All' && t.type.toLowerCase() != _selectedType.toLowerCase()) return false;

                // Receipt Filter
                if (_showOnlyReceipts && t.receiptUrl == null) return false;

                // Search Filter
                final query = _searchController.text.toLowerCase().trim();
                if (query.isNotEmpty) {
                  final merchant = t.note?.toLowerCase() ?? '';
                  final category = catMap[t.categoryId]?.name.toLowerCase() ?? '';
                  final amount = (t.amount / 100).toString();
                  if (!merchant.contains(query) && !category.contains(query) && !amount.contains(query)) {
                    return false;
                  }
                }

                return true;
              }).toList();

              return Column(
                children: [
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Search merchant, category...',
                          hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 14),
                          prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                          suffixIcon: _searchController.text.isNotEmpty 
                            ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () => setState(() => _searchController.clear())) 
                            : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),

                  // Filter Chips
                  SizedBox(
                    height: 50,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      children: [
                        _buildFilterChip('All'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Expense'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Income'),
                        const SizedBox(width: 16),
                        FilterChip(
                          label: const Text('WITH RECEIPT'),
                          labelStyle: TextStyle(
                            color: _showOnlyReceipts ? Colors.white : AppColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.1,
                          ),
                          selected: _showOnlyReceipts,
                          onSelected: (val) => setState(() => _showOnlyReceipts = val),
                          backgroundColor: Colors.white,
                          selectedColor: AppColors.primary,
                          checkmarkColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30), side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2))),
                          elevation: 0,
                          pressElevation: 0,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (transactions.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(40),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.receipt_long_outlined, color: AppColors.textLight, size: 56),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isNotEmpty || _showOnlyReceipts || _selectedType != 'All'
                                ? 'No results found'
                                : l10n.noTransactions,
                              style: const TextStyle(
                                color: AppColors.textLight,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _searchController.text.isNotEmpty || _showOnlyReceipts || _selectedType != 'All'
                                ? 'Try adjusting your filters'
                                : l10n.tapToAdd,
                              style: const TextStyle(color: AppColors.textLight),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: MainCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: transactions.map((t) {
                            return _buildTransactionItem(context, t, catMap);
                          }).toList(),
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

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedType == label;
    return ChoiceChip(
      label: Text(label.toUpperCase()),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.primary,
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.1,
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _selectedType = label);
      },
      backgroundColor: Colors.white,
      selectedColor: AppColors.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30), side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2))),
      elevation: 0,
      pressElevation: 0,
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
              if (transaction.receiptUrl != null) ...[
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ReceiptViewerScreen(
                          imageUrl: transaction.receiptUrl!,
                          merchantName: transaction.note ?? categoryName,
                          receiptId: transaction.receiptId,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.receipt_long, size: 10, color: AppColors.primary),
                        SizedBox(width: 2),
                        Text(
                          'RECEIPT',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: AppColors.textLight, size: 20),
        ],
      ),
    ));
  }
}
