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
import 'package:spendly/features/ocr/repository/receipt_repository.dart';
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
  late TextEditingController _subtotalController;
  late TextEditingController _taxController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _paymentMethodController;
  late TextEditingController _receiptNumberController;
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
    _subtotalController = TextEditingController(
      text: widget.receipt.subtotal != null ? (widget.receipt.subtotal! / 100).toStringAsFixed(2) : '',
    );
    _taxController = TextEditingController(
      text: widget.receipt.tax != null ? (widget.receipt.tax! / 100).toStringAsFixed(2) : '',
    );
    _addressController = TextEditingController(text: widget.receipt.address);
    _phoneController = TextEditingController(text: widget.receipt.phone);
    _emailController = TextEditingController(text: widget.receipt.email);
    _paymentMethodController = TextEditingController(text: widget.receipt.paymentMethod);
    _receiptNumberController = TextEditingController(text: widget.receipt.receiptNumber);
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
    _subtotalController.dispose();
    _taxController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _paymentMethodController.dispose();
    _receiptNumberController.dispose();
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
      final totalCents = amount.round();
      final subtotalCents = (double.tryParse(_subtotalController.text) ?? 0.0) * 100;
      final taxCents = (double.tryParse(_taxController.text) ?? 0.0) * 100;

      // Update the Receipt record with corrected values
      final correctedReceipt = widget.receipt.copyWith(
        merchant: _merchantController.text,
        total: totalCents,
        subtotal: subtotalCents.round(),
        tax: taxCents.round(),
        date: _selectedDate,
        address: _addressController.text.isNotEmpty ? _addressController.text : null,
        phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
        email: _emailController.text.isNotEmpty ? _emailController.text : null,
        paymentMethod: _paymentMethodController.text.isNotEmpty ? _paymentMethodController.text : null,
        receiptNumber: _receiptNumberController.text.isNotEmpty ? _receiptNumberController.text : null,
        processed: true,
      );

      await ref.read(receiptRepositoryProvider).saveReceipt(correctedReceipt);

      final transaction = AppTransaction(
        id: const Uuid().v4(),
        userId: userId,
        accountId: _selectedAccountId!,
        amount: totalCents,
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

            // Subtotal and Tax
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    label: 'Subtotal',
                    controller: _subtotalController,
                    icon: Icons.summarize_outlined,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    confidence: widget.receipt.subtotal != null ? widget.receipt.confidence : 1.0,
                    dense: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInputField(
                    label: 'Tax',
                    controller: _taxController,
                    icon: Icons.receipt_outlined,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    confidence: widget.receipt.tax != null ? widget.receipt.confidence : 1.0,
                    dense: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Amount
            _buildInputField(
              label: 'Grand Total',
              controller: _amountController,
              icon: Icons.payments_outlined,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              confidence: widget.receipt.total != null ? widget.receipt.confidence : 0.0,
            ),
            const SizedBox(height: 16),

            // Date
            _buildDatePicker(
              confidence: _selectedDate != null ? widget.receipt.confidence : 0.0,
            ),
            const SizedBox(height: 32),

            // Line Items Section
            if (widget.receipt.items != null && widget.receipt.items!.isNotEmpty) ...[
              const Text(
                'LINE ITEMS',
                style: TextStyle(color: AppColors.textLight, fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 16),
              _buildLineItems(),
              const SizedBox(height: 32),
            ],

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
            const SizedBox(height: 32),

            // Extra Metadata Section
            const Text(
              'RECEIPT DETAILS',
              style: TextStyle(color: AppColors.textLight, fontWeight: FontWeight.bold, fontSize: 12),
            ),
            const SizedBox(height: 16),
            _buildInputField(
              label: 'Address',
              controller: _addressController,
              icon: Icons.location_on_outlined,
              confidence: widget.receipt.address != null ? widget.receipt.confidence : 1.0,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    label: 'Phone',
                    controller: _phoneController,
                    icon: Icons.phone_outlined,
                    confidence: widget.receipt.phone != null ? widget.receipt.confidence : 1.0,
                    keyboardType: TextInputType.phone,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInputField(
                    label: 'Email',
                    controller: _emailController,
                    icon: Icons.email_outlined,
                    confidence: widget.receipt.email != null ? widget.receipt.confidence : 1.0,
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    label: 'Payment Method',
                    controller: _paymentMethodController,
                    icon: Icons.payment_outlined,
                    confidence: widget.receipt.paymentMethod != null ? widget.receipt.confidence : 1.0,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInputField(
                    label: 'Receipt #',
                    controller: _receiptNumberController,
                    icon: Icons.tag,
                    confidence: widget.receipt.receiptNumber != null ? widget.receipt.confidence : 1.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const SizedBox(height: 16),

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

  Widget _buildLineItems() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: widget.receipt.items!.map((item) {
          final isLast = widget.receipt.items!.last == item;
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: isLast ? null : Border(bottom: BorderSide(color: AppColors.primary.withValues(alpha: 0.1))),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.shopping_bag_outlined, color: AppColors.primary, size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.description,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (item.quantity != null)
                        Text(
                          'Qty: ${item.quantity}',
                          style: const TextStyle(color: AppColors.textLight, fontSize: 12),
                        ),
                    ],
                  ),
                ),
                Text(
                  '${(item.amount / 100).toStringAsFixed(2)} HTG',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required double confidence,
    TextInputType keyboardType = TextInputType.text,
    bool dense = false,
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
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppColors.primary, size: dense ? 18 : 24),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: dense ? 8 : 12),
              hintText: 'Enter $label',
              hintStyle: TextStyle(fontSize: dense ? 12 : 14),
            ),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: dense ? 13 : 15,
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
