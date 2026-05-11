import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/shared/themes/app_theme.dart';
import 'package:spendly/core/models/bill.dart';
import 'package:spendly/core/models/app_transaction.dart';
import 'package:spendly/core/models/account.dart';
import 'package:spendly/features/accounts/repository/account_repository.dart';
import 'package:spendly/features/transactions/repository/transaction_repository.dart';
import 'package:spendly/core/providers/currency_provider.dart';
import 'package:spendly/features/ocr/repository/receipt_repository.dart';
import 'package:uuid/uuid.dart';

class MarkPaidSheet extends ConsumerStatefulWidget {
  final Bill bill;
  final String userId;

  const MarkPaidSheet({super.key, required this.bill, required this.userId});

  @override
  ConsumerState<MarkPaidSheet> createState() => _MarkPaidSheetState();
}

class _MarkPaidSheetState extends ConsumerState<MarkPaidSheet> {
  Account? _selectedAccount;
  DateTime _paymentDate = DateTime.now();
  late TextEditingController _amountController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final remaining = widget.bill.amount - widget.bill.paidAmount;
    _amountController = TextEditingController(
      text: (remaining / 100).toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
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
        child: Padding(
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

              // Amount field
              _fieldLabel('AMOUNT'),
              const SizedBox(height: 8),
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: _inputDecoration('0.00', prefixText: '\$ '),
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                ),
              ),
              if (widget.bill.paidAmount > 0) ...[
                const SizedBox(height: 6),
                Text(
                  'Remaining: \$${(remaining / 100).toStringAsFixed(2)} of \$${(widget.bill.amount / 100).toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontSize: 11,
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // Pay from account
              _fieldLabel('PAY FROM'),
              const SizedBox(height: 8),
              accountsAsync.when(
                data: (accounts) {
                  if (_selectedAccount == null && accounts.isNotEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(() => _selectedAccount = accounts.first);
                      }
                    });
                  }
                  return DropdownButtonFormField<Account>(
                    initialValue: _selectedAccount,
                    decoration: _inputDecoration('Select account'),
                    items: accounts
                        .map(
                          (acc) => DropdownMenuItem(
                            value: acc,
                            child: Text(
                              acc.name,
                              style: const TextStyle(
                                color: AppColors.textDark,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (acc) => setState(() => _selectedAccount = acc),
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

  Future<void> _confirm() async {
    final amountText = _amountController.text.replaceAll(',', '');
    final amount = (double.tryParse(amountText) ?? 0) * 100;
    if (amount <= 0 || _selectedAccount == null) return;
    final amountCents = amount.round();

    setState(() => _isLoading = true);
    try {
      final txRepo = ref.read(transactionRepositoryProvider);
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

      // 2. Create the linked transaction
      final txId = uuid.v4();
      final baseCurrency = ref.read(currencyProvider);
      const double rate = 1.0; // TODO: Implement real-time rate lookup
      
      // Rule #2: Scaled Integer Math
      const int rateScale = 1000000;
      final int scaledRate = (rate * rateScale).round();
      final int normalizedAmount = (amountCents * scaledRate) ~/ rateScale;

      final tx = AppTransaction(
        id: txId,
        userId: widget.userId,
        type: 'expense',
        amount: amountCents,
        currency: _selectedAccount!.currency,
        amountInBaseCurrency: normalizedAmount,
        baseCurrency: baseCurrency,
        exchangeRate: rate,
        scaledRate: scaledRate,
        rateScale: rateScale,
        rateSource: 'manual',
        rateBaseCurrency: baseCurrency,
        rateQuoteCurrency: _selectedAccount!.currency,
        date: _paymentDate,
        accountId: _selectedAccount!.id,
        categoryId: widget.bill.categoryId,
        note: 'Payment: ${widget.bill.title}',
        receiptId: widget.bill.receiptId,
        searchTokens: deepSearchTokens, // Optimized for universal search
      );

      // Atomic write across Transaction, Bill, and Account
      await txRepo.payBill(
        transaction: tx,
        bill: widget.bill,
        amountCents: amountCents,
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
