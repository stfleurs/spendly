import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/shared/widgets/app_header.dart';
import 'package:spendly/shared/widgets/main_card.dart';
import 'package:spendly/shared/themes/app_theme.dart';
import 'package:spendly/features/transactions/repository/transaction_repository.dart';
import 'package:spendly/features/accounts/repository/account_repository.dart';
import 'package:spendly/features/budget/repository/category_repository.dart';
import 'package:spendly/core/models/app_transaction.dart';
import 'package:spendly/core/models/account.dart';
import 'package:spendly/core/models/category.dart';
import 'package:spendly/core/providers/firebase_providers.dart';
import 'package:spendly/features/auth/repository/auth_repository.dart';

class NewTransactionScreen extends ConsumerStatefulWidget {
  /// Pass an existing transaction to enter edit mode.
  final AppTransaction? transaction;

  const NewTransactionScreen({super.key, this.transaction});

  @override
  ConsumerState<NewTransactionScreen> createState() => _NewTransactionScreenState();
}

class _NewTransactionScreenState extends ConsumerState<NewTransactionScreen> {
  late final TextEditingController _amountController;
  late String _selectedType;
  Account? _selectedAccount;
  Category? _selectedCategory;
  late String _selectedCurrency;
  late final TextEditingController _payeeController;
  bool _isLoading = false;

  bool get _isEditing => widget.transaction != null;

  static const List<String> _currencies = ['USD', 'HTG', 'EUR', 'CAD'];

  @override
  void initState() {
    super.initState();
    final t = widget.transaction;
    _amountController = TextEditingController(
      text: t != null ? (t.amount / 100).toStringAsFixed(2) : '0.00',
    );
    _selectedType = t != null ? t.type.toUpperCase() : 'EXPENSE';
    _selectedCurrency = t?.currency ?? 'USD';
    _payeeController = TextEditingController(text: t?.note ?? '');
    // Account and category are resolved after streams load in build()
  }

  @override
  void dispose() {
    _amountController.dispose();
    _payeeController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_selectedAccount == null || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select account and category')),
      );
      return;
    }

    final amountValue = double.tryParse(_amountController.text) ?? 0.0;
    if (amountValue <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final transaction = AppTransaction(
      id: widget.transaction?.id ?? '',
      userId: ref.read(authRepositoryProvider).currentUser?.uid ?? '',
      type: _selectedType.toLowerCase(),
      amount: (amountValue * 100).toInt(),
      currency: _selectedCurrency,
      date: widget.transaction?.date ?? DateTime.now(),
      accountId: _selectedAccount!.id,
      categoryId: _selectedCategory!.id,
      note: _payeeController.text.trim(),
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
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text('Are you sure you want to delete this transaction?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('DELETE', style: TextStyle(color: AppColors.expense)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      setState(() => _isLoading = true);
      try {
        await ref.read(transactionRepositoryProvider).deleteTransaction(widget.transaction!.id);
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
                const Text(
                  'SELECT CURRENCY',
                  style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.textDark, letterSpacing: 1.2),
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

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(authStateProvider).value?.uid ?? '';
    final accountsAsync = ref.watch(accountsStreamProvider(userId));
    final categoriesAsync = ref.watch(categoriesStreamProvider(userId));

    // Pre-select account/category when stream data arrives (edit mode)
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
            title: _isEditing ? 'Edit Transaction' : 'New Transaction',
            showBackButton: true,
            showDatePicker: false,
            showActions: false,
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 24),

                // Scan Receipt — hide in edit mode
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

                // Transaction Type Toggle
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

                // Transaction Details
                MainCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ACCOUNT',
                          style: TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.1)),
                      const SizedBox(height: 8),
                      accountsAsync.when(
                        data: (accounts) {
                          if (accounts.isEmpty) return const Text('No accounts found');
                          return DropdownButton<Account>(
                            value: _selectedAccount,
                            isExpanded: true,
                            underline: const SizedBox(),
                            hint: const Text('Select Account'),
                            items: accounts.map((acc) {
                              return DropdownMenuItem(
                                value: acc,
                                child: Text('${acc.name} (${acc.currency})'),
                              );
                            }).toList(),
                            onChanged: (val) => setState(() {
                              _selectedAccount = val;
                              if (val != null) _selectedCurrency = val.currency;
                            }),
                          );
                        },
                        loading: () => const LinearProgressIndicator(),
                        error: (e, s) => Text('Error: $e'),
                      ),
                      const SizedBox(height: 24),
                      const Divider(color: AppColors.primaryLight),
                      const SizedBox(height: 24),
                      const Text('CATEGORY',
                          style: TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.1)),
                      const SizedBox(height: 8),
                      categoriesAsync.when(
                        data: (categories) {
                          if (categories.isEmpty) return const Text('No categories found');
                          return DropdownButton<Category>(
                            value: _selectedCategory,
                            isExpanded: true,
                            underline: const SizedBox(),
                            hint: const Text('Select Category'),
                            items: categories.map((cat) {
                              return DropdownMenuItem(value: cat, child: Text(cat.name));
                            }).toList(),
                            onChanged: (val) => setState(() => _selectedCategory = val),
                          );
                        },
                        loading: () => const LinearProgressIndicator(),
                        error: (e, s) => Text('Error: $e'),
                      ),
                      const SizedBox(height: 24),
                      const Divider(color: AppColors.primaryLight),
                      const SizedBox(height: 24),
                      const Text('AMOUNT',
                          style: TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.1)),
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
                      const SizedBox(height: 24),
                      const Divider(color: AppColors.primaryLight),
                      const SizedBox(height: 24),
                      const Text('PAYEE / NOTE',
                          style: TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.1)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _payeeController,
                        style: const TextStyle(
                            color: AppColors.textDark, fontSize: 20, fontWeight: FontWeight.w900),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Who or what for?',
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Save Button
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
                              _isEditing ? 'UPDATE TRANSACTION' : 'SAVE TRANSACTION',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.1),
                            ),
                    ),
                  ),
                ),

                // Delete Button (edit mode only)
                if (_isEditing) ...[
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: _isLoading ? null : _delete,
                      child: const Text(
                        'DELETE TRANSACTION',
                        style: TextStyle(color: AppColors.expense, fontWeight: FontWeight.bold),
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
