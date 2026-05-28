import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:spendly/shared/widgets/app_header.dart';
import 'package:spendly/shared/widgets/main_card.dart';
import 'package:spendly/core/providers/currency_provider.dart';
import 'package:spendly/shared/themes/app_theme.dart';
import 'package:spendly/features/transactions/repository/transaction_repository.dart';
import 'package:spendly/features/accounts/repository/account_repository.dart';
import 'package:spendly/features/budget/repository/category_repository.dart';
import 'package:spendly/core/models/app_transaction.dart';
import 'package:spendly/core/models/account.dart';
import 'package:spendly/core/models/category.dart';
import 'package:spendly/core/providers/firebase_providers.dart';
import 'package:spendly/features/auth/repository/auth_repository.dart';
import 'package:spendly/core/providers/balance_provider.dart';
import 'package:spendly/features/budget/view/category_form_bottom_sheet.dart';
import 'package:spendly/generated/l10n/app_localizations.dart';
import 'package:spendly/core/providers/exchange_rate_provider.dart';
import 'package:spendly/core/providers/device_provider.dart';
import 'package:spendly/core/utils/currency_formatter.dart';

class NewTransactionScreen extends ConsumerStatefulWidget {
  final AppTransaction? transaction;

  const NewTransactionScreen({super.key, this.transaction});

  @override
  ConsumerState<NewTransactionScreen> createState() => _NewTransactionScreenState();
}

class _NewTransactionScreenState extends ConsumerState<NewTransactionScreen> {
  late final TextEditingController _amountController;
  late final TextEditingController _rateController;
  late String _selectedType;
  Account? _selectedAccount;
  Category? _selectedCategory;
  late String _selectedCurrency;
  late final TextEditingController _payeeController;
  bool _isLoading = false;

  bool get _isEditing => widget.transaction != null;

  static const List<String> _currencies = ['USD', 'HTG', 'EUR', 'CAD'];

  late final String _idempotencyKey;

  @override
  void initState() {
    super.initState();
    _idempotencyKey = widget.transaction?.idempotencyKey ?? const Uuid().v4();
    final t = widget.transaction;
    _amountController = TextEditingController(
      text: t != null ? (t.amount / 100).toStringAsFixed(2) : '0.00',
    );
    _selectedType = t != null ? t.type.toUpperCase() : 'EXPENSE';
    _selectedCurrency = t?.currency ?? 'USD';
    _payeeController = TextEditingController(text: t?.note ?? '');
    _rateController = TextEditingController(
      text: t != null && t.exchangeRate != 1.0 ? t.exchangeRate.toStringAsFixed(4) : '',
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _payeeController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final isExpense = _selectedType.toUpperCase() == 'EXPENSE';
    if (_selectedAccount == null || (isExpense && _selectedCategory == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isExpense ? 'Please select account and category' : 'Please select an account')),
      );
      return;
    }

    final amountValue = double.tryParse(_amountController.text) ?? 0.0;
    final amountCents = (amountValue * 100).toInt();

    if (amountValue <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    final userId = ref.read(authRepositoryProvider).currentUser?.uid ?? '';
    int available = ref.read(availableFundsProvider((userId: userId, accountId: _selectedAccount!.id)));

    if (_isEditing && widget.transaction!.accountId == _selectedAccount!.id) {
      if (widget.transaction!.type.toLowerCase() == 'expense') {
        available += widget.transaction!.amount;
      } else if (widget.transaction!.type.toLowerCase() == 'income') {
        available -= widget.transaction!.amount;
      }
    }

    if (_selectedType.toUpperCase() == 'EXPENSE' && amountCents > available) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Insufficient funds. Available: ${formatCents(available, _selectedAccount!.currency, locale: AppLocalizations.of(context)!.localeName)}'),
          backgroundColor: AppColors.expense,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final int centsValue = (amountValue * 100).toInt();
    final baseCurrency = ref.read(currencyProvider);
    final isCrossCurrency = _selectedAccount != null && _selectedCurrency != _selectedAccount!.currency;

    final double rate;
    if (isCrossCurrency) {
      rate = double.tryParse(_rateController.text.replaceAll(',', '')) ?? 0.0;
      if (rate <= 0) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter the exchange rate to continue.')),
        );
        return;
      }
    } else {
      rate = ref.read(exchangeRateProvider((userId: userId, from: _selectedCurrency, to: baseCurrency)));
    }

    const int rateScale = 1000000;
    final int scaledRate = (rate * rateScale).round();
    final int normalizedAmount = (centsValue * scaledRate) ~/ rateScale;

    final deviceId = ref.read(deviceIdProvider).value;
    final sequence = await ref.read(mutationSequenceProvider.notifier).increment();

    final transaction = AppTransaction(
      id: widget.transaction?.id ?? '',
      idempotencyKey: _idempotencyKey,
      mutationVersion: (widget.transaction?.mutationVersion ?? 0) + 1,
      parentMutationId: widget.transaction?.idempotencyKey,
      deviceId: deviceId,
      mutationSequence: sequence,
      userId: ref.read(authRepositoryProvider).currentUser?.uid ?? '',
      type: _selectedType.toLowerCase(),
      amount: centsValue,
      currency: _selectedCurrency,
      amountInBaseCurrency: normalizedAmount,
      baseCurrency: baseCurrency,
      exchangeRate: rate,
      scaledRate: scaledRate,
      rateScale: rateScale,
      rateSource: 'manual',
      rateBaseCurrency: _selectedAccount?.currency ?? baseCurrency,
      rateQuoteCurrency: _selectedCurrency,
      date: widget.transaction?.date ?? DateTime.now(),
      accountId: _selectedAccount!.id,
      categoryId: isExpense ? _selectedCategory!.id : '',
      note: _payeeController.text.trim(),
      searchTokens: AppTransaction.createSearchTokens(
          _payeeController.text.trim(), isExpense ? _selectedCategory!.name : null),
      originalAmount: centsValue,
      originalCurrency: _selectedCurrency,
    );

    try {
      if (_isEditing) {
        await ref.read(transactionRepositoryProvider).updateTransaction(transaction);
      } else {
        await ref.read(transactionRepositoryProvider).addTransaction(transaction);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving transaction: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteConfirmTitle),
        content: Text(l10n.deleteConfirmMessage),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete, style: const TextStyle(color: AppColors.expense)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      setState(() => _isLoading = true);
      try {
        await ref.read(transactionRepositoryProvider).deleteTransaction(widget.transaction!);
        if (mounted) Navigator.of(context).pop();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _showCurrencyPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context)!.currency.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.textDark, letterSpacing: 1.2),
                ),
                const SizedBox(height: 8),
                ..._currencies.map((c) {
                  final isSelected = c == _selectedCurrency;
                  return ListTile(
                    title: Text(
                      c,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                        color: isSelected ? AppColors.primary : AppColors.textDark,
                      ),
                    ),
                    trailing: isSelected ? const Icon(Icons.check, color: AppColors.primary) : null,
                    onTap: () {
                      setState(() => _selectedCurrency = c);
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
  }

  void _applyExchangeRate() async {
    final rateController = TextEditingController();
    final result = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exchange Rate', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter the exchange rate to multiply the amount by.', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
            const SizedBox(height: 16),
            TextField(
              controller: rateController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Rate',
                border: OutlineInputBorder(),
                hintText: '1.0',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, double.tryParse(rateController.text)),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('APPLY'),
          ),
        ],
      ),
    );

    if (result != null && result > 0) {
      setState(() {
        final current = double.tryParse(_amountController.text) ?? 0.0;
        _amountController.text = (current * result).toStringAsFixed(2);

        if (_selectedAccount != null) {
          _selectedCurrency = _selectedAccount!.currency;
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Applied exchange rate: $result')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = l10n.localeName;
    final userId = ref.watch(authStateProvider).value?.uid ?? '';
    final accountsAsync = ref.watch(accountsStreamProvider(userId));
    final categoriesAsync = ref.watch(categoriesStreamProvider(userId));
    final availableFunds = _selectedAccount != null
        ? ref.watch(availableFundsProvider((userId: userId, accountId: _selectedAccount!.id)))
        : 0;

    if (_isEditing && _selectedAccount == null && accountsAsync.value != null) {
      final match = accountsAsync.value!.where((a) => a.id == widget.transaction!.accountId);
      if (match.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() => _selectedAccount = match.first);
        });
      }
    }
    if (_isEditing && _selectedCategory == null && categoriesAsync.value != null) {
      final match = categoriesAsync.value!.where((c) => c.id == widget.transaction!.categoryId);
      if (match.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() => _selectedCategory = match.first);
        });
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppHeader(
            title: _isEditing ? l10n.editTransaction : l10n.newTransaction,
            showBackButton: true,
            showDatePicker: false,
            showActions: false,
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 24),

                if (!_isEditing)
                  MainCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.primaryLight),
                            ),
                            child: const Text(
                              'Text or Scan Receipt',
                              style: TextStyle(color: AppColors.textLight, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('PARSE', style: TextStyle(fontWeight: FontWeight.w900)),
                        ),
                      ],
                    ),
                  ),

                if (!_isEditing) const SizedBox(height: 16),

                MainCard(
                  padding: const EdgeInsets.all(8),
                  borderRadius: 40,
                  child: Row(
                    children: [
                      _buildTypeItem('EXPENSE'),
                      _buildTypeItem('INCOME'),
                      _buildTypeItem('TRANSFER'),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                MainCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.accounts,
                          style: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.1)),
                      const SizedBox(height: 8),
                      accountsAsync.when(
                        data: (accounts) {
                          if (accounts.isEmpty) return const Text('No accounts found');
                          return DropdownButton<String>(
                            value: _selectedAccount?.id,
                            isExpanded: true,
                            underline: const SizedBox(),
                            hint: const Text('Select Account'),
                            items: accounts.map((acc) {
                              final balance = ref.watch(accountBalanceProvider((userId: userId, accountId: acc.id)));
                              final isNegative = balance < 0;
                              return DropdownMenuItem<String>(
                                value: acc.id,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(acc.name,
                                        style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
                                    Text(
                                      formatCents(balance, acc.currency, locale: locale),
                                      style: TextStyle(
                                        color: isNegative ? AppColors.expense : AppColors.textLight,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (id) => setState(() {
                              final acc = accounts.cast<Account?>().firstWhere((a) => a?.id == id, orElse: () => null);
                              _selectedAccount = acc;
                              if (acc != null) _selectedCurrency = acc.currency;
                            }),
                          );
                        },
                        loading: () => const LinearProgressIndicator(),
                        error: (e, s) => Text('Error: $e'),
                      ),
                      if (_selectedAccount != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Available: ${formatCents(availableFunds, _selectedAccount!.currency, locale: locale)}',
                            style: TextStyle(
                              color: availableFunds < 0 ? AppColors.expense : AppColors.textLight,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),

                      if (_selectedType.toUpperCase() == 'EXPENSE') ...[
                        const SizedBox(height: 24),
                        const Divider(color: AppColors.primaryLight),
                        const SizedBox(height: 24),
                        Text(l10n.category,
                            style: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.1)),
                        const SizedBox(height: 8),
                        categoriesAsync.when(
                          data: (categories) {
                            return Row(
                              children: [
                                Expanded(
                                  child: DropdownButton<String>(
                                    value: _selectedCategory?.id,
                                    isExpanded: true,
                                    underline: const SizedBox(),
                                    hint: const Text('Select Category'),
                                    items: categories.map((cat) {
                                      return DropdownMenuItem<String>(value: cat.id, child: Text(cat.name));
                                    }).toList(),
                                    onChanged: (id) => setState(() {
                                      final cat = categories.cast<Category?>().firstWhere((c) => c?.id == id, orElse: () => null);
                                      _selectedCategory = cat;
                                    }),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline, color: AppColors.primary, size: 20),
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (context) => const CategoryFormBottomSheet(category: null),
                                    ).then((_) {
                                      ref.invalidate(categoriesStreamProvider(userId));
                                    });
                                  },
                                ),
                              ],
                            );
                          },
                          loading: () => const LinearProgressIndicator(),
                          error: (e, s) => Text('Error: $e'),
                        ),
                      ],
                      const SizedBox(height: 24),
                      const Divider(color: AppColors.primaryLight),
                      const SizedBox(height: 24),
                      Text(l10n.amount,
                          style: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.1)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _showCurrencyPicker,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Text(_selectedCurrency,
                                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900)),
                                  const Icon(Icons.keyboard_arrow_down, color: AppColors.primary, size: 16),
                                  const SizedBox(width: 8),
                                  const VerticalDivider(width: 1, indent: 4, endIndent: 4),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: _applyExchangeRate,
                                    child: const Icon(Icons.calculate_outlined, size: 20, color: AppColors.primary),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: _amountController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(
                                  color: AppColors.textDark, fontSize: 40, fontWeight: FontWeight.w900),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: '0.00',
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_selectedAccount != null && _selectedCurrency != _selectedAccount!.currency) ...[
                        const SizedBox(height: 16),
                        const Divider(color: AppColors.primaryLight),
                        const SizedBox(height: 16),
                        Builder(builder: (context) {
                          final userRate = double.tryParse(_rateController.text.replaceAll(',', '')) ?? 0.0;
                          final amt = double.tryParse(_amountController.text) ?? 0.0;
                          final converted = userRate > 0 ? amt * userRate : null;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.swap_horiz, color: Colors.orange, size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Cross-currency: $_selectedCurrency → ${_selectedAccount!.currency}. Enter the exchange rate.',
                                        style: const TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'EXCHANGE RATE  (1 $_selectedCurrency = ? ${_selectedAccount!.currency})',
                                style: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.1),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _rateController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w900, fontSize: 18),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'e.g. 135.00',
                                  prefixText: '1 $_selectedCurrency = ',
                                  prefixStyle: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.bold),
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                              if (converted != null && converted > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.income.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.account_balance_wallet_outlined, size: 14, color: AppColors.income),
                                      const SizedBox(width: 8),
                                      Text(
                                        '≈ ${_selectedAccount!.currency} ${converted.toStringAsFixed(2)} will be recorded',
                                        style: const TextStyle(color: AppColors.income, fontWeight: FontWeight.w900, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                const Padding(
                                  padding: EdgeInsets.only(top: 6),
                                  child: Text(
                                    '⚠ Exchange rate required to save.',
                                    style: TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                            ],
                          );
                        }),
                      ],

                      const SizedBox(height: 24),
                      const Divider(color: AppColors.primaryLight),
                      const SizedBox(height: 24),
                      Text(l10n.payeeNote,
                          style: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.1)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _payeeController,
                        style: const TextStyle(
                            color: AppColors.textDark, fontSize: 20, fontWeight: FontWeight.w900),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: l10n.payeeHint,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 8,
                        shadowColor: AppColors.primary.withValues(alpha: 0.4),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              _isEditing ? l10n.updateTransaction : l10n.saveTransaction,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.1),
                            ),
                    ),
                  ),
                ),

                if (_isEditing) ...[
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: _isLoading ? null : _delete,
                      child: Text(
                        l10n.deleteTransaction,
                        style: const TextStyle(color: AppColors.expense, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeItem(String label) {
    final isSelected = _selectedType == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(32),
            boxShadow: isSelected
                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.textDark : AppColors.textLight,
                fontWeight: FontWeight.w900,
                fontSize: 12,
                letterSpacing: 1.1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
