import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/shared/widgets/app_header.dart';
import 'package:spendly/shared/widgets/main_card.dart';
import 'package:spendly/shared/themes/app_theme.dart';
import 'package:spendly/features/accounts/repository/account_repository.dart';
import 'package:spendly/core/providers/firebase_providers.dart';
import 'package:spendly/core/models/account.dart';
import 'package:spendly/generated/l10n/app_localizations.dart';

class NewAccountScreen extends ConsumerStatefulWidget {
  final Account? account;
  const NewAccountScreen({super.key, this.account});

  @override
  ConsumerState<NewAccountScreen> createState() => _NewAccountScreenState();
}

class _NewAccountScreenState extends ConsumerState<NewAccountScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _balanceController;
  late final TextEditingController _creditLimitController;
  late String _selectedType;
  late String _selectedCurrency;
  late Color _selectedColor;
  bool _isLoading = false;

  final List<Color> _accountColors = [
    AppColors.primary,
    const Color(0xFF03DAC6), // Teal
    const Color(0xFFFF0266), // Pink
    const Color(0xFFFFDE03), // Yellow
    const Color(0xFF0336FF), // Blue
    const Color(0xFFFF5722), // Orange
    const Color(0xFF4CAF50), // Green
    const Color(0xFF9C27B0), // Purple
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.account?.name ?? '');
    _balanceController = TextEditingController(
      text: widget.account != null ? (widget.account!.balance / 100).toStringAsFixed(2) : '0.00',
    );
    _creditLimitController = TextEditingController(
      text: widget.account != null ? (widget.account!.creditLimit / 100).toStringAsFixed(2) : '0.00',
    );
    _selectedType = widget.account?.type ?? 'CHECKING';
    _selectedCurrency = widget.account?.currency ?? 'USD';
    
    // Parse color if exists
    _selectedColor = AppColors.primary;
    if (widget.account?.color != null && widget.account!.color!.startsWith('#')) {
      try {
        final hex = widget.account!.color!.substring(1);
        _selectedColor = Color(int.parse('FF$hex', radix: 16));
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    _creditLimitController.dispose();
    super.dispose();
  }

  Future<void> _saveAccount() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an account name')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final userId = ref.read(authStateProvider).value?.uid ?? '';
    final balanceValue = double.tryParse(_balanceController.text) ?? 0.0;
    final creditLimitValue = double.tryParse(_creditLimitController.text) ?? 0.0;

    final account = Account(
      id: widget.account?.id ?? '',
      userId: userId,
      name: _nameController.text.trim(),
      type: _selectedType,
      balance: (balanceValue * 100).toInt(),
      creditLimit: (creditLimitValue * 100).toInt(),
      currency: _selectedCurrency,
      color: '#${_selectedColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}',
    );

    try {
      if (widget.account == null) {
        await ref.read(accountRepositoryProvider).addAccount(account);
      } else {
        await ref.read(accountRepositoryProvider).updateAccount(account);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving account: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteAccount() async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteAccount),
        content: const Text('Are you sure you want to delete this account? All related transactions will remain but may lose their reference.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.deleteAccount.toUpperCase(), style: const TextStyle(color: AppColors.expense)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        await ref.read(accountRepositoryProvider).deleteAccount(widget.account!);
        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting account: $e')),
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
    final isEditing = widget.account != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppHeader(
            title: isEditing ? l10n.updateAccount : l10n.createAccount,
            showBackButton: true,
            showDatePicker: false,
            showActions: false,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  MainCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel(l10n.accountName),
                        TextField(
                          controller: _nameController,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          decoration: const InputDecoration(
                            hintText: 'e.g. Savings, Wallet, Bank Name',
                            border: InputBorder.none,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Divider(color: AppColors.primaryLight),
                        const SizedBox(height: 24),
                        _buildLabel(l10n.accountType),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          children: [
                            _buildTypeChip('CHECKING', l10n.checking),
                            _buildTypeChip('SAVINGS', l10n.savings),
                            _buildTypeChip('CASH', l10n.cash),
                            _buildTypeChip('CREDIT CARD', l10n.creditCard),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Divider(color: AppColors.primaryLight),
                        const SizedBox(height: 24),
                        _buildLabel(l10n.accountColor),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 50,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _accountColors.length,
                            separatorBuilder: (context, index) => const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final color = _accountColors[index];
                              final isSelected = _selectedColor == color;
                              return GestureDetector(
                                onTap: () => setState(() => _selectedColor = color),
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    border: isSelected
                                        ? Border.all(color: Colors.white, width: 3)
                                        : null,
                                    boxShadow: isSelected
                                        ? [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 4))]
                                        : null,
                                  ),
                                  child: isSelected
                                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                                      : null,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Divider(color: AppColors.primaryLight),
                        const SizedBox(height: 24),
                        _buildLabel(l10n.currency),
                        DropdownButton<String>(
                          value: _selectedCurrency,
                          isExpanded: true,
                          underline: const SizedBox(),
                          items: ['USD', 'HTG', 'EUR', 'CAD'].map((c) {
                            return DropdownMenuItem(value: c, child: Text(c));
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedCurrency = val!),
                        ),
                        const SizedBox(height: 24),
                        const Divider(color: AppColors.primaryLight),
                        const SizedBox(height: 24),
                        _buildLabel(l10n.initialBalance),
                        TextField(
                          controller: _balanceController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 32, color: _selectedColor),
                          decoration: const InputDecoration(
                            prefixText: r'$ ',
                            border: InputBorder.none,
                          ),
                        ),
                        if (_selectedType == 'CREDIT CARD') ...[
                          const SizedBox(height: 24),
                          const Divider(color: AppColors.primaryLight),
                          const SizedBox(height: 24),
                          _buildLabel('CREDIT LIMIT'),
                          TextField(
                            controller: _creditLimitController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 32, color: AppColors.expense),
                            decoration: const InputDecoration(
                              prefixText: r'$ ',
                              border: InputBorder.none,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveAccount,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _selectedColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Text(
                                    (isEditing ? l10n.updateAccount : l10n.createAccount).toUpperCase(),
                                    style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.1),
                                  ),
                          ),
                        ),
                        if (isEditing) ...[
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: _isLoading ? null : _deleteAccount,
                            child: Text(
                              l10n.deleteAccount.toUpperCase(),
                              style: const TextStyle(color: AppColors.expense, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String type, String label) {
    final isSelected = _selectedType == type;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) => setState(() => _selectedType = type),
      selectedColor: _selectedColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textLight,
        fontWeight: FontWeight.bold,
        fontSize: 11,
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
