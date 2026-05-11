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
import 'package:spendly/core/providers/firebase_providers.dart';
import 'package:spendly/core/providers/currency_provider.dart';
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
  String _selectedCurrency = 'USD';
  bool _isSaving = false;
  
  // Immutability helpers for currency conversion
  late final double _originalTotal;
  late final double _originalSubtotal;
  late final double _originalTax;
  late final String _originalCurrency;
  double _currentExchangeRate = 1.0;

  @override
  void initState() {
    super.initState();
    _merchantController = TextEditingController(text: widget.receipt.merchant);
    
    // Store original values (derived from OCR or initial scan)
    _originalTotal = (widget.receipt.total != null ? widget.receipt.total! / 100 : 0.0);
    _originalSubtotal = (widget.receipt.subtotal != null ? widget.receipt.subtotal! / 100 : 0.0);
    _originalTax = (widget.receipt.tax != null ? widget.receipt.tax! / 100 : 0.0);
    _originalCurrency = widget.receipt.originalCurrency ?? 'USD';

    _amountController = TextEditingController(text: _originalTotal.toStringAsFixed(2));
    _subtotalController = TextEditingController(text: _originalSubtotal.toStringAsFixed(2));
    _taxController = TextEditingController(text: _originalTax.toStringAsFixed(2));
    
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

    final userId = ref.read(authStateProvider).value?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated')),
      );
      return;
    }

    setState(() => _isSaving = true);
    debugPrint('Spendly: Starting save for userId: $userId');
    
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
      if (proceed != true || !mounted) {
        setState(() => _isSaving = false);
        return;
      }
    }

    // Currency Match Validation
    final accounts = ref.read(accountsStreamProvider(userId)).value;
    final selectedAccount = accounts?.firstWhere((a) => a.id == _selectedAccountId);
    
    if (selectedAccount != null && selectedAccount.currency != _selectedCurrency) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Currency Mismatch! Account is in ${selectedAccount.currency}, but Receipt is in $_selectedCurrency. Please convert or change account.'),
          backgroundColor: AppColors.expense,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'CONVERT',
            textColor: Colors.white,
            onPressed: _applyExchangeRate,
          ),
        ),
      );
      return;
    }

    try {
      final totalCents = amount.round();
      final subtotalCents = (double.tryParse(_subtotalController.text) ?? 0.0) * 100;
      final taxCents = (double.tryParse(_taxController.text) ?? 0.0) * 100;

      // Update the Receipt record with corrected values and audit info
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
        // Audit fields
        originalTotal: (_originalTotal * 100).round(),
        originalSubtotal: (_originalSubtotal * 100).round(),
        originalTax: (_originalTax * 100).round(),
        originalCurrency: _originalCurrency,
        exchangeRate: _currentExchangeRate,
      );

      await ref.read(receiptRepositoryProvider).saveReceipt(correctedReceipt);

      final baseCurrency = ref.read(currencyProvider);
      const double rateToBase = 1.0; // TODO: Implement real-time rate lookup
      
      // Rule #2: Scaled Integer Math
      const int rateScale = 1000000;
      final int scaledRate = (rateToBase * rateScale).round();
      final int normalizedAmount = (totalCents * scaledRate) ~/ rateScale;

      final transaction = AppTransaction(
        id: const Uuid().v4(),
        userId: userId,
        accountId: _selectedAccountId!,
        amount: totalCents,
        currency: _selectedCurrency,
        amountInBaseCurrency: normalizedAmount,
        baseCurrency: baseCurrency,
        exchangeRate: _currentExchangeRate, // Rate from original to account
        scaledRate: (rateToBase * rateScale).round(), // Rate from account to base
        rateScale: rateScale,
        rateSource: 'receipt',
        rateBaseCurrency: baseCurrency,
        rateQuoteCurrency: _selectedCurrency,
        date: _selectedDate ?? DateTime.now(),
        categoryId: _selectedCategoryId!,
        receiptUrl: widget.receipt.imageUrl,
        receiptId: correctedReceipt.id,
        note: _merchantController.text,
        type: 'expense',
        // Audit fields
        originalAmount: (_originalTotal * 100).round(),
        originalCurrency: _originalCurrency,
      );

      await ref.read(transactionRepositoryProvider).addTransaction(transaction);
      
      // Update Merchant Memory
      await ref.read(merchantRepositoryProvider).savePreference(userId, MerchantPreference(
        merchantName: _merchantController.text,
        categoryId: _selectedCategoryId!,
        accountId: _selectedAccountId!,
      ));

      debugPrint('Spendly: Save successful');

      if (!mounted) return;
      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      debugPrint('Spendly: Save failed with error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.expense),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
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
            _buildField(
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
                  child: _buildField(
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
                  child: _buildField(
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
            _buildField(
              icon: Icons.payments,
              label: 'Total Amount',
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              trailing: GestureDetector(
                onTap: _showCurrencyPicker,
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _selectedCurrency,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.primary),
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
              data: (accs) {
                final selectedAccount = accs.where((a) => a.id == _selectedAccountId).firstOrNull;
                final isMismatch = selectedAccount != null && selectedAccount.currency != _selectedCurrency;
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDropdown<String>(
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
                                    '${(balance / 100).toStringAsFixed(2)} ${a.currency}',
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
                      onChanged: (val) {
                        setState(() {
                          _selectedAccountId = val;
                          final account = accs.firstWhere((a) => a.id == val);
                          _selectedCurrency = account.currency;
                        });
                      },
                    ),
                    if (isMismatch) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.expense.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: AppColors.expense, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Currency Mismatch: Account is in ${selectedAccount.currency}, but Receipt is in $_selectedCurrency.',
                                style: const TextStyle(color: AppColors.expense, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                            TextButton(
                              onPressed: _applyExchangeRate,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text('CONVERT', style: TextStyle(color: AppColors.expense, fontSize: 11, fontWeight: FontWeight.w900)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (err, stack) => const Text('Error loading accounts'),
            ),
            const SizedBox(height: 16),

            // Conversion Summary (If applied)
            if (_currentExchangeRate != 1.0) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('CONVERSION SUMMARY', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.1, color: AppColors.primary)),
                        GestureDetector(
                          onTap: () => setState(() {
                            _currentExchangeRate = 1.0;
                            _amountController.text = _originalTotal.toStringAsFixed(2);
                            _subtotalController.text = _originalSubtotal.toStringAsFixed(2);
                            _taxController.text = _originalTax.toStringAsFixed(2);
                            _selectedCurrency = _originalCurrency;
                          }),
                          child: const Icon(Icons.close, size: 14, color: AppColors.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryRow('Original Total', '${_originalTotal.toStringAsFixed(2)} $_originalCurrency'),
                    _buildSummaryRow('Exchange Rate', 'x ${_currentExchangeRate.toStringAsFixed(4)}'),
                    const Divider(height: 16),
                    _buildSummaryRow('Converted Total', '${(double.tryParse(_amountController.text) ?? 0.0).toStringAsFixed(2)} $_selectedCurrency', isBold: true),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

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
            _buildField(
              label: 'Address',
              controller: _addressController,
              icon: Icons.location_on_outlined,
              confidence: widget.receipt.address != null ? widget.receipt.confidence : 1.0,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildField(
                    label: 'Phone',
                    controller: _phoneController,
                    icon: Icons.phone_outlined,
                    confidence: widget.receipt.phone != null ? widget.receipt.confidence : 1.0,
                    keyboardType: TextInputType.phone,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildField(
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
                  child: _buildField(
                    label: 'Payment Method',
                    controller: _paymentMethodController,
                    icon: Icons.payment_outlined,
                    confidence: widget.receipt.paymentMethod != null ? widget.receipt.confidence : 1.0,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildField(
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
                onPressed: _isSaving ? null : _saveTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                ),
                child: _isSaving 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Confirm & Save', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                  '${(item.amount / 100).toStringAsFixed(2)} $_selectedCurrency',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool dense = false,
    Widget? trailing,
    double confidence = 1.0,
  }) {
    Color borderColor = AppColors.primary.withValues(alpha: 0.1);
    Color? bgColor = Colors.white;

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
        if (!dense) ...[
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: AppColors.textLight,
              fontWeight: FontWeight.w900,
              fontSize: 10,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: confidence < 0.8 ? 2 : 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
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
              ?trailing,
            ],
          ),
        ),
      ],
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
            const Text('Enter the exchange rate to multiply the amounts by (e.g., 150.0 for USD to HTG).', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
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
      final userId = ref.read(authStateProvider).value?.uid;
      final accounts = ref.read(accountsStreamProvider(userId ?? '')).value;
      final account = accounts?.firstWhere((a) => a.id == _selectedAccountId);

      setState(() {
        _currentExchangeRate = result;
        
        // Derive from originals to prevent stacking
        final total = _originalTotal * _currentExchangeRate;
        final subtotal = _originalSubtotal * _currentExchangeRate;
        final tax = _originalTax * _currentExchangeRate;
        
        _amountController.text = total.toStringAsFixed(2);
        _subtotalController.text = subtotal.toStringAsFixed(2);
        _taxController.text = tax.toStringAsFixed(2);

        // Automatically switch currency to match account if we converted
        if (account != null) {
          _selectedCurrency = account.currency;
        }
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Converted using rate: $result. Currency set to $_selectedCurrency')),
        );
      }
    }
  }

  Widget _buildDatePicker({required double confidence}) {
    Color borderColor = AppColors.primary.withValues(alpha: 0.1);
    Color? bgColor = Colors.white;

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
        const Text(
          'DATE',
          style: TextStyle(
            color: AppColors.textLight,
            fontWeight: FontWeight.w900,
            fontSize: 10,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
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
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: confidence < 0.8 ? 2 : 1),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: AppColors.primary, size: 24),
                const SizedBox(width: 16),
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
                ...['USD', 'HTG', 'EUR', 'CAD'].map((c) {
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

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: AppColors.textLight, fontSize: 12))),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.w900 : FontWeight.bold,
              fontSize: 12,
              color: AppColors.textDark,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
