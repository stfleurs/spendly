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
import 'package:spendly/features/accounts/repository/account_repository.dart';
import 'package:spendly/core/models/account.dart';
import 'package:spendly/generated/l10n/app_localizations.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  final String? initialAccountId;
  const TransactionsScreen({super.key, this.initialAccountId});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showOnlyReceipts = false;
  String _selectedType = 'All'; // All, Expense, Income
  String _selectedAccountId = 'All';

  final ScrollController _scrollController = ScrollController();
  final List<AppTransaction> _historicalTransactions = [];
  bool _isLoadingMore = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    if (widget.initialAccountId != null) {
      _selectedAccountId = widget.initialAccountId!;
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    final userId = ref.read(authStateProvider).value?.uid ?? '';
    final liveTransactions = ref.read(transactionsStreamProvider(userId)).value ?? [];
    
    // Use the date of the last transaction we have (either from history or live)
    final lastTx = _historicalTransactions.isNotEmpty 
        ? _historicalTransactions.last 
        : (liveTransactions.isNotEmpty ? liveTransactions.last : null);

    if (lastTx == null) return;

    setState(() => _isLoadingMore = true);
    try {
      final more = await ref.read(transactionRepositoryProvider).getTransactionsPaginated(
        userId,
        startAfterDate: lastTx.date,
        startAfterId: lastTx.id,
      );

      if (mounted) {
        setState(() {
          if (more.isEmpty) {
            _hasMore = false;
          } else {
            // Deduplicate just in case
            final existingIds = {
              ...liveTransactions.map((t) => t.id),
              ..._historicalTransactions.map((t) => t.id)
            };
            _historicalTransactions.addAll(more.where((t) => !existingIds.contains(t.id)));
          }
        });
      }
    } finally {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(authStateProvider).value?.uid ?? '';
    final selectedDate = ref.watch(selectedDateProvider);
    final transactionsAsync = ref.watch(transactionsStreamProvider(userId));
    final accountsAsync = ref.watch(accountsStreamProvider(userId));
    final categoriesAsync = ref.watch(categoriesStreamProvider(userId));

    final l10n = AppLocalizations.of(context)!;

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverAppHeader(
          title: l10n.activity,
          showBackButton: widget.initialAccountId != null,
          bottom: _buildAccountPicker(context, ref),
        ),
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
            data: (liveTransactions) {
              final categories = categoriesAsync.value ?? [];
              final accounts = accountsAsync.value ?? [];
              final Map<String, Category> catMap = {for (final c in categories) c.id: c};
              final Map<String, Account> accMap = {for (final a in accounts) a.id: a};
              
              // Merge live transactions with historical ones
              final allTransactions = [
                ...liveTransactions,
                ..._historicalTransactions,
              ];

              // Apply Filters
              final transactions = allTransactions.where((t) {
                // Month Filter
                final isSameMonth = t.date.year == selectedDate.year && t.date.month == selectedDate.month;
                if (!isSameMonth) return false;

                // Type Filter
                if (_selectedType != 'All' && t.type.toLowerCase() != _selectedType.toLowerCase()) return false;

                // Account Filter
                if (_selectedAccountId != 'All' && t.accountId != _selectedAccountId) return false;

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
                        _buildFilterChip(_selectedType, 'All', (val) => setState(() => _selectedType = val)),
                        const SizedBox(width: 8),
                        _buildFilterChip(_selectedType, 'Expense', (val) => setState(() => _selectedType = val)),
                        const SizedBox(width: 8),
                        _buildFilterChip(_selectedType, 'Income', (val) => setState(() => _selectedType = val)),
                        const SizedBox(width: 16),
                        Container(width: 1, height: 24, color: AppColors.primaryLight, margin: const EdgeInsets.symmetric(vertical: 12)),
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
                              _searchController.text.isNotEmpty || _showOnlyReceipts || _selectedType != 'All' || _selectedAccountId != 'All'
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
                              _searchController.text.isNotEmpty || _showOnlyReceipts || _selectedType != 'All' || _selectedAccountId != 'All'
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
                            return _buildTransactionItem(context, t, catMap, accMap);
                          }).toList(),
                        ),
                      ),
                    ),
                  if (_isLoadingMore)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                  if (!_hasMore && transactions.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          'END OF HISTORY',
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
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

  Widget _buildFilterChip(
    String currentValue, 
    String value, 
    ValueChanged<String> onSelected, 
    {String? labelOverride, Color? colorOverride}
  ) {
    final isSelected = currentValue == value;
    final themeColor = colorOverride ?? AppColors.primary;
    
    return ChoiceChip(
      label: Text(labelOverride ?? value.toUpperCase()),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : themeColor,
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.1,
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) onSelected(value);
      },
      backgroundColor: Colors.white,
      selectedColor: themeColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30), side: BorderSide(color: themeColor.withValues(alpha: 0.2))),
      elevation: 0,
      pressElevation: 0,
    );
  }

  Widget _buildAccountPicker(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(authStateProvider).value?.uid ?? '';
    final accounts = ref.watch(accountsStreamProvider(userId)).value ?? [];
    
    final selectedAccount = accounts.where((a) => a.id == _selectedAccountId).firstOrNull;
    final label = _selectedAccountId == 'All' ? 'ALL ACCOUNTS' : selectedAccount?.name.toUpperCase() ?? 'SELECT ACCOUNT';
    final accountColor = selectedAccount?.color != null 
        ? Color(int.parse('FF${selectedAccount!.color!.substring(1)}', radix: 16)) 
        : Colors.white;

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: AppColors.background,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (context) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('SELECT ACCOUNT', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.textDark, letterSpacing: 1.2)),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Icon(Icons.all_inclusive, color: AppColors.primary),
                      title: Text(
                        'ALL ACCOUNTS',
                        style: TextStyle(
                          fontWeight: _selectedAccountId == 'All' ? FontWeight.w900 : FontWeight.bold,
                          color: _selectedAccountId == 'All' ? AppColors.primary : AppColors.textDark,
                        ),
                      ),
                      onTap: () {
                        setState(() => _selectedAccountId = 'All');
                        Navigator.pop(context);
                      },
                    ),
                    ...accounts.map((acc) {
                      final isSelected = acc.id == _selectedAccountId;
                      final color = acc.color != null ? Color(int.parse('FF${acc.color!.substring(1)}', radix: 16)) : AppColors.primary;
                      return ListTile(
                        leading: Icon(Icons.account_balance_wallet, color: color),
                        title: Text(
                          acc.name,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                            color: isSelected ? color : AppColors.textDark,
                          ),
                        ),
                        onTap: () {
                          setState(() => _selectedAccountId = acc.id);
                          Navigator.pop(context);
                        },
                      );
                    }),
                  ],
                ),
              ),
            );
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 16),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white, 
                fontWeight: FontWeight.bold, 
                fontSize: 12, 
                letterSpacing: 1.1
              ),
            ),
            const Spacer(),
            if (_selectedAccountId != 'All') ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: accountColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
            ],
            const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 20),
          ],
        ),
      ),
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
    Map<String, Account> accMap,
  ) {
    final account = accMap[transaction.accountId];
    final accountName = account?.name ?? 'Unknown';
    Color accountColor = AppColors.primary;
    if (account?.color != null && account!.color!.startsWith('#')) {
      try {
        accountColor = Color(int.parse('FF${account.color!.substring(1)}', radix: 16));
      } catch (_) {}
    }

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
    final dateStr = '${monthNames[transaction.date.month - 1]} $day';

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
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: accountColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${accountName.toUpperCase()} • ${categoryName.toUpperCase()}',
                        style: TextStyle(
                          color: accountColor.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w900,
                          fontSize: 8,
                          letterSpacing: 0.8,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
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
