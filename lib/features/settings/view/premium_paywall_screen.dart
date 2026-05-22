import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:spendly/core/services/subscription_service.dart';
import 'package:spendly/shared/themes/app_theme.dart';

class PremiumPaywallScreen extends ConsumerStatefulWidget {
  const PremiumPaywallScreen({super.key});

  @override
  ConsumerState<PremiumPaywallScreen> createState() => _PremiumPaywallScreenState();
}

class _PremiumPaywallScreenState extends ConsumerState<PremiumPaywallScreen> {
  Package? _selectedPackage;
  bool _isPurchasing = false;
  bool _isRestoring = false;

  @override
  Widget build(BuildContext context) {
    final offeringsAsync = ref.watch(offeringsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Brand Badge
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.auto_awesome, color: AppColors.primary, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'RECEET PRO PREMIUM',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Title & Description
              const Center(
                child: Text(
                  'Unlock Complete Financial Clarity',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Empower your financial planning with our suite of advanced features and cloud synchronization tools.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Core Gated Features list
              _buildFeatureRow(
                icon: LucideIcons.layers,
                title: 'Unlimited Envelopes',
                description: 'Organize your budget categories dynamically without any artificial limits.',
              ),
              _buildFeatureRow(
                icon: LucideIcons.fileSpreadsheet,
                title: 'Advanced CSV & JSON Exports',
                description: 'Extract raw transaction records and budget structures for custom analyses.',
              ),
              _buildFeatureRow(
                icon: LucideIcons.cloudLightning,
                title: 'Secure Cloud Backups',
                description: 'Keep your ledger protected and instantly restorable across all devices.',
              ),
              _buildFeatureRow(
                icon: LucideIcons.shieldCheck,
                title: 'Biometric App Guard',
                description: 'Secure your transactional files with touch and face verification integrations.',
              ),
              
              const SizedBox(height: 32),

              // Dynamic Store Offerings Section
              offeringsAsync.when(
                data: (offerings) {
                  final currentOffering = offerings.current;
                  if (currentOffering == null || currentOffering.availablePackages.isEmpty) {
                    return const Center(
                      child: Text(
                        'No premium tiers currently available. Please check back later.',
                        style: TextStyle(color: AppColors.textLight),
                      ),
                    );
                  }

                  final packages = currentOffering.availablePackages;

                  // Auto select first package (preferably Yearly) if none is selected yet
                  if (_selectedPackage == null) {
                    final defaultSelect = packages.firstWhere(
                      (p) => p.packageType == PackageType.annual,
                      orElse: () => packages.first,
                    );
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() => _selectedPackage = defaultSelect);
                    });
                  }

                  return Column(
                    children: packages.map((package) {
                      final isSelected = _selectedPackage?.identifier == package.identifier;
                      return _buildPackageOption(package, isSelected);
                    }).toList(),
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (err, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      children: [
                        const Icon(LucideIcons.alertTriangle, color: AppColors.expense, size: 36),
                        const SizedBox(height: 8),
                        Text(
                          'Unable to load subscription tiers: $err',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.textDark, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Main Purchase Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isPurchasing || _isRestoring || _selectedPackage == null
                      ? null
                      : () => _handlePurchase(_selectedPackage!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isPurchasing
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text(
                          'Unlock Premium Access',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // Restore purchases button
              Center(
                child: TextButton.icon(
                  onPressed: _isPurchasing || _isRestoring ? null : _handleRestore,
                  icon: const Icon(LucideIcons.refreshCw, size: 14, color: AppColors.textLight),
                  label: const Text(
                    'Restore Existing Purchases',
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Terms & Disclaimers Footer
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Subscriptions will be charged to your App Store account at confirmation of purchase. Subscriptions automatically renew unless cancelled at least 24 hours before the end of the current period.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textLight.withValues(alpha: 0.8),
                    fontSize: 10,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageOption(Package package, bool isSelected) {
    final storeProduct = package.storeProduct;
    String billingCycle = '';
    String badgeText = '';

    if (package.packageType == PackageType.monthly) {
      billingCycle = ' / Month';
    } else if (package.packageType == PackageType.annual) {
      billingCycle = ' / Year';
      badgeText = 'BEST VALUE';
    } else if (package.packageType == PackageType.lifetime) {
      billingCycle = ' One-Time Payment';
      badgeText = 'LIFETIME ACCESS';
    }

    final hasIntroductoryPrice = storeProduct.introductoryPrice != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPackage = package;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : AppColors.cardBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.primaryLight,
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Radio selection icon
              Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: isSelected ? AppColors.primary : AppColors.textLight,
                size: 22,
              ),
              const SizedBox(width: 16),
              
              // Pricing Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          storeProduct.title.split('(').first.trim(),
                          style: const TextStyle(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        if (badgeText.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              badgeText,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      storeProduct.description,
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontSize: 12,
                      ),
                    ),
                    if (hasIntroductoryPrice) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Includes 7-day free trial',
                        style: const TextStyle(
                          color: AppColors.income,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // localized Price
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    storeProduct.priceString,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    billingCycle,
                    style: const TextStyle(
                      color: AppColors.textLight,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handlePurchase(Package package) async {
    setState(() => _isPurchasing = true);
    
    final result = await ref.read(subscriptionServiceProvider).purchasePackage(package);
    
    if (mounted) {
      setState(() => _isPurchasing = false);
      
      if (result.isSuccess) {
        if (result.hasPremium) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Welcome to Receet Pro Premium! Thank you for your support.'),
              backgroundColor: AppColors.income,
            ),
          );
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment completed, but premium entitlement is not active. Please contact support.'),
            ),
          );
        }
      } else if (!result.isCancelled) {
        // Only show error dialog if user did not cancel the native payment sheet themselves
        _showErrorDialog(result.errorMessage ?? 'An unexpected purchase error occurred.');
      }
    }
  }

  Future<void> _handleRestore() async {
    setState(() => _isRestoring = true);
    
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.showSnackBar(
      const SnackBar(content: Text('Contacting store server to restore transactions...')),
    );
    
    final result = await ref.read(subscriptionServiceProvider).restorePurchases();
    
    if (mounted) {
      setState(() => _isRestoring = false);
      
      if (result.isSuccess) {
        if (result.hasPremium) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('Successfully restored! Premium features unlocked.'),
              backgroundColor: AppColors.income,
            ),
          );
          Navigator.of(context).pop();
        } else {
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('Restoration completed. No active premium subscription found.'),
            ),
          );
        }
      } else {
        _showErrorDialog(result.errorMessage ?? 'An error occurred while restoring purchases.');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Purchase Help'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
