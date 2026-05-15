import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/shared/themes/app_theme.dart';
import 'package:spendly/core/models/allocation_event.dart';
import 'package:spendly/core/models/category.dart';
import 'package:spendly/features/transactions/repository/transaction_repository.dart';
import 'package:spendly/features/budget/repository/category_repository.dart';
import 'package:spendly/core/providers/firebase_providers.dart';
import 'package:spendly/core/providers/date_provider.dart';
import 'package:spendly/core/providers/app_user_provider.dart';
import 'package:intl/intl.dart';
import 'package:spendly/core/providers/exchange_rate_provider.dart';
import 'package:uuid/uuid.dart';

class AllocationBottomSheet extends ConsumerStatefulWidget {
  final Category? initialTarget;
  final int? maxAmount;

  const AllocationBottomSheet({
    super.key,
    this.initialTarget,
    this.maxAmount,
  });

  @override
  ConsumerState<AllocationBottomSheet> createState() => _AllocationBottomSheetState();
}

class _AllocationBottomSheetState extends ConsumerState<AllocationBottomSheet> {
  final _amountController = TextEditingController();
  Category? _selectedCategory;
  String? _selectedCurrency;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialTarget;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_selectedCategory == null) return;
    
    final amountText = _amountController.text.replaceAll(',', '');
    final amountInput = double.tryParse(amountText) ?? 0;
    if (amountInput <= 0) return;

    setState(() => _isSaving = true);

    try {
      final userId = ref.read(authStateProvider).value?.uid ?? '';
      final appUser = ref.read(appUserStreamProvider(userId)).value;
      final baseCurrency = appUser?.baseCurrency ?? 'USD';
      final currency = _selectedCurrency ?? baseCurrency;

      // 1. Convert to Base Currency Cents (Accounting Truth)
      int amountCents;
      if (currency == baseCurrency) {
        amountCents = (amountInput * 100).toInt();
      } else {
        final rate = ref.read(exchangeRateProvider((
          userId: userId,
          from: currency,
          to: baseCurrency,
        )));
        
        // Use the same scaled logic for consistency
        const scale = 1000000;
        final scaledRate = (rate * scale).round();
        final rawCents = (amountInput * 100).toInt();
        amountCents = (rawCents * scaledRate) ~/ scale;
      }
      
      if (amountCents <= 0) {
        throw Exception('Converted amount too small to move');
      }

      final selectedDate = ref.read(selectedDateProvider);
      final monthId = DateFormat('yyyy_MM').format(selectedDate);

      final event = AllocationEvent(
        id: const Uuid().v4(),
        userId: userId,
        amount: amountCents,
        fromEntityId: 'ReadyToAssign',
        toEntityId: _selectedCategory!.id,
        monthId: monthId,
        timestamp: DateTime.now(),
      );

      await ref.read(transactionRepositoryProvider).addAllocationEvent(event);
      
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(authStateProvider).value?.uid ?? '';
    final categoriesAsync = ref.watch(categoriesStreamProvider(userId));
    final appUserAsync = ref.watch(appUserStreamProvider(userId));

    // Default to base currency once loaded
    if (_selectedCurrency == null && appUserAsync.hasValue) {
      _selectedCurrency = appUserAsync.value?.baseCurrency;
    }

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'MOVE MONEY',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppColors.textLight),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // From Pool Info
            appUserAsync.when(
              data: (user) {
                final rta = user?.readyToAssign ?? 0;
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.primary),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'MOVING FROM',
                            style: TextStyle(
                              color: AppColors.textLight,
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                              letterSpacing: 1.1,
                            ),
                          ),
                          Text(
                            'Ready to Assign',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        user?.baseCurrency == 'HTG' ? '${(rta / 100).toStringAsFixed(2)} G' : '\$${(rta / 100).toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (e, s) => const SizedBox.shrink(),
            ),
            
            const SizedBox(height: 32),
            
            // Target Category Selection
            const Text(
              'TO ENVELOPE',
              style: TextStyle(
                color: AppColors.textLight,
                fontWeight: FontWeight.w900,
                fontSize: 10,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 12),
            categoriesAsync.when(
              data: (categories) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primaryLight),
                  ),
                  child: DropdownButton<Category>(
                    value: _selectedCategory,
                    isExpanded: true,
                    underline: const SizedBox(),
                    hint: const Text('Select target envelope'),
                    items: categories.map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedCategory = val),
                  ),
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
            ),
            
            const SizedBox(height: 32),
            
            // Amount Input
            const Text(
              'AMOUNT',
              style: TextStyle(
                color: AppColors.textLight,
                fontWeight: FontWeight.w900,
                fontSize: 10,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark,
                    ),
                    decoration: InputDecoration(
                      hintText: '0.00',
                      border: InputBorder.none,
                      prefixText: _selectedCurrency == 'USD' ? r'$' : '',
                      suffixText: _selectedCurrency == 'HTG' ? ' G' : '',
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                    ],
                    autofocus: true,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCurrency ?? appUserAsync.value?.baseCurrency ?? 'USD',
                      icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      onChanged: (val) => setState(() => _selectedCurrency = val),
                      items: ['USD', 'HTG'].map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(c),
                      )).toList(),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 40),
            
            // Move Button
            SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
                child: _isSaving 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'CONFIRM MOVEMENT',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
