import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/shared/widgets/app_header.dart';
import 'package:spendly/shared/widgets/main_card.dart';
import 'package:spendly/shared/themes/app_theme.dart';
import 'package:spendly/core/providers/locale_provider.dart';
import 'package:spendly/core/providers/currency_provider.dart';
import 'package:spendly/core/providers/firebase_providers.dart';
import 'package:spendly/features/auth/repository/auth_repository.dart';
import 'package:spendly/features/auth/view/onboarding_screen.dart';
import 'package:spendly/features/accounts/repository/account_repository.dart';
import 'package:spendly/generated/l10n/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);
    final currentCurrency = ref.watch(currencyProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppHeader(
            title: l10n.settings,
            showBackButton: true,
            showDatePicker: false,
            showActions: false,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  // Language Settings
                  MainCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(l10n.language),
                        const SizedBox(height: 16),
                        _buildSettingTile(
                          context,
                          title: l10n.english,
                          isSelected: currentLocale.languageCode == 'en',
                          onTap: () => ref.read(localeProvider.notifier).setLocale(const Locale('en')),
                        ),
                        _buildDivider(),
                        _buildSettingTile(
                          context,
                          title: l10n.french,
                          isSelected: currentLocale.languageCode == 'fr',
                          onTap: () => ref.read(localeProvider.notifier).setLocale(const Locale('fr')),
                        ),
                        _buildDivider(),
                        _buildSettingTile(
                          context,
                          title: l10n.haitianCreole,
                          isSelected: currentLocale.languageCode == 'ht',
                          onTap: () => ref.read(localeProvider.notifier).setLocale(const Locale('ht')),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Currency Settings
                  MainCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(l10n.preferredCurrency),
                        const SizedBox(height: 16),
                        _buildSettingTile(
                          context,
                          title: 'USD (\$)',
                          isSelected: currentCurrency == 'USD',
                          onTap: () => ref.read(currencyProvider.notifier).setCurrency('USD'),
                        ),
                        _buildDivider(),
                        _buildSettingTile(
                          context,
                          title: 'HTG (G)',
                          isSelected: currentCurrency == 'HTG',
                          onTap: () => ref.read(currencyProvider.notifier).setCurrency('HTG'),
                        ),
                        _buildDivider(),
                        _buildSettingTile(
                          context,
                          title: 'EUR (€)',
                          isSelected: currentCurrency == 'EUR',
                          onTap: () => ref.read(currencyProvider.notifier).setCurrency('EUR'),
                        ),
                        _buildDivider(),
                        _buildSettingTile(
                          context,
                          title: 'CAD (\$)',
                          isSelected: currentCurrency == 'CAD',
                          onTap: () => ref.read(currencyProvider.notifier).setCurrency('CAD'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Account Settings
                  MainCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('ACCOUNT'), // Add to l10n if needed, but for now hardcoded
                        const SizedBox(height: 16),
                        _buildSettingTile(
                          context,
                          title: l10n.logOut,
                          isSelected: false,
                          onTap: () {
                            ref.read(authRepositoryProvider).signOut();
                            Navigator.of(context).popUntil((route) => route.isFirst);
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  if (kDebugMode) ...[
                    MainCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader('DEBUG'),
                          const SizedBox(height: 16),
                          _buildSettingTile(
                            context,
                            title: 'Launch Onboarding',
                            isSelected: false,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => const OnboardingScreen()),
                              );
                            },
                          ),
                          _buildDivider(),
                          _buildSettingTile(
                            context,
                            title: 'Reset App (Clear Data)',
                            isSelected: false,
                            onTap: () async {
                              final userId = ref.read(authStateProvider).value?.uid;
                              if (userId == null) return;
                              
                              final scaffoldMessenger = ScaffoldMessenger.of(context);
                              
                              try {
                                final accounts = await ref.read(accountRepositoryProvider).watchAccounts(userId).first;
                                for (var account in accounts) {
                                  await ref.read(accountRepositoryProvider).deleteAccount(account.id);
                                }
                                scaffoldMessenger.showSnackBar(const SnackBar(content: Text('App Reset Successful')));
                              } catch (e) {
                                scaffoldMessenger.showSnackBar(SnackBar(content: Text('Reset Failed: $e')));
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textLight,
        fontWeight: FontWeight.w900,
        fontSize: 10,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textDark,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                fontSize: 16,
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(color: AppColors.primaryLight, height: 1);
  }
}
