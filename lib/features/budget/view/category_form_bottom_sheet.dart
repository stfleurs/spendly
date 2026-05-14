import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/core/models/category.dart';
import 'package:spendly/features/budget/repository/category_repository.dart';
import 'package:spendly/features/home/providers/insights_provider.dart';
import 'package:spendly/shared/themes/app_theme.dart';
import 'package:spendly/core/providers/firebase_providers.dart';
import 'package:spendly/generated/l10n/app_localizations.dart';

class CategoryFormBottomSheet extends ConsumerStatefulWidget {
  final Category? category;

  const CategoryFormBottomSheet({super.key, this.category});

  @override
  ConsumerState<CategoryFormBottomSheet> createState() => _CategoryFormBottomSheetState();
}

class _CategoryFormBottomSheetState extends ConsumerState<CategoryFormBottomSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _budgetController;
  late String _selectedGroup;
  late String _selectedCurrency;
  late String _selectedRecurrence;
  bool _isLoading = false;

  final List<String> _groups = [
    'Family',
    'Health',
    'Kids',
    'Home',
    'Essentials',
    'Lifestyle',
    'Financial Obligations',
    'Other'
  ];

  final List<String> _currencies = ['USD', 'HTG', 'EUR', 'CAD'];
  final List<String> _recurrences = ['Weekly', 'Monthly', 'Yearly'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _budgetController = TextEditingController(
      text: widget.category?.monthlyTarget != null 
          ? (widget.category!.monthlyTarget! / 100).toStringAsFixed(2) 
          : '',
    );
    _selectedGroup = widget.category?.group ?? _groups.first;
    // ensure _selectedGroup is valid (fallback to Other if it was old format)
    if (!_groups.contains(_selectedGroup)) {
      _selectedGroup = 'Other';
    }

    _selectedCurrency = widget.category?.currency ?? 'USD';
    _selectedRecurrence = widget.category?.recurrence ?? 'Monthly';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a category name')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    final userId = ref.read(authStateProvider).value?.uid ?? '';
    final budgetValue = double.tryParse(_budgetController.text) ?? 0.0;
    final monthlyTarget = budgetValue > 0 ? (budgetValue * 100).toInt() : null;

    final newCategory = Category(
      id: widget.category?.id ?? '',
      userId: userId,
      name: _nameController.text.trim(),
      group: _selectedGroup,
      monthlyTarget: monthlyTarget,
      currency: _selectedCurrency,
      recurrence: _selectedRecurrence,
    );

    try {
      if (widget.category == null) {
        await ref.read(categoryRepositoryProvider).addCategory(newCategory);
      } else {
        await ref.read(categoryRepositoryProvider).updateCategory(newCategory);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving category: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.category), 
        content: Text(l10n.deleteConfirmMessage),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete, style: const TextStyle(color: AppColors.expense)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        await ref.read(categoryRepositoryProvider).deleteCategory(widget.category!.userId, widget.category!.id);
        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting category: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEditing = widget.category != null;
    final userId = ref.watch(authStateProvider).value?.uid ?? '';

    // Adjusting for keyboard
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Material(
        color: AppColors.background,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? '${l10n.category.toUpperCase()} - ${l10n.updateAccount}' : '${l10n.category.toUpperCase()} - ${l10n.createAccount}', 
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: 1.2,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    color: AppColors.textLight,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildLabel(l10n.category.toUpperCase()),
              TextField(
                controller: _nameController,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                decoration: const InputDecoration(
                  hintText: 'e.g. Groceries, Rent, Gas',
                  border: InputBorder.none,
                ),
              ),
              const Divider(color: AppColors.primaryLight),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel(l10n.group.toUpperCase()),
                        DropdownButton<String>(
                          value: _selectedGroup,
                          isExpanded: true,
                          underline: const SizedBox(),
                          items: _groups.map((g) {
                            return DropdownMenuItem(value: g, child: Text(g));
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedGroup = val!),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel(l10n.currency.toUpperCase()),
                        DropdownButton<String>(
                          value: _selectedCurrency,
                          isExpanded: true,
                          underline: const SizedBox(),
                          items: _currencies.map((c) {
                            return DropdownMenuItem(value: c, child: Text(c));
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedCurrency = val!),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const Divider(color: AppColors.primaryLight),
              const SizedBox(height: 16),
              
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel(l10n.targetAmount.toUpperCase()),
                        TextField(
                          controller: _budgetController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 32, color: AppColors.primary),
                          decoration: InputDecoration(
                            prefixText: _selectedCurrency == 'USD' ? r'$ ' 
                                : _selectedCurrency == 'HTG' ? 'G '
                                : _selectedCurrency == 'EUR' ? '€ '
                                : r'$ ',
                            hintText: '0.00',
                            border: InputBorder.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel(l10n.recurrence.toUpperCase()),
                        DropdownButton<String>(
                          value: _selectedRecurrence,
                          isExpanded: true,
                          underline: const SizedBox(),
                          items: _recurrences.map((r) {
                            return DropdownMenuItem(value: r, child: Text(r));
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedRecurrence = val!),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Reality Suggestion
              if (isEditing) ...[
                const SizedBox(height: 8),
                Consumer(
                  builder: (context, ref, child) {
                    final suggestionAsync = ref.watch(realityBudgetSuggestionProvider((
                      userId: userId,
                      categoryId: widget.category!.id,
                    )));

                    return suggestionAsync.when(
                      data: (avgAmount) {
                        if (avgAmount <= 0) return const SizedBox.shrink();
                        final avgStr = (avgAmount / 100).toStringAsFixed(0);
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.lightbulb_outline, size: 16, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'You average \$$avgStr here. Consider setting this as a comfort target.',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  _budgetController.text = avgStr;
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text('Apply', style: TextStyle(fontWeight: FontWeight.w900)),
                              ),
                            ],
                          ),
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, _) => const SizedBox.shrink(),
                    );
                  },
                ),
              ],

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(isEditing ? l10n.updateAccount : l10n.category, style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.1)),
                ),
              ),
              if (isEditing) ...[
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: _isLoading ? null : _delete,
                    child: Text(l10n.deleteAccount, style: const TextStyle(color: AppColors.expense, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textLight,
        fontWeight: FontWeight.w900,
        fontSize: 10,
        letterSpacing: 1.2,
      ),
    );
  }
}
