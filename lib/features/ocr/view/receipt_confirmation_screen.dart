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
import 'package:spendly/features/ocr/repository/financial_intelligence_repository.dart';
import 'package:spendly/features/ocr/view/receipt_viewer_screen.dart';
import 'package:spendly/core/providers/firebase_providers.dart';
import 'package:spendly/core/providers/currency_provider.dart';
import 'package:spendly/core/providers/exchange_rate_provider.dart';
import 'package:spendly/features/budget/repository/category_repository.dart';
import 'package:spendly/core/models/category.dart' as model;
import 'package:uuid/uuid.dart';

class ReceiptConfirmationScreen extends ConsumerStatefulWidget {
  final Receipt receipt;
  const ReceiptConfirmationScreen({super.key, required this.receipt});

  @override
  ConsumerState<ReceiptConfirmationScreen> createState() =>
      _ReceiptConfirmationScreenState();
}

class _ReceiptConfirmationScreenState
    extends ConsumerState<ReceiptConfirmationScreen> {
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
  List<ReceiptItem> _editableItems = [];

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
    _originalTotal = (widget.receipt.total != null
        ? widget.receipt.total! / 100
        : 0.0);
    _originalSubtotal = (widget.receipt.subtotal != null
        ? widget.receipt.subtotal! / 100
        : 0.0);
    _originalTax = (widget.receipt.tax != null
        ? widget.receipt.tax! / 100
        : 0.0);
    _originalCurrency = widget.receipt.originalCurrency ?? 'USD';

    _amountController = TextEditingController(
      text: _originalTotal.toStringAsFixed(2),
    );
    _subtotalController = TextEditingController(
      text: _originalSubtotal.toStringAsFixed(2),
    );
    _taxController = TextEditingController(
      text: _originalTax.toStringAsFixed(2),
    );

    _addressController = TextEditingController(text: widget.receipt.address);
    _phoneController = TextEditingController(text: widget.receipt.phone);
    _emailController = TextEditingController(text: widget.receipt.email);
    _paymentMethodController = TextEditingController(
      text: widget.receipt.paymentMethod,
    );
    _receiptNumberController = TextEditingController(
      text: widget.receipt.receiptNumber,
    );
    _selectedDate = widget.receipt.date ?? DateTime.now();
    _editableItems = List.from(widget.receipt.items ?? []);

    // Merchant Memory: Auto-select category/account
    _loadMerchantPreferences();
  }

  Future<void> _loadMerchantPreferences() async {
    if (widget.receipt.merchant == null) return;

    final userId = ref.read(authRepositoryProvider).currentUser?.uid ?? '';
    final pref = await ref
        .read(merchantRepositoryProvider)
        .getPreference(userId, widget.receipt.merchant!);

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid amount')));
      return;
    }

    final userId = ref.read(authStateProvider).value?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User not authenticated')));
      return;
    }

    setState(() => _isSaving = true);
    debugPrint('Spendly: Starting save for userId: $userId');

    // Duplicate Detection (Enhanced)
    final existingTransactions =
        ref.read(transactionsStreamProvider(userId)).value ?? [];
    
    // Use the normalized merchant name for more accurate matching
    final targetMerchant = _merchantController.text.trim().toLowerCase();
    
    final isDuplicate = existingTransactions.any(
      (t) {
        final sameAmount = t.amount == amount.round();
        
        // Check for same day or adjacent days (to handle processing delays)
        final dateDiff = t.date.difference(_selectedDate!).inDays.abs();
        final sameDateWindow = dateDiff <= 1;
        
        final sameMerchant = t.note?.toLowerCase().contains(targetMerchant) == true ||
                             targetMerchant.contains(t.note?.toLowerCase() ?? '');
        
        return sameAmount && sameDateWindow && sameMerchant;
      },
    );

    if (isDuplicate) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Possible Duplicate'),
          content: const Text(
            'A transaction with this amount and merchant already exists for today. Save anyway?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('SAVE'),
            ),
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
    final selectedAccount = accounts?.firstWhere(
      (a) => a.id == _selectedAccountId,
    );

    if (selectedAccount != null &&
        selectedAccount.currency != _selectedCurrency) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Currency Mismatch! Account is in ${selectedAccount.currency}, but Receipt is in $_selectedCurrency. Please convert or change account.',
          ),
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
      final subtotalCents =
          (double.tryParse(_subtotalController.text) ?? 0.0) * 100;
      final taxCents = (double.tryParse(_taxController.text) ?? 0.0) * 100;

      // Update the Receipt record with corrected values and audit info
      final correctedReceipt = widget.receipt.copyWith(
        merchant: _merchantController.text,
        total: totalCents,
        subtotal: subtotalCents.round(),
        tax: taxCents.round(),
        date: _selectedDate,
        address: _addressController.text.isNotEmpty
            ? _addressController.text
            : null,
        phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
        email: _emailController.text.isNotEmpty ? _emailController.text : null,
        paymentMethod: _paymentMethodController.text.isNotEmpty
            ? _paymentMethodController.text
            : null,
        receiptNumber: _receiptNumberController.text.isNotEmpty
            ? _receiptNumberController.text
            : null,
        processed: true,
        items: _editableItems,
        // Audit fields
        originalTotal: (_originalTotal * 100).round(),
        originalSubtotal: (_originalSubtotal * 100).round(),
        originalTax: (_originalTax * 100).round(),
        originalCurrency: _originalCurrency,
        exchangeRate: _currentExchangeRate,
      );

      await ref.read(receiptRepositoryProvider).saveReceipt(correctedReceipt);

      final baseCurrency = ref.read(currencyProvider);
      final double rateToBase = ref.read(
        exchangeRateProvider((userId: userId, from: _selectedCurrency, to: baseCurrency)),
      );

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
        scaledRate: (rateToBase * rateScale)
            .round(), // Rate from account to base
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
      await ref
          .read(merchantRepositoryProvider)
          .savePreference(
            userId,
            MerchantPreference(
              merchantName: _merchantController.text,
              categoryId: _selectedCategoryId!,
              accountId: _selectedAccountId!,
            ),
          );

      try {
        await ref
            .read(financialIntelligenceRepositoryProvider)
            .recordConfirmedReceipt(
              userId: userId,
              originalReceipt: widget.receipt,
              correctedReceipt: correctedReceipt,
              categoryId: _selectedCategoryId!,
              accountId: _selectedAccountId!,
              currency: _selectedCurrency,
            );
      } catch (e) {
        debugPrint('Spendly: Receipt learning update failed: $e');
      }

      debugPrint('Spendly: Save successful');

      if (!mounted) return;
      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      debugPrint('Spendly: Save failed with error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.expense,
        ),
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
        title: const Text(
          'Confirm Details',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textDark,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            tooltip: 'RETRY',
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _saveTransaction,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              shadowColor: AppColors.primary.withValues(alpha: 0.4),
            ),
            child: _isSaving
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'Confirm & Save',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.receipt.archetype != null)
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.psychology, size: 14, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      'ARCHETYPE: ${widget.receipt.archetype!.toUpperCase()}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            // Receipt Preview Card
            GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ReceiptViewerScreen(
                    imageUrl: widget.receipt.imageUrl,
                    merchantName: widget.receipt.merchant,
                    receiptId: widget.receipt.id,
                  ),
                ),
              ),
              child: Hero(
                tag: widget.receipt.imageUrl,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    image: DecorationImage(
                      image: NetworkImage(widget.receipt.imageUrl),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withValues(alpha: 0.1),
                        BlendMode.darken,
                      ),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.fullscreen,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),

            _sectionHeader('MERCHANT & AMOUNTS'),
            _buildCard(
              children: [
                _buildField(
                  label: 'Merchant',
                  controller: _merchantController,
                  icon: Icons.store_rounded,
                  confidence: widget.receipt.fieldConfidences?['merchant'] ??
                      (widget.receipt.merchant != null ? 0.9 : 0.0),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildField(
                        label: 'Subtotal',
                        controller: _subtotalController,
                        icon: Icons.summarize_outlined,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        confidence: widget.receipt.fieldConfidences?['subtotal'] ?? 1.0,
                        dense: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildField(
                        label: 'Tax',
                        controller: _taxController,
                        icon: Icons.receipt_outlined,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        confidence: widget.receipt.fieldConfidences?['tax'] ?? 1.0,
                        dense: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildField(
                  icon: Icons.payments_rounded,
                  label: 'Total Amount',
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  confidence: widget.receipt.fieldConfidences?['total'] ?? 0.8,
                  trailing: GestureDetector(
                    onTap: _showCurrencyPicker,
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Text(
                            _selectedCurrency,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                            ),
                          ),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildDatePicker(
                  confidence: widget.receipt.fieldConfidences?['date'] ?? 0.8,
                ),
              ],
            ),
            const SizedBox(height: 28),

            _sectionHeader('TRANSACTION DETAILS'),
            _buildCard(
              children: [
                accounts.when(
                  data: (accs) {
                    final selectedAccount = accs
                        .where((a) => a.id == _selectedAccountId)
                        .firstOrNull;
                    final isMismatch =
                        selectedAccount != null &&
                        selectedAccount.currency != _selectedCurrency;

                    return Column(
                      children: [
                        _buildDropdown<String>(
                          label: 'Account',
                          value: _selectedAccountId,
                          items: accs.map((a) {
                            return DropdownMenuItem(
                              value: a.id,
                              child: Consumer(
                                builder: (context, ref, _) {
                                  final balance = ref.watch(
                                    accountBalanceProvider((
                                      userId: userId,
                                      accountId: a.id,
                                    )),
                                  );
                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        a.name,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      Text(
                                        '${(balance / 100).toStringAsFixed(2)} ${a.currency}',
                                        style: const TextStyle(
                                          color: AppColors.textLight,
                                          fontSize: 11,
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
                              final account = accs.firstWhere(
                                (a) => a.id == val,
                              );
                              _selectedCurrency = account.currency;
                            });
                          },
                        ),
                        if (isMismatch) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.expense.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.expense.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline_rounded,
                                  color: AppColors.expense,
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: Text(
                                    'Currency Mismatch',
                                    style: TextStyle(
                                      color: AppColors.expense,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: _applyExchangeRate,
                                  child: const Text(
                                    'CONVERT',
                                    style: TextStyle(
                                      color: AppColors.expense,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
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
                const SizedBox(height: 20),
                budgetState.when(
                  data: (state) => _buildDropdown<String>(
                    label: 'Category',
                    value: _selectedCategoryId,
                    items: state.items
                        .map(
                          (i) => DropdownMenuItem(
                            value: i.category.id,
                            child: Text(i.category.name),
                          ),
                        )
                        .toList(),
                    onChanged: (val) =>
                        setState(() => _selectedCategoryId = val),
                    onAddPressed: () => _showCreateCategoryDialog(userId),
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (err, stack) => const Text('Error loading categories'),
                ),
              ],
            ),
            const SizedBox(height: 28),

            _sectionHeader('LINE ITEMS'),
            _buildLineItems(),
            const SizedBox(height: 28),

            _sectionHeader('RECEIPT DETAILS'),
            _buildCard(
              children: [
                _buildField(
                  label: 'Address',
                  controller: _addressController,
                  icon: Icons.location_on_rounded,
                  confidence: widget.receipt.address != null
                      ? widget.receipt.confidence
                      : 1.0,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildField(
                        label: 'Phone',
                        controller: _phoneController,
                        icon: Icons.phone_rounded,
                        confidence: widget.receipt.phone != null
                            ? widget.receipt.confidence
                            : 1.0,
                        keyboardType: TextInputType.phone,
                        dense: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildField(
                        label: 'Email',
                        controller: _emailController,
                        icon: Icons.email_rounded,
                        confidence: widget.receipt.email != null
                            ? widget.receipt.confidence
                            : 1.0,
                        keyboardType: TextInputType.emailAddress,
                        dense: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildField(
                        label: 'Payment',
                        controller: _paymentMethodController,
                        icon: Icons.credit_card_rounded,
                        confidence: widget.receipt.paymentMethod != null
                            ? widget.receipt.confidence
                            : 1.0,
                        dense: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildField(
                        label: 'Receipt #',
                        controller: _receiptNumberController,
                        icon: Icons.tag_rounded,
                        confidence: widget.receipt.receiptNumber != null
                            ? widget.receipt.confidence
                            : 1.0,
                        dense: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.textLight,
          fontWeight: FontWeight.w900,
          fontSize: 11,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildLineItems() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              if (_editableItems.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'No items detected',
                    style: TextStyle(color: AppColors.textLight, fontSize: 13),
                  ),
                ),
              ..._editableItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isLast = index == _editableItems.length - 1;

                return InkWell(
                  onTap: () => _showEditItemDialog(index),
                  borderRadius: isLast
                      ? const BorderRadius.vertical(bottom: Radius.circular(24))
                      : index == 0
                          ? const BorderRadius.vertical(top: Radius.circular(24))
                          : BorderRadius.zero,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: isLast
                          ? null
                          : Border(
                              bottom: BorderSide(
                                color: AppColors.primary.withValues(alpha: 0.05),
                              ),
                            ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.shopping_bag_outlined,
                            color: AppColors.primary,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.description,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (item.quantity != null)
                                Text(
                                  'Qty: ${item.quantity} × ${( (item.unitPrice ?? item.amount) / 100).toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: AppColors.textLight,
                                    fontSize: 11,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          (item.amount / 100).toStringAsFixed(2),
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: AppColors.textDark,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _selectedCurrency,
                          style: const TextStyle(
                            color: AppColors.textLight,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.edit_note_rounded,
                          color: AppColors.textLight,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton.icon(
            onPressed: _showAddItemDialog,
            icon: const Icon(Icons.add_circle_outline, size: 18),
            label: const Text(
              'ADD ITEM',
              style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
            ),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  void _showEditItemDialog(int index) async {
    final item = _editableItems[index];
    final descController = TextEditingController(text: item.description);
    final qtyController = TextEditingController(text: item.quantity?.toString() ?? '1');
    final priceController = TextEditingController(
      text: ((item.unitPrice ?? item.amount) / 100).toStringAsFixed(2),
    );

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Item', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: qtyController,
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: priceController,
                    decoration: const InputDecoration(labelText: 'Unit Price'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _editableItems.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: const Text('DELETE', style: TextStyle(color: AppColors.expense)),
          ),
          const Spacer(),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, 'save'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('SAVE'),
          ),
        ],
      ),
    );

    if (result == 'save') {
      final qty = int.tryParse(qtyController.text) ?? 1;
      final unitPrice = (double.tryParse(priceController.text) ?? 0.0) * 100;
      final total = (qty * unitPrice).round();

      setState(() {
        _editableItems[index] = item.copyWith(
          description: descController.text.trim(),
          quantity: qty,
          unitPrice: unitPrice.round(),
          amount: total,
        );
      });
    }
  }

  void _showAddItemDialog() async {
    final descController = TextEditingController();
    final qtyController = TextEditingController(text: '1');
    final priceController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Item', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
              textCapitalization: TextCapitalization.words,
              autofocus: true,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: qtyController,
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: priceController,
                    decoration: const InputDecoration(labelText: 'Price'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('ADD'),
          ),
        ],
      ),
    );

    if (result == true && descController.text.isNotEmpty) {
      final qty = int.tryParse(qtyController.text) ?? 1;
      final price = (double.tryParse(priceController.text) ?? 0.0) * 100;

      setState(() {
        _editableItems.add(ReceiptItem(
          description: descController.text.trim(),
          quantity: qty,
          unitPrice: price.round(),
          amount: (qty * price).round(),
        ));
      });
    }
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
            border: Border.all(
              color: borderColor,
              width: confidence < 0.8 ? 2 : 1,
            ),
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
                    prefixIcon: Icon(
                      icon,
                      color: AppColors.primary,
                      size: dense ? 18 : 24,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: dense ? 8 : 12,
                    ),
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

  void _showCreateCategoryDialog(String userId) async {
    final nameController = TextEditingController();
    final groupController = TextEditingController(text: 'General');
    final targetController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'New Category',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Category Name',
                hintText: 'e.g. Groceries',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: groupController,
              decoration: const InputDecoration(
                labelText: 'Group',
                hintText: 'e.g. Food, Transport',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: targetController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Monthly Target (Optional)',
                hintText: '0.00',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('CREATE'),
          ),
        ],
      ),
    );

    if (result == true && nameController.text.isNotEmpty) {
      try {
        final target = (double.tryParse(targetController.text) ?? 0.0) * 100;
        final newCategory = model.Category(
          id: '', // Will be set by Firestore
          userId: userId,
          name: nameController.text.trim(),
          group: groupController.text.trim(),
          monthlyTarget: target > 0 ? target.round() : null,
          currency: _selectedCurrency,
        );

        await ref.read(categoryRepositoryProvider).addCategory(newCategory);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Category "${newCategory.name}" created!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create category: $e'),
              backgroundColor: AppColors.expense,
            ),
          );
        }
      }
    }
  }

  void _applyExchangeRate() async {
    final rateController = TextEditingController();
    final result = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Exchange Rate',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter the exchange rate to multiply the amounts by (e.g., 150.0 for USD to HTG).',
              style: TextStyle(fontSize: 12, color: AppColors.textLight),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: rateController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Rate',
                border: OutlineInputBorder(),
                hintText: '1.0',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(context, double.tryParse(rateController.text)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
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
          SnackBar(
            content: Text(
              'Converted using rate: $result. Currency set to $_selectedCurrency',
            ),
          ),
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
              border: Border.all(
                color: borderColor,
                width: confidence < 0.8 ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Text(
                  _selectedDate != null
                      ? DateFormat('MMM dd, yyyy').format(_selectedDate!)
                      : 'Select Date',
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
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                ...['USD', 'HTG', 'EUR', 'CAD'].map((c) {
                  final isSelected = c == _selectedCurrency;
                  return ListTile(
                    title: Text(
                      c,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.w900
                            : FontWeight.bold,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textDark,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check, color: AppColors.primary)
                        : null,
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
    VoidCallback? onAddPressed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                color: AppColors.textLight,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
              ),
            ),
            if (onAddPressed != null)
              GestureDetector(
                onTap: onAddPressed,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.add, size: 14, color: AppColors.primary),
                      SizedBox(width: 4),
                      Text(
                        'NEW',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(width: 4),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              items: items,
              onChanged: onChanged,
              isExpanded: true,
              hint: Text('Select $label'),
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.primary,
              ),
              style: const TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ],
    );
  }
}
