import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/shared/themes/app_theme.dart';
import 'package:spendly/shared/widgets/main_card.dart';
import 'package:spendly/core/providers/firebase_providers.dart';
import 'package:spendly/features/accounts/repository/account_repository.dart';
import 'package:spendly/core/models/account.dart';
import 'package:spendly/generated/l10n/app_localizations.dart';
import 'package:spendly/core/providers/currency_provider.dart';
import 'package:spendly/features/home/view/main_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  
  final _accountNameController = TextEditingController();
  final _balanceController = TextEditingController(text: '0.00');
  String _selectedAccountType = 'CASH';
  
  final List<Account> _pendingAccounts = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _pageController.dispose();
    _accountNameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _addAccount() {
    final l10n = AppLocalizations.of(context)!;
    if (_accountNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.accountName)),
      );
      return;
    }

    final balanceValue = double.tryParse(_balanceController.text.replaceAll(',', '.')) ?? 0.0;
    final currency = ref.read(currencyProvider);
    
    setState(() {
      _pendingAccounts.add(Account(
        id: '',
        userId: '', // Will be set on save
        name: _accountNameController.text.trim(),
        type: _selectedAccountType,
        balance: (balanceValue * 100).toInt(),
        currency: currency,
        color: '#5E46E6',
      ));
      _accountNameController.clear();
      _balanceController.text = '0.00';
      _selectedAccountType = 'CASH';
    });
  }

  Future<void> _completeOnboarding() async {
    final l10n = AppLocalizations.of(context)!;
    debugPrint('Onboarding: Starting completion process');
    
    // If form is not empty, add the last account automatically
    if (_accountNameController.text.trim().isNotEmpty) {
      debugPrint('Onboarding: Adding last account from form');
      _addAccount();
    }

    if (_pendingAccounts.isEmpty) {
      debugPrint('Onboarding: No accounts to add');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.atLeastOneAccount)),
      );
      return;
    }

    setState(() => _isLoading = true);
    debugPrint('Onboarding: Saving ${_pendingAccounts.length} accounts');
    
    try {
      final user = ref.read(authStateProvider).value;
      if (user == null) {
        debugPrint('Onboarding Error: User not authenticated');
        throw Exception('User not authenticated');
      }
      
      final userId = user.uid;
      final repo = ref.read(accountRepositoryProvider);

      for (var acc in _pendingAccounts) {
        debugPrint('Onboarding: Saving account ${acc.name}');
        await repo.addAccount(acc.copyWith(userId: userId));
      }
      
      debugPrint('Onboarding: All accounts saved successfully');
      
      // Invalidate the accounts stream to force an immediate refresh in AuthGate
      ref.invalidate(accountsStreamProvider(userId));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Setup Complete! Transitioning...')),
        );
      }
      
      // Small delay to allow the stream to emit and AuthGate to rebuild
      await Future.delayed(const Duration(seconds: 1));
      
      // Fallback: If AuthGate hasn't switched us yet, force navigation
      if (mounted) {
        debugPrint('Onboarding: Forcing navigation fallback');
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint('Onboarding Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Setup failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildWelcomePage(l10n),
            _buildCurrencyPage(l10n),
            _buildAccountPage(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_awesome, color: Colors.white, size: 80),
          const SizedBox(height: 40),
          Text(
            l10n.welcomeSpendly.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            l10n.onboardingSubtitle,
            style: const TextStyle(color: Colors.white70, fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 60),
          _buildButton(l10n.getStarted, _nextPage),
        ],
      ),
    );
  }

  Widget _buildCurrencyPage(AppLocalizations l10n) {
    final currentCurrency = ref.watch(currencyProvider);
    
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.public, color: Colors.white, size: 80),
          const SizedBox(height: 40),
          Text(
            l10n.chooseCurrency,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          MainCard(
            margin: 0,
            child: Column(
              children: ['USD', 'HTG', 'EUR', 'CAD'].map((c) {
                final isSelected = currentCurrency == c;
                return ListTile(
                  title: Text(c, style: TextStyle(fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold)),
                  trailing: isSelected ? const Icon(Icons.check_circle, color: AppColors.primary) : null,
                  onTap: () => ref.read(currencyProvider.notifier).setCurrency(c),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 60),
          _buildButton(l10n.next, _nextPage),
        ],
      ),
    );
  }

  Widget _buildAccountPage(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Icon(Icons.account_balance_wallet, color: Colors.white, size: 60),
            const SizedBox(height: 24),
            Text(
              l10n.yourFirstAccount,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            if (_pendingAccounts.isNotEmpty) ...[
              MainCard(
                margin: 0,
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: _pendingAccounts.map((acc) => ListTile(
                    leading: const CircleAvatar(backgroundColor: AppColors.primaryLight, child: Icon(Icons.account_balance, color: AppColors.primary, size: 20)),
                    title: Text(acc.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(acc.type),
                    trailing: Text('${acc.currency} ${(acc.balance / 100).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    onLongPress: () => setState(() => _pendingAccounts.remove(acc)),
                  )).toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],

            MainCard(
              margin: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.accountName, style: const TextStyle(color: AppColors.textLight, fontSize: 10, fontWeight: FontWeight.w900)),
                  TextField(
                    controller: _accountNameController,
                    decoration: InputDecoration(hintText: l10n.accountNameHint),
                  ),
                  const SizedBox(height: 20),
                  Text(l10n.accountType, style: const TextStyle(color: AppColors.textLight, fontSize: 10, fontWeight: FontWeight.w900)),
                  DropdownButton<String>(
                    value: _selectedAccountType,
                    isExpanded: true,
                    items: ['CASH', 'CHECKING', 'SAVINGS', 'CREDIT CARD'].map((t) {
                      return DropdownMenuItem(value: t, child: Text(t));
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedAccountType = val!),
                  ),
                  const SizedBox(height: 20),
                  Text(l10n.initialBalance, style: const TextStyle(color: AppColors.textLight, fontSize: 10, fontWeight: FontWeight.w900)),
                  TextField(
                    controller: _balanceController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _addAccount,
                      icon: const Icon(Icons.add),
                      label: Text(l10n.addAnotherAccount),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primaryLight),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            _isLoading 
              ? const CircularProgressIndicator(color: Colors.white)
              : _buildButton(l10n.completeSetup, _completeOnboarding),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 10,
          shadowColor: Colors.black45,
        ),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5),
        ),
      ),
    );
  }
}
