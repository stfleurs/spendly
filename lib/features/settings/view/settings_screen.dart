import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/shared/widgets/app_header.dart';
import 'package:spendly/shared/widgets/main_card.dart';
import 'package:spendly/shared/themes/app_theme.dart';
import 'package:spendly/core/services/subscription_service.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:spendly/features/settings/view/premium_paywall_screen.dart';
import 'package:spendly/core/providers/locale_provider.dart';
import 'package:spendly/core/providers/currency_provider.dart';
import 'package:spendly/core/providers/firebase_providers.dart';
import 'package:spendly/features/auth/repository/auth_repository.dart';
import 'package:spendly/features/auth/view/onboarding_screen.dart';
import 'package:spendly/features/accounts/repository/account_repository.dart';
import 'package:spendly/features/transactions/repository/transaction_repository.dart';
import 'package:spendly/features/budget/repository/category_repository.dart';
import 'package:spendly/core/providers/security_provider.dart';
import 'package:spendly/core/providers/export_provider.dart';
import 'package:spendly/features/settings/view/financial_settings_screen.dart';
import 'package:spendly/features/settings/view/delete_account_screen.dart';
import 'package:spendly/features/debug/view/financial_integrity_screen.dart';
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
                  _buildPremiumCard(context, ref, ref.watch(isPremiumProvider)),
                  const SizedBox(height: 24),

                  // Language Settings
                  MainCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(l10n.language),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.primaryLight),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String?>(
                              value: currentLocale.isDeviceDefault ? null : currentLocale.locale.languageCode,
                              isExpanded: true,
                              hint: Text(
                                'Automatic',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark),
                              ),
                              items: [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('Automatic (Follow Device)',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textLight)),
                                ),
                                DropdownMenuItem(
                                  value: 'en',
                                  child: Text(l10n.english, style: const TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                DropdownMenuItem(
                                  value: 'fr',
                                  child: Text(l10n.french, style: const TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                DropdownMenuItem(
                                  value: 'ht',
                                  child: Text(l10n.haitianCreole, style: const TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ],
                              onChanged: (val) {
                                if (val == null) {
                                  ref.read(localeProvider.notifier).resetToDeviceLocale();
                                } else {
                                  ref.read(localeProvider.notifier).setLocale(Locale(val));
                                }
                              },
                            ),
                          ),
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
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.primaryLight),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: currentCurrency,
                              isExpanded: true,
                              items: const [
                                DropdownMenuItem(value: 'USD', child: Text('USD (\$)', style: TextStyle(fontWeight: FontWeight.bold))),
                                DropdownMenuItem(value: 'HTG', child: Text('HTG (G)', style: TextStyle(fontWeight: FontWeight.bold))),
                                DropdownMenuItem(value: 'EUR', child: Text('EUR (€)', style: TextStyle(fontWeight: FontWeight.bold))),
                                DropdownMenuItem(value: 'CAD', child: Text('CAD (\$)', style: TextStyle(fontWeight: FontWeight.bold))),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  ref.read(currencyProvider.notifier).setCurrency(val);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Financial Policy Settings
                  MainCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('FINANCIAL POLICY'),
                        const SizedBox(height: 16),
                        _buildSettingTile(
                          context,
                          title: 'Currency & Exchange Rates',
                          isSelected: false,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => const FinancialSettingsScreen()),
                            );
                          },
                        ),
                        _buildDivider(),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            'Control how your net worth and cross-currency transactions are calculated.',
                            style: TextStyle(color: AppColors.textLight, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Security Settings
                  MainCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('SECURITY'),
                        const SizedBox(height: 16),
                        _buildSecuritySwitch(
                          context,
                          title: 'App PIN Lock',
                          value: ref.watch(securityProvider).isPinEnabled,
                          onChanged: (enabled) {
                            if (enabled) {
                              _showSetupPinDialog(context, ref);
                            } else {
                              ref.read(securityProvider.notifier).disablePin();
                            }
                          },
                        ),
                        _buildDivider(),
                        _buildSecuritySwitch(
                          context,
                          title: 'Biometric Unlock',
                          value: ref.watch(securityProvider).isBiometricEnabled,
                          onChanged: (enabled) async {
                            try {
                              await ref.read(securityProvider.notifier).toggleBiometric(enabled);
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString())),
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Data & Backup Settings
                  MainCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('DATA & BACKUP'),
                        const SizedBox(height: 16),
                        _buildSettingTile(
                          context,
                          title: 'Export to CSV',
                          isSelected: false,
                          onTap: () => _handleExport(context, ref, format: 'csv'),
                        ),
                        _buildDivider(),
                        _buildSettingTile(
                          context,
                          title: 'Backup to JSON',
                          isSelected: false,
                          onTap: () => _handleExport(context, ref, format: 'json'),
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
                        _buildSectionHeader('ACCOUNT'),
                        const SizedBox(height: 16),
                        _buildSettingTile(
                          context,
                          title: 'Restore Purchases',
                          isSelected: false,
                          onTap: () async {
                            final scaffoldMessenger = ScaffoldMessenger.of(context);
                            scaffoldMessenger.showSnackBar(
                              const SnackBar(content: Text('Restoring purchases...')),
                            );
                            try {
                              final result = await ref.read(subscriptionServiceProvider).restorePurchases();
                              if (result.isSuccess) {
                                if (result.hasPremium) {
                                  scaffoldMessenger.showSnackBar(
                                    const SnackBar(
                                      content: Text('Successfully restored! Premium is active.'),
                                      backgroundColor: AppColors.income,
                                    ),
                                  );
                                } else {
                                  scaffoldMessenger.showSnackBar(
                                    const SnackBar(
                                      content: Text('Restoration complete. No active premium found.'),
                                    ),
                                  );
                                }
                              } else {
                                scaffoldMessenger.showSnackBar(
                                  SnackBar(
                                    content: Text('Restore failed: ${result.errorMessage}'),
                                    backgroundColor: AppColors.expense,
                                  ),
                                );
                              }
                            } catch (e) {
                              scaffoldMessenger.showSnackBar(
                                SnackBar(
                                  content: Text('Restore failed: $e'),
                                  backgroundColor: AppColors.expense,
                                ),
                              );
                            }
                          },
                        ),
                        _buildDivider(),
                        _buildSettingTile(
                          context,
                          title: l10n.deleteUserAccount,
                          isSelected: false,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => const DeleteAccountScreen()),
                            );
                          },
                        ),
                        _buildDivider(),
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
                            title: 'Financial Integrity Dashboard',
                            isSelected: false,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => const FinancialIntegrityScreen()),
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
                                  await ref.read(accountRepositoryProvider).deleteAccount(account);
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

                  // App Version Footer
                  Center(
                    child: Text(
                      'Receet Pro v1.0.1',
                      style: TextStyle(
                        color: AppColors.textLight.withValues(alpha: 0.5),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

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

  Widget _buildSecuritySwitch(
    BuildContext context, {
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  void _showSetupPinDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Setup App PIN'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: 4,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: 'Enter 4-digit PIN',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.length == 4) {
                ref.read(securityProvider.notifier).setPin(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleExport(
    BuildContext context,
    WidgetRef ref, {
    required String format,
  }) async {
    final userId = ref.read(authStateProvider).value?.uid;
    if (userId == null) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.showSnackBar(
      SnackBar(content: Text('Generating ${format.toUpperCase()} export...')),
    );

    try {
      final accounts = await ref.read(accountRepositoryProvider).watchAccounts(userId).first;
      final transactions = await ref.read(transactionRepositoryProvider).watchTransactions(userId).first;
      final categories = await ref.read(categoryRepositoryProvider).watchCategories(userId).first;

      final catMap = {for (final c in categories) c.id: c};

      if (format == 'csv') {
        await ref.read(dataExportServiceProvider).exportToCsv(
              transactions: transactions,
              accounts: accounts,
              catMap: catMap,
            );
      } else {
        await ref.read(dataExportServiceProvider).exportToJson(
              transactions: transactions,
              accounts: accounts,
            );
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Export failed: $e'), backgroundColor: AppColors.expense),
      );
    }
  }

  Widget _buildPremiumCard(BuildContext context, WidgetRef ref, bool isPremium) {
    if (isPremium) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.verified, color: AppColors.primary, size: 28),
                  SizedBox(width: 12),
                  Text(
                    'Receet Pro Premium Active',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Thank you for your support! You have unlimited access to premium tools and financial insights.',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      await RevenueCatUI.presentCustomerCenter();
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Unable to open Customer Center: $e')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.tune, size: 18),
                  label: const Text('Manage Subscription'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF1A6BA8),
              AppColors.primary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.navShadow,
              blurRadius: 16,
              offset: const Offset(0, 8),
            )
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.auto_awesome, color: Colors.white, size: 14),
                      SizedBox(width: 6),
                      Text(
                        'RECEET PRO PREMIUM',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Unlock Complete Financial Clarity',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enable advanced tools like unlimited envelopes, smart CSV/JSON data exports, cloud backups, and smart financial analysis.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const PremiumPaywallScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.textDark,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Explore Premium Plans',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
