import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/shared/themes/app_theme.dart';
import 'package:spendly/core/models/bill.dart';
import 'package:spendly/core/models/app_transaction.dart';
import 'package:spendly/features/accounts/repository/account_repository.dart';
import 'package:spendly/features/transactions/repository/transaction_repository.dart';
import 'package:spendly/core/providers/currency_provider.dart';
import 'package:spendly/features/ocr/repository/receipt_repository.dart';
import 'package:spendly/core/providers/firebase_providers.dart';
import 'package:spendly/core/providers/exchange_rate_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';

class MarkPaidSheet extends ConsumerStatefulWidget {
  final Bill bill;
  final String userId;

  const MarkPaidSheet({super.key, required this.bill, required this.userId});

  @override
  ConsumerState<MarkPaidSheet> createState() => _MarkPaidSheetState();
}

class _MarkPaidSheetState extends ConsumerState<MarkPaidSheet> {
  String? _selectedAccountId;
  DateTime _paymentDate = DateTime.now();
  late TextEditingController _amountController;
  late TextEditingController _rateController;
  bool _isLoading = false;
  File? _imageFile;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final remaining = widget.bill.amount - widget.bill.paidAmount;
    _amountController = TextEditingController(
      text: (remaining / 100).toStringAsFixed(2),
    );
    _rateController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsStreamProvider(widget.userId));
    final remaining = widget.bill.amount - widget.bill.paidAmount;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(28),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
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

              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.payments_outlined,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mark as Paid',
                          style: TextStyle(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          widget.bill.title,
                          style: const TextStyle(
                            color: AppColors.textLight,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Amount field — always denominated in the plan's currency
              _fieldLabel('AMOUNT  (${widget.bill.currency})'),
              const SizedBox(height: 8),
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: _inputDecoration('0.00', prefixText: '${widget.bill.currency} '),
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                ),
              ),
              if (widget.bill.paidAmount > 0) ...[
                const SizedBox(height: 6),
                Text(
                  'Remaining: ${widget.bill.currency} ${(remaining / 100).toStringAsFixed(2)} of ${widget.bill.currency} ${(widget.bill.amount / 100).toStringAsFixed(2)}',
                  style: const TextStyle(color: AppColors.textLight, fontSize: 11),
                ),
              ],
              // Cross-currency notice
              Builder(builder: (context) {
                final accounts = ref.watch(accountsStreamProvider(widget.userId)).value ?? [];
                final selectedAcc = accounts.where((a) => a.id == _selectedAccountId).firstOrNull;
                if (selectedAcc != null && selectedAcc.currency != widget.bill.currency) {
                  final billAmt = double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0;
                  final userRate = double.tryParse(_rateController.text.replaceAll(',', '')) ?? 0;
                  final accountAmt = userRate > 0 ? billAmt * userRate : null;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 12),
                        child: Container(
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
                                  'Cross-currency payment: ${widget.bill.currency} → ${selectedAcc.currency}. Enter the exchange rate you used.',
                                  style: const TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      _fieldLabel('EXCHANGE RATE  (1 ${widget.bill.currency} = ? ${selectedAcc.currency})'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _rateController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: _inputDecoration(
                          'e.g. 135.00',
                          prefixText: '1 ${widget.bill.currency} = ',
                        ),
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      if (accountAmt != null && accountAmt > 0) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.income.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.account_balance_wallet_outlined, size: 14, color: AppColors.income),
                              const SizedBox(width: 8),
                              Text(
                                '≈ ${selectedAcc.currency} ${accountAmt.toStringAsFixed(2)} will leave your account',
                                style: const TextStyle(color: AppColors.income, fontWeight: FontWeight.w900, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ] else if (userRate == 0) ...[
                        const SizedBox(height: 6),
                        const Text(
                          '⚠ Exchange rate is required to proceed.',
                          style: TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                      const SizedBox(height: 16),
                    ],
                  );
                }
                return const SizedBox.shrink();
              }),

              const SizedBox(height: 20),

              // Pay from account
              _fieldLabel('PAY FROM'),
              const SizedBox(height: 8),
              accountsAsync.when(
                data: (accounts) {
                  if (_selectedAccountId == null && accounts.isNotEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(() => _selectedAccountId = accounts.first.id);
                      }
                    });
                  }
                  return DropdownButtonFormField<String>(
                    initialValue: _selectedAccountId,
                    decoration: _inputDecoration('Select account'),
                    items: accounts
                        .map(
                          (acc) => DropdownMenuItem(
                            value: acc.id,
                            child: Text(
                              '${acc.name}  (${acc.currency})',
                              style: const TextStyle(
                                color: AppColors.textDark,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (id) => setState(() => _selectedAccountId = id),
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Error loading accounts: $e'),
              ),

              const SizedBox(height: 20),

              // Date
              _fieldLabel('DATE'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.primaryLight),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        color: AppColors.textLight,
                        size: 18,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${_paymentDate.day}/${_paymentDate.month}/${_paymentDate.year}',
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Proof of Payment
              _fieldLabel('PROOF OF PAYMENT (OPTIONAL)'),
              const SizedBox(height: 8),
              if (_imageFile != null)
                Stack(
                  children: [
                    Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        image: DecorationImage(
                          image: FileImage(_imageFile!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => setState(() => _imageFile = null),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
                )
              else
                OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.camera_alt_outlined, size: 18),
                  label: const Text('ATTACH RECEIPT OR CHECK'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primaryLight),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),

              const SizedBox(height: 28),

              // Confirm Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _confirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'CONFIRM PAYMENT',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                            fontSize: 14,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.textLight,
        fontWeight: FontWeight.w900,
        fontSize: 10,
        letterSpacing: 1.4,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, {String? prefixText}) {
    return InputDecoration(
      hintText: hint,
      prefixText: prefixText,
      hintStyle: const TextStyle(color: AppColors.textLight),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primaryLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primaryLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _paymentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _paymentDate = picked);
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() => _imageFile = File(pickedFile.path));
      }
    }
  }

  Future<void> _confirm() async {
    final amountText = _amountController.text.replaceAll(',', '');
    final amount = (double.tryParse(amountText) ?? 0) * 100;
    if (amount <= 0 || _selectedAccountId == null) return;
    final amountCents = amount.round();

    setState(() => _isLoading = true);
    try {
      final txRepo = ref.read(transactionRepositoryProvider);
      final accounts = ref.read(accountsStreamProvider(widget.userId)).value ?? [];
      final selectedAccount = accounts.firstWhere((a) => a.id == _selectedAccountId);
      final receiptRepo = ref.read(receiptRepositoryProvider);
      const uuid = Uuid();

      // 1. Fetch search tokens from receipt if it exists
      List<String>? deepSearchTokens;
      if (widget.bill.receiptId != null) {
        final receipt = await receiptRepo.getReceiptById(
          widget.bill.receiptId!,
        );
        deepSearchTokens = receipt?.extractedTokens;
      }

      // 2. Upload image if exists
      String? imageUrl;
      if (_imageFile != null) {
        final storage = ref.read(storageProvider);
        final refStorage = storage.ref().child('receipts/${widget.userId}/${uuid.v4()}.jpg');
        await refStorage.putFile(_imageFile!);
        imageUrl = await refStorage.getDownloadURL();
      }

      // 3. Create the linked transaction
      final txId = uuid.v4();
      final baseCurrency = ref.read(currencyProvider);
      final isCrossCurrency = selectedAccount.currency != widget.bill.currency;

      // Bill amount: always in the bill's currency — used to track obligation progress
      final billAmountCents = amountCents;

      // Account amount: what actually leaves the account
      // If same currency: identical. If cross-currency: bill amount × user-entered rate
      late final int accountAmountCents;
      late final double rate;
      if (isCrossCurrency) {
        rate = double.tryParse(_rateController.text.replaceAll(',', '')) ?? 1.0;
        if (rate <= 0) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please enter the exchange rate to continue.')),
            );
          }
          return;
        }
        accountAmountCents = (billAmountCents * rate).round();
      } else {
        rate = 1.0;
        accountAmountCents = billAmountCents;
      }

      // Normalize to base currency
      final rateToBase = ref.read(exchangeRateProvider((userId: widget.userId, from: selectedAccount.currency, to: baseCurrency)));
      const int rateScale = 1000000;
      final int scaledRateToBase = (rateToBase * rateScale).round();
      final int normalizedAmount = (accountAmountCents * scaledRateToBase) ~/ rateScale;

      final tx = AppTransaction(
        id: txId,
        userId: widget.userId,
        type: 'expense',
        amount: accountAmountCents,       // what leaves the account
        currency: selectedAccount.currency,
        amountInBaseCurrency: normalizedAmount,
        baseCurrency: baseCurrency,
        exchangeRate: isCrossCurrency ? rate : rateToBase,
        scaledRate: scaledRateToBase,
        rateScale: rateScale,
        rateSource: 'manual',
        rateBaseCurrency: widget.bill.currency,
        rateQuoteCurrency: selectedAccount.currency,
        date: _paymentDate,
        accountId: selectedAccount.id,
        categoryId: widget.bill.categoryId,
        note: 'Payment: ${widget.bill.title}',
        receiptId: widget.bill.receiptId,
        receiptUrl: imageUrl,
        searchTokens: deepSearchTokens,
      );

      // Atomic write: bill progress tracked in bill's currency, account debited in account's currency
      await txRepo.payBill(
        transaction: tx,
        bill: widget.bill,
        amountCents: billAmountCents, // bill progress in bill's own currency
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.expense,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
