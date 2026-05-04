import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/shared/themes/app_theme.dart';
import 'package:spendly/core/providers/firebase_providers.dart';
import 'package:spendly/features/accounts/repository/account_repository.dart';
import 'package:spendly/features/budget/repository/category_repository.dart';
import 'package:spendly/core/models/account.dart';
import 'package:spendly/core/models/category.dart';
import 'package:spendly/generated/l10n/app_localizations.dart';
import 'package:spendly/core/providers/currency_provider.dart';
import 'package:spendly/core/providers/locale_provider.dart';
import 'package:spendly/features/home/view/main_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 4;

  // Page 1: Profile
  final _nameController = TextEditingController();

  // Page 2: Preferences handled by providers (localeProvider, currencyProvider)

  // Page 3: Accounts
  final List<Account> _pendingAccounts = [
    const Account(id: '', userId: '', name: 'Main Checking', type: 'CHECKING', currency: 'USD', balance: 0)
  ];

  // Page 4: Categories
  final List<Map<String, dynamic>> _defaultCategories = [
    {'name': 'Rent', 'group': 'Housing', 'target': 0.0, 'enabled': true},
    {'name': 'Groceries', 'group': 'Food', 'target': 0.0, 'enabled': true},
    {'name': 'Transport', 'group': 'Lifestyle', 'target': 0.0, 'enabled': true},
  ];

  bool _isLoading = false;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      _completeOnboarding();
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  Future<void> _completeOnboarding() async {
    setState(() => _isLoading = true);
    try {
      final user = ref.read(authStateProvider).value;
      if (user == null) throw Exception('User not authenticated');
      final userId = user.uid;

      // Update display name
      if (_nameController.text.isNotEmpty) {
        await user.updateDisplayName(_nameController.text.trim());
      }

      // Save Accounts
      final accountRepo = ref.read(accountRepositoryProvider);
      for (var acc in _pendingAccounts) {
        await accountRepo.addAccount(acc.copyWith(userId: userId, currency: ref.read(currencyProvider)));
      }

      // Save Categories
      final categoryRepo = ref.read(categoryRepositoryProvider);
      for (var cat in _defaultCategories) {
        if (cat['enabled']) {
          await categoryRepo.addCategory(Category(
            id: '',
            userId: userId,
            name: cat['name'],
            group: cat['group'],
            monthlyTarget: (cat['target'] * 100).toInt(),
            currency: ref.read(currencyProvider),
          ));
        }
      }

      // Invalidate providers
      ref.invalidate(accountsStreamProvider(userId));
      ref.invalidate(categoriesStreamProvider(userId));

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (page) => setState(() => _currentPage = page),
              children: [
                _buildNamePage(),
                _buildPreferencesPage(),
                _buildAccountsPage(),
                _buildCategoriesPage(),
              ],
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "LET'S GET STARTED!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white70),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: List.generate(_totalPages, (index) {
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: index == _totalPages - 1 ? 0 : 8),
                  decoration: BoxDecoration(
                    color: index <= _currentPage ? Colors.white : Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildNamePage() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "What's your name?",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.textDark),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: "Profile Name",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(20),
            ),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesPage() {
    final currentLocale = ref.watch(localeProvider);
    final currentCurrency = ref.watch(currencyProvider);

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Preferences",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.textDark),
          ),
          const SizedBox(height: 8),
          const Text(
            "Select your preferred language and base currency.",
            style: TextStyle(fontSize: 16, color: AppColors.textLight),
          ),
          const SizedBox(height: 40),
          const Text(
            "LANGUAGE",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.textLight, letterSpacing: 1),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildChoiceChip(
                  label: "ENGLISH",
                  isSelected: currentLocale.languageCode == 'en',
                  onTap: () => ref.read(localeProvider.notifier).setLocale(const Locale('en')),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildChoiceChip(
                  label: "KREYÒL",
                  isSelected: currentLocale.languageCode == 'ht',
                  onTap: () => ref.read(localeProvider.notifier).setLocale(const Locale('ht')),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          const Text(
            "BASE CURRENCY",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.textLight, letterSpacing: 1),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: currentCurrency,
                isExpanded: true,
                items: ['USD', 'HTG', 'EUR', 'CAD'].map((c) {
                  return DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontWeight: FontWeight.bold)));
                }).toList(),
                onChanged: (val) => ref.read(currencyProvider.notifier).setCurrency(val!),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceChip({required String label, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8EBFF) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.textLight,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _buildAccountsPage() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Your Accounts",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.textDark),
          ),
          const SizedBox(height: 8),
          const Text(
            "Add all the places where you keep your money.",
            style: TextStyle(fontSize: 16, color: AppColors.textLight),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.builder(
              itemCount: _pendingAccounts.length + 1,
              itemBuilder: (context, index) {
                if (index == _pendingAccounts.length) {
                  return _buildAddAccountButton();
                }
                final acc = _pendingAccounts[index];
                return _buildAccountCard(acc, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard(Account acc, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(acc.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F2F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(acc.currency, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: "0.00",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    final balanceValue = double.tryParse(val.replaceAll(',', '.')) ?? 0.0;
                    _pendingAccounts[index] = acc.copyWith(balance: (balanceValue * 100).toInt());
                  },
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddAccountButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _pendingAccounts.add(Account(
            id: '',
            userId: '',
            name: 'New Account ${_pendingAccounts.length + 1}',
            type: 'CASH',
            currency: ref.read(currencyProvider),
            balance: 0,
          ));
        });
      },
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withOpacity(0.3), style: BorderStyle.solid, width: 2),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: AppColors.primary),
            SizedBox(width: 8),
            Text(
              "ADD ANOTHER ACCOUNT",
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesPage() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Set Categories",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.textDark),
          ),
          const SizedBox(height: 8),
          const Text(
            "Customize your budget categories, target amounts, and frequencies.",
            style: TextStyle(fontSize: 16, color: AppColors.textLight),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.builder(
              itemCount: _defaultCategories.length,
              itemBuilder: (context, index) {
                final cat = _defaultCategories[index];
                return _buildCategoryCard(cat, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> cat, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Checkbox(
                value: cat['enabled'],
                onChanged: (val) => setState(() => _defaultCategories[index]['enabled'] = val!),
                activeColor: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(cat['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: "0.00",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    final targetValue = double.tryParse(val.replaceAll(',', '.')) ?? 0.0;
                    _defaultCategories[index]['target'] = targetValue;
                  },
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F2F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(ref.watch(currencyProvider), style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              flex: 1,
              child: GestureDetector(
                onTap: _prevPage,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F2F5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    "BACK",
                    style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.textLight),
                  ),
                ),
              ),
            ),
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: _isLoading ? null : _nextPage,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
                  ],
                ),
                alignment: Alignment.center,
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                    : Text(
                        _currentPage == _totalPages - 1 ? "FINISH" : "NEXT",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
