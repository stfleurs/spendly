// import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:spendly/shared/themes/app_theme.dart';
import 'package:spendly/core/models/receipt.dart';
import 'package:spendly/core/models/app_transaction.dart';
import 'package:spendly/features/transactions/repository/transaction_repository.dart';
import 'package:spendly/features/accounts/repository/account_repository.dart';
import 'package:spendly/features/budget/providers/budget_provider.dart';
import 'package:spendly/features/auth/repository/auth_repository.dart';
import 'package:spendly/core/providers/balance_provider.dart';
import 'package:spendly/features/ocr/repository/merchant_repository.dart';
import 'package:uuid/uuid.dart';

class ReceiptConfirmationScreen extends ConsumerStatefulWidget {
  final Receipt receipt;
  const ReceiptConfirmationScreen({super.key, required this.receipt});

  @override
  ConsumerState<ReceiptConfirmationScreen> createState() => _ReceiptConfirmationScreenState();
}

class _ReceiptConfirmationScreenState extends ConsumerState<ReceiptConfirmationScreen> {
  late TextEditingController _merchantController;
  late TextEditingController _amountController;
  DateTime? _selectedDate;
  String? _selectedAccountId;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _merchantController = TextEditingController(text: widget.receipt.merchant);
    _amountController = TextEditingController(
      text: widget.receipt.total != null ? (widget.receipt.total! / 100).toStringAsFixed(2) : '',
    );
    _selectedDate = widget.receipt.date ?? DateTime.now();
    
    // Merchant Memory: Auto-select category/account
    _loadMerchantPreferences();
  }

  Future<void> _loadMerchantPreferences() async {
    if (widget.receipt.merchant == null) return;
    
    final userId = ref.read(authRepositoryProvider).currentUser?.uid ?? '';
    final pref = await ref.read(merchantRepositoryProvider).getPreference(userId, widget.receipt.merchant!);
    
    if (pref != null && mounted) {
      setState(() {
        _selectedCategoryId = pref.categoryId;
        _selectedAccountId = pref.accountId;
      });
    }
  }

  @override
  void dispose() {
    _merchantController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _saveTransaction() async {
    if (_selectedAccountId == null || _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select account and category')),
      );
      return;
    }

    final amount = (double.tryParse(_amountController.text) ?? 0.0) * 100;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid amount')),
      );
      return;
    }

    final userId = widget.receipt.userId;
    
    // Duplicate Detection (Basic)
    final existingTransactions = ref.read(transactionsStreamProvider(userId)).value ?? [];
    final isDuplicate = existingTransactions.any((t) => 
      t.amount == amount.round() && 
      t.date.year == _selectedDate!.year &&
      t.date.month == _selectedDate!.month &&
      t.date.day == _selectedDate!.day &&
      t.note?.toLowerCase() == _merchantController.text.toLowerCase()
    );

    if (isDuplicate) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Possible Duplicate'),
          content: const Text('A transaction with this amount and merchant already exists for today. Save anyway?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('SAVE')),
          ],
        ),
      );
      if (proceed != true || !mounted) return;
    }

    try {
      final transaction = AppTransaction(
        id: const Uuid().v4(),
        userId: userId,
        accountId: _selectedAccountId!,
        amount: amount.round(),
        categoryId: _selectedCategoryId!,
        note: _merchantController.text,
        type: 'expense',
        date: _selectedDate ?? DateTime.now(),
        receiptUrl: widget.receipt.imageUrl,
        currency: 'HTG',
      );

      await ref.read(transactionRepositoryProvider).addTransaction(transaction);
      
      // Update Merchant Memory
      await ref.read(merchantRepositoryProvider).savePreference(userId, MerchantPreference(
        merchantName: _merchantController.text,
        categoryId: _selectedCategoryId!,
        accountId: _selectedAccountId!,
      ));

      if (!mounted) return;
      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.expense),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.read(authRepositoryProvider).currentUser?.uid ?? '';
    final accounts = ref.watch(accountsStreamProvider(userId));
    final budgetState = ref.watch(budgetProvider(userId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Confirm Details', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.refresh),
            label: const Text('RETRY'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Receipt Preview
            Center(
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: NetworkImage(widget.receipt.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 32),

            // Merchant
            _buildInputField(
              label: 'Merchant',
              controller: _merchantController,
              icon: Icons.store,
              confidence: widget.receipt.merchant != null ? widget.receipt.confidence : 0.0,
            ),
            const SizedBox(height: 16),

            // Amount
            _buildInputField(
              label: 'Amount',
              controller: _amountController,
              icon: Icons.attach_money,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              confidence: widget.receipt.total != null ? widget.receipt.confidence : 0.0,
            ),
            const SizedBox(height: 16),

            // Date
            _buildDatePicker(
              confidence: _selectedDate != null ? widget.receipt.confidence : 0.0,
            ),
            const SizedBox(height: 32),

            const Text(
              'TRANSACTION DETAILS',
              style: TextStyle(color: AppColors.textLight, fontWeight: FontWeight.bold, fontSize: 12),
            ),
            const SizedBox(height: 16),

            // Account Selection
            accounts.when(
              data: (accs) => _buildDropdown<String>(
                label: 'Account',
                value: _selectedAccountId,
                items: accs.map((a) {
                  return DropdownMenuItem(
                    value: a.id,
                    child: Consumer(
                      builder: (context, ref, _) {
                        final balance = ref.watch(accountBalanceProvider((userId: userId, accountId: a.id)));
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(a.name),
                            Text(
                              '${(balance / 100).toStringAsFixed(2)} HTG',
                              style: const TextStyle(
                                color: AppColors.textLight,
                                fontSize: 12,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedAccountId = val),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (err, stack) => const Text('Error loading accounts'),
            ),
            const SizedBox(height: 16),

            // Category Selection
            budgetState.when(
              data: (state) => _buildDropdown<String>(
                label: 'Category',
                value: _selectedCategoryId,
                items: state.items.map((i) => DropdownMenuItem(value: i.category.id, child: Text(i.category.name))).toList(),
                onChanged: (val) => setState(() => _selectedCategoryId = val),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (err, stack) => const Text('Error loading categories'),
            ),
            const SizedBox(height: 48),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _saveTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                ),
                child: const Text('Confirm & Save', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required double confidence,
    TextInputType keyboardType = TextInputType.text,
  }) {
    Color borderColor = Colors.transparent;
    Color? bgColor;

    if (confidence < 0.5) {
      borderColor = AppColors.expense.withValues(alpha: 0.5); // Subtle red
      bgColor = AppColors.expense.withValues(alpha: 0.03);
    } else if (confidence < 0.8) {
      borderColor = Colors.amber.withValues(alpha: 0.5); // Subtle amber
      bgColor = Colors.amber.withValues(alpha: 0.03);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textLight, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: bgColor ?? Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor != Colors.transparent ? borderColor : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppColors.primary),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              hintText: 'Enter $label',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker({required double confidence}) {
    Color borderColor = Colors.transparent;
    Color? bgColor;

    if (confidence < 0.5) {
      borderColor = AppColors.expense.withValues(alpha: 0.5);
      bgColor = AppColors.expense.withValues(alpha: 0.03);
    } else if (confidence < 0.8) {
      borderColor = Colors.amber.withValues(alpha: 0.5);
      bgColor = Colors.amber.withValues(alpha: 0.03);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Date', style: TextStyle(color: AppColors.textLight, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _selectedDate ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
            );
            if (picked != null) setState(() => _selectedDate = picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: bgColor ?? Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: borderColor != Colors.transparent ? borderColor : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Text(
                  _selectedDate != null ? DateFormat('MMM dd, yyyy').format(_selectedDate!) : 'Select Date',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textLight, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              items: items,
              onChanged: onChanged,
              isExpanded: true,
              hint: Text('Select $label'),
              style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
