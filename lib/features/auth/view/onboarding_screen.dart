import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/shared/themes/app_theme.dart';
import 'package:spendly/core/providers/firebase_providers.dart';
import 'package:spendly/features/accounts/repository/account_repository.dart';
import 'package:spendly/features/budget/repository/category_repository.dart';
import 'package:spendly/core/models/account.dart';
import 'package:spendly/core/models/category.dart';
import 'package:spendly/core/providers/currency_provider.dart';
import 'package:spendly/core/providers/locale_provider.dart';
import 'package:spendly/core/providers/security_provider.dart';
import 'package:spendly/core/services/monetization_limits.dart';
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

  // Page 3: Goals
  String? _selectedGoal;
  final List<String> _goals = [
    'Stop overspending',
    'Save more money',
    'Pay bills on time',
    'Track where money goes',
    'Feel less stressed about money'
  ];

  // Page 4: Envelopes
  final List<Map<String, dynamic>> _suggestedEnvelopes = [
    {'name': 'Rent / Housing', 'group': 'Housing', 'selected': true},
    {'name': 'Groceries', 'group': 'Food', 'selected': true},
    {'name': 'Transport', 'group': 'Lifestyle', 'selected': true},
    {'name': 'Eating Out', 'group': 'Food', 'selected': false},
    {'name': 'Bills', 'group': 'Utilities', 'selected': true},
    {'name': 'Savings', 'group': 'Savings', 'selected': true},
    {'name': 'Fun Money', 'group': 'Entertainment', 'selected': false},
    {'name': 'Emergency Fund', 'group': 'Savings', 'selected': false},
  ];

  final _customEnvelopeController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _customEnvelopeController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage == 2 && _selectedGoal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a budgeting goal')),
      );
      return;
    }

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

      // Save user goal locally for future personalization
      if (_selectedGoal != null) {
        final prefs = ref.read(sharedPreferencesProvider);
        await prefs.setString('user_budgeting_goal', _selectedGoal!);
      }

      // Automatically create a default 'Main Wallet' account
      final accountRepo = ref.read(accountRepositoryProvider);
      await accountRepo.addAccount(Account(
        id: '',
        userId: userId,
        name: 'Main Wallet',
        type: 'CASH',
        currency: ref.read(currencyProvider),
        balance: 0,
      ));

      // Save Selected Envelopes
      final categoryRepo = ref.read(categoryRepositoryProvider);
      var createdEnvelopeCount = 0;
      for (var env in _suggestedEnvelopes) {
        if (env['selected'] && createdEnvelopeCount < MonetizationLimits.freeMaxEnvelopes) {
          await categoryRepo.addCategory(Category(
            id: '',
            userId: userId,
            name: env['name'],
            group: env['group'],
            monthlyTarget: 0, // Users will set targets later
            currency: ref.read(currencyProvider),
            recurrence: 'Monthly',
          ));
          createdEnvelopeCount++;
        }
      }

      // Invalidate providers so Dashboard loads fresh
      ref.invalidate(accountsStreamProvider(userId));
      ref.invalidate(categoriesStreamProvider(userId));
      ref.read(firebaseObservabilityServiceProvider).logEvent(
        'onboarding_completed',
        parameters: {
          'user_id': userId,
          'selected_currency': ref.read(currencyProvider),
          'selected_envelopes_count': createdEnvelopeCount,
        },
      );

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
                _buildGoalPage(),
                _buildEnvelopesPage(),
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
    return SingleChildScrollView(
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

    return SingleChildScrollView(
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
              const SizedBox(width: 8),
              Expanded(
                child: _buildChoiceChip(
                  label: "FRANCAIS",
                  isSelected: currentLocale.languageCode == 'fr',
                  onTap: () => ref.read(localeProvider.notifier).setLocale(const Locale('fr')),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildChoiceChip(
                  label: "KREYOL",
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

  Widget _buildGoalPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "What's your biggest budgeting goal?",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.textDark, height: 1.2),
          ),
          const SizedBox(height: 8),
          const Text(
            "We'll customize your experience to help you achieve this.",
            style: TextStyle(fontSize: 16, color: AppColors.textLight),
          ),
          const SizedBox(height: 32),
          ..._goals.map((goal) => GestureDetector(
                onTap: () => setState(() => _selectedGoal = goal),
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _selectedGoal == goal ? AppColors.primary.withValues(alpha: 0.1) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _selectedGoal == goal ? AppColors.primary : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: _selectedGoal == goal ? [] : [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _selectedGoal == goal ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                        color: _selectedGoal == goal ? AppColors.primary : AppColors.textLight,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          goal,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: _selectedGoal == goal ? FontWeight.w900 : FontWeight.w600,
                            color: _selectedGoal == goal ? AppColors.primary : AppColors.textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildEnvelopesPage() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "What do you want your money to cover?",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.textDark, height: 1.2),
          ),
          const SizedBox(height: 8),
          const Text(
            "Select the Envelopes you need. You can always adjust these later.",
            style: TextStyle(fontSize: 16, color: AppColors.textLight),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  ..._suggestedEnvelopes.asMap().entries.map((entry) {
                    final int idx = entry.key;
                    final Map<String, dynamic> env = entry.value;
                    final bool isSelected = env['selected'];
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _suggestedEnvelopes[idx]['selected'] = !isSelected;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.primaryLight,
                            width: 1.5,
                          ),
                          boxShadow: isSelected ? [
                            BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4)),
                          ] : [],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isSelected) const Icon(Icons.check, color: Colors.white, size: 18),
                            if (isSelected) const SizedBox(width: 6),
                            Text(
                              env['name'],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  GestureDetector(
                    onTap: _showAddCustomEnvelopeDialog,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.textLight.withValues(alpha: 0.5),
                          style: BorderStyle.solid,
                          width: 1.5,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, color: AppColors.textLight, size: 18),
                          SizedBox(width: 6),
                          Text(
                            "Add Custom",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
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

  void _showAddCustomEnvelopeDialog() {
    _customEnvelopeController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Custom Envelope", style: TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: _customEnvelopeController,
            decoration: const InputDecoration(
              hintText: "e.g. Gym, Pet, Travel",
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCEL", style: TextStyle(color: AppColors.textLight)),
            ),
            ElevatedButton(
              onPressed: () {
                final name = _customEnvelopeController.text.trim();
                if (name.isNotEmpty) {
                  setState(() {
                    _suggestedEnvelopes.add({
                      'name': name,
                      'group': 'Other', // default group for custom
                      'selected': true,
                    });
                  });
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("ADD", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textLight,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
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
                    BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8)),
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
