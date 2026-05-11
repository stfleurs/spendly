import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/shared/widgets/app_header.dart';
import 'package:spendly/shared/widgets/main_card.dart';
import 'package:spendly/shared/themes/app_theme.dart';
import 'package:spendly/core/models/bill_template.dart';
import 'package:spendly/core/providers/firebase_providers.dart';
import 'package:spendly/features/budget/repository/category_repository.dart';
import 'package:spendly/core/models/category.dart';
import 'package:spendly/features/upcoming/providers/upcoming_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:spendly/features/budget/view/category_form_bottom_sheet.dart';

class AddPlanScreen extends ConsumerStatefulWidget {
  final BillTemplate? existingPlan;
  const AddPlanScreen({super.key, this.existingPlan});

  @override
  ConsumerState<AddPlanScreen> createState() => _AddPlanScreenState();
}

class _AddPlanScreenState extends ConsumerState<AddPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _totalAmountController;
  late final TextEditingController _installmentController;
  late final TextEditingController _descriptionController;

  Category? _selectedCategory;
  String _selectedCurrency = 'USD';
  bool _isLoading = false;

  bool get _isEditing => widget.existingPlan != null;

  @override
  void initState() {
    super.initState();
    final p = widget.existingPlan;
    _titleController = TextEditingController(text: p?.title ?? '');
    _totalAmountController = TextEditingController(
      text: p?.totalAmount != null ? (p!.totalAmount! / 100).toStringAsFixed(2) : '',
    );
    _installmentController = TextEditingController(
      text: p != null ? (p.defaultAmount / 100).toStringAsFixed(2) : '',
    );
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _selectedCurrency = p?.currency ?? 'USD';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _totalAmountController.dispose();
    _installmentController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(authStateProvider).value?.uid ?? '';
    final categoriesAsync = ref.watch(categoriesStreamProvider(userId));
    // Watch existing bills to determine if currency is locked
    final existingBills = _isEditing
        ? (ref.watch(billsProvider(userId)).value ?? [])
            .where((b) => b.templateId == widget.existingPlan!.id)
            .toList()
        : <dynamic>[];
    final currencyLocked = _isEditing && existingBills.isNotEmpty;

    if (_isEditing && _selectedCategory == null && categoriesAsync.value != null) {
      final match = categoriesAsync.value!
          .where((c) => c.id == widget.existingPlan!.categoryId);
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
            title: _isEditing ? 'Edit Plan' : 'Create Plan',
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
                    // Explainer banner
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.15)),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline,
                                color: AppColors.primary, size: 18),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'A Plan is a big obligation (e.g. "School Tuition"). '
                                'Individual payments are added as installments that roll up to this plan.',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    MainCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Plan name
                          _label('PLAN NAME'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _titleController,
                            style: const TextStyle(
                                color: AppColors.textDark,
                                fontWeight: FontWeight.w900,
                                fontSize: 18),
                            decoration: _input('e.g. School Tuition 2025-26'),
                            validator: (v) =>
                                (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                          ),

                          const SizedBox(height: 24),
                          const Divider(color: AppColors.primaryLight),
                          const SizedBox(height: 24),

                          // Description
                          _label('DESCRIPTION (OPTIONAL)'),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _descriptionController,
                            maxLines: 2,
                            style: const TextStyle(
                                color: AppColors.textDark,
                                fontWeight: FontWeight.bold),
                            decoration: _input(
                                'e.g. Full year tuition for 2 kids at ABC School'),
                          ),

                          const SizedBox(height: 24),
                          const Divider(color: AppColors.primaryLight),
                          const SizedBox(height: 24),

                          // Total obligation
                          _label('TOTAL OBLIGATION'),
                          const SizedBox(height: 4),
                          const Text(
                            'The full amount you expect to pay over time.',
                            style: TextStyle(
                                color: AppColors.textLight, fontSize: 11),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _totalAmountController,
                            keyboardType:
                                const TextInputType.numberWithOptions(decimal: true),
                            style: const TextStyle(
                                color: AppColors.textDark,
                                fontWeight: FontWeight.w900,
                                fontSize: 28),
                            decoration: _input('0.00', prefix: '$_selectedCurrency '),
                          ),

                          const SizedBox(height: 24),
                          const Divider(color: AppColors.primaryLight),
                          const SizedBox(height: 24),

                          const SizedBox(height: 24),
                          const Divider(color: AppColors.primaryLight),
                          const SizedBox(height: 24),

                          // Currency — locked if plan has existing payments
                          _label('PLAN CURRENCY'),
                          const SizedBox(height: 8),
                          if (currencyLocked)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.primaryLight),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.lock_outline, size: 16, color: AppColors.textLight),
                                  const SizedBox(width: 10),
                                  Text(
                                    _selectedCurrency,
                                    style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w900, fontSize: 16),
                                  ),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Text(
                                      'Currency is locked — payments already recorded.',
                                      style: TextStyle(color: AppColors.textLight, fontSize: 10),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            DropdownButtonFormField<String>(
                              value: _selectedCurrency,
                              decoration: _input('Select currency'),
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

                          // Default installment
                          _label('DEFAULT INSTALLMENT AMOUNT'),
                          const SizedBox(height: 4),
                          const Text(
                            'The typical amount for each payment (can be changed per installment).',
                            style: TextStyle(
                                color: AppColors.textLight, fontSize: 11),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _installmentController,
                            keyboardType:
                                const TextInputType.numberWithOptions(decimal: true),
                            style: const TextStyle(
                                color: AppColors.textDark,
                                fontWeight: FontWeight.w900,
                                fontSize: 24),
                            decoration: _input('0.00', prefix: '$_selectedCurrency '),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Installment amount is required';
                              }
                              if ((double.tryParse(v) ?? 0) <= 0) {
                                return 'Enter a valid amount';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 24),
                          const Divider(color: AppColors.primaryLight),
                          const SizedBox(height: 24),

                          // Category
                          _label('CATEGORY'),
                          const SizedBox(height: 8),
                          categoriesAsync.when(
                            data: (cats) {
                              return Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<Category>(
                                      value: _selectedCategory,
                                      decoration: _input('Select a category'),
                                      items: cats
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
                                  _isEditing ? 'UPDATE PLAN' : 'CREATE PLAN',
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

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          color: AppColors.textLight,
          fontWeight: FontWeight.w900,
          fontSize: 10,
          letterSpacing: 1.4,
        ),
      );

  InputDecoration _input(String hint, {String? prefix}) => InputDecoration(
        hintText: hint,
        prefixText: prefix,
        hintStyle: const TextStyle(color: AppColors.textLight),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primaryLight)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primaryLight)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.expense)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      );

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

      final totalCents = _totalAmountController.text.trim().isEmpty
          ? null
          : ((double.tryParse(_totalAmountController.text) ?? 0) * 100).round();
      final installmentCents =
          ((double.tryParse(_installmentController.text) ?? 0) * 100).round();

      final plan = BillTemplate(
        id: widget.existingPlan?.id ?? uuid.v4(),
        userId: userId,
        title: _titleController.text.trim(),
        defaultAmount: installmentCents,
        currency: _selectedCurrency,
        categoryId: _selectedCategory!.id,
        totalAmount: totalCents,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        defaultAccountId: widget.existingPlan?.defaultAccountId,
        notes: widget.existingPlan?.notes,
      );

      if (_isEditing) {
        await repo.updateBillTemplate(plan);
      } else {
        await repo.addBillTemplate(plan);
      }

      if (mounted) Navigator.of(context).pop(plan); // return plan so caller can open detail
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppColors.expense),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
