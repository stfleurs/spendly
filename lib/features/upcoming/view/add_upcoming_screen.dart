import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/shared/widgets/app_header.dart';
import 'package:spendly/shared/widgets/main_card.dart';
import 'package:spendly/shared/themes/app_theme.dart';
import 'package:spendly/core/models/bill.dart';
import 'package:spendly/core/models/category.dart';
import 'package:spendly/core/providers/firebase_providers.dart';
import 'package:spendly/features/budget/repository/category_repository.dart';
import 'package:spendly/features/upcoming/providers/upcoming_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:spendly/features/budget/view/category_form_bottom_sheet.dart';

class AddUpcomingScreen extends ConsumerStatefulWidget {
  final Bill? existingBill;
  /// When launching from a plan detail, pre-fill these values.
  final String? prefilledPlanId;
  final int? prefilledAmount;
  final String? prefilledCategoryId;

  const AddUpcomingScreen({
    super.key,
    this.existingBill,
    this.prefilledPlanId,
    this.prefilledAmount,
    this.prefilledCategoryId,
  });

  @override
  ConsumerState<AddUpcomingScreen> createState() => _AddUpcomingScreenState();
}

class _AddUpcomingScreenState extends ConsumerState<AddUpcomingScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _notesController;

  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  Category? _selectedCategory;
  String _selectedCurrency = 'USD';
  bool _isLoading = false;

  bool get _isEditing => widget.existingBill != null;

  @override
  void initState() {
    super.initState();
    final b = widget.existingBill;
    _titleController = TextEditingController(text: b?.title ?? '');
    _amountController = TextEditingController(
      text: b != null
          ? (b.amount / 100).toStringAsFixed(2)
          : widget.prefilledAmount != null
              ? (widget.prefilledAmount! / 100).toStringAsFixed(2)
              : '',
    );
    _notesController = TextEditingController(text: b?.notes ?? '');
    if (b != null) {
      _dueDate = b.dueDate;
      _selectedCurrency = b.currency;
    } else {
      _selectedCurrency = 'USD';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(authStateProvider).value?.uid ?? '';
    final categoriesAsync = ref.watch(categoriesStreamProvider(userId));

    // Pre-select category in edit mode OR when launched from a plan
    final prefilledCatId =
        widget.existingBill?.categoryId ?? widget.prefilledCategoryId;
    if (_selectedCategory == null &&
        prefilledCatId != null &&
        categoriesAsync.value != null) {
      final match =
          categoriesAsync.value!.where((c) => c.id == prefilledCatId);
      if (match.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _selectedCategory = match.first);
        });
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppHeader(
            title: _isEditing ? 'Edit Payment' : 'Add Upcoming',
            showBackButton: true,
            showDatePicker: false,
            showActions: false,
          ),
          SliverToBoxAdapter(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 24, 0, 40),
                child: Column(
                  children: [
                    MainCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          _sectionLabel('PAYMENT TITLE'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _titleController,
                            style: const TextStyle(
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                            decoration: _inputDecoration('e.g. Kids Tuition Q3'),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Title is required'
                                : null,
                          ),

                          const SizedBox(height: 24),
                          const Divider(color: AppColors.primaryLight),
                          const SizedBox(height: 24),

                          const SizedBox(height: 24),
                          const Divider(color: AppColors.primaryLight),
                          const SizedBox(height: 24),

                          // Currency
                          _sectionLabel('CURRENCY'),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedCurrency,
                            decoration: _inputDecoration('Select currency'),
                            items: ['USD', 'HTG', 'EUR', 'CAD', 'DOP']
                                .map((c) => DropdownMenuItem(
                                      value: c,
                                      child: Text(c,
                                          style: const TextStyle(
                                              color: AppColors.textDark,
                                              fontWeight: FontWeight.w900)),
                                    ))
                                .toList(),
                            onChanged: (v) => setState(() => _selectedCurrency = v ?? 'USD'),
                            dropdownColor: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),

                          const SizedBox(height: 24),
                          const Divider(color: AppColors.primaryLight),
                          const SizedBox(height: 24),

                          // Amount
                          _sectionLabel('AMOUNT'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: const TextStyle(
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w900,
                              fontSize: 32,
                            ),
                            decoration: _inputDecoration('0.00', prefixText: '$_selectedCurrency '),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Amount is required';
                              if ((double.tryParse(v) ?? 0) <= 0) return 'Enter a valid amount';
                              return null;
                            },
                          ),

                          const SizedBox(height: 24),
                          const Divider(color: AppColors.primaryLight),
                          const SizedBox(height: 24),

                          // Due Date
                          _sectionLabel('DUE DATE'),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: _pickDueDate,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 18),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.primaryLight),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today_outlined,
                                      color: AppColors.primary, size: 20),
                                  const SizedBox(width: 12),
                                  Text(
                                    '${_dueDate.day}/${_dueDate.month}/${_dueDate.year}',
                                    style: const TextStyle(
                                      color: AppColors.textDark,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const Spacer(),
                                  const Icon(Icons.chevron_right,
                                      color: AppColors.textLight),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),
                          const Divider(color: AppColors.primaryLight),
                          const SizedBox(height: 24),

                          // Category
                          _sectionLabel('CATEGORY'),
                          const SizedBox(height: 8),
                          categoriesAsync.when(
                            data: (categories) {
                              return Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<Category>(
                                      initialValue: _selectedCategory,
                                      decoration: _inputDecoration('Select a category'),
                                      items: categories
                                          .map((c) => DropdownMenuItem(
                                                value: c,
                                                child: Text(c.name,
                                                    style: const TextStyle(
                                                        color: AppColors.textDark,
                                                        fontWeight: FontWeight.bold)),
                                              ))
                                          .toList(),
                                      onChanged: (c) =>
                                          setState(() => _selectedCategory = c),
                                      validator: (v) =>
                                          v == null ? 'Please select a category' : null,
                                      dropdownColor: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
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
                            error: (e, _) => Text('Error: $e'),
                          ),

                          const SizedBox(height: 24),
                          const Divider(color: AppColors.primaryLight),
                          const SizedBox(height: 24),

                          // Notes
                          _sectionLabel('NOTES (OPTIONAL)'),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _notesController,
                            maxLines: 2,
                            style: const TextStyle(
                              color: AppColors.textDark,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: _inputDecoration(
                                'e.g. Spring semester, School ABC'),
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
                          onPressed: _isLoading ? null : () => _save(userId),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            elevation: 8,
                            shadowColor: AppColors.primary.withValues(alpha: 0.4),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : Text(
                                  _isEditing
                                      ? 'UPDATE PAYMENT'
                                      : 'SAVE PAYMENT',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.1),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.expense),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.expense, width: 1.5),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _save(String userId) async {
    if (!_formKey.currentState!.validate() || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(upcomingRepositoryProvider);
      const uuid = Uuid();

      final amountCents =
          ((double.tryParse(_amountController.text) ?? 0) * 100).round();

      final bill = Bill(
        id: widget.existingBill?.id ?? uuid.v4(),
        userId: userId,
        title: _titleController.text.trim(),
        amount: amountCents,
        currency: _selectedCurrency,
        paidAmount: widget.existingBill?.paidAmount ?? 0,
        dueDate: _dueDate,
        status: widget.existingBill?.status ?? BillStatus.upcoming,
        categoryId: _selectedCategory!.id,
        // Link to plan if launched from plan detail or editing existing plan-linked bill
        templateId: widget.existingBill?.templateId ?? widget.prefilledPlanId,
        receiptId: widget.existingBill?.receiptId,
        linkedTransactionId: widget.existingBill?.linkedTransactionId,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      if (_isEditing) {
        await repo.updateBill(bill);
      } else {
        await repo.addBill(bill);
      }

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error saving: $e'),
              backgroundColor: AppColors.expense),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
