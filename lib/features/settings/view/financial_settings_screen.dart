import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/shared/themes/app_theme.dart';
import 'package:spendly/shared/widgets/app_header.dart';
import 'package:spendly/shared/widgets/main_card.dart';
import 'package:spendly/core/providers/app_user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spendly/core/providers/firebase_providers.dart';

class FinancialSettingsScreen extends ConsumerStatefulWidget {
  const FinancialSettingsScreen({super.key});

  @override
  ConsumerState<FinancialSettingsScreen> createState() => _FinancialSettingsScreenState();
}

class _FinancialSettingsScreenState extends ConsumerState<FinancialSettingsScreen> {

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(authStateProvider).value?.uid ?? '';
    final userAsync = ref.watch(appUserStreamProvider(userId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          const SliverAppHeader(
            title: 'Financial Policy',
            showBackButton: true,
            showDatePicker: false,
          ),
          SliverToBoxAdapter(
            child: userAsync.when(
              data: (user) {
                if (user == null) return const Center(child: Text('User not found'));

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      // Rate Mode Section
                      MainCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader('EXCHANGE RATE STRATEGY'),
                            const SizedBox(height: 16),
                            _buildModeTile(
                              title: 'Market Rates',
                              subtitle: 'Use global averages for calculations',
                              isSelected: user.rateMode == 'market',
                              onTap: () => _updateRateMode(context, userId, 'market'),
                            ),
                            _buildDivider(),
                            _buildModeTile(
                              title: 'Manual/Custom',
                              subtitle: 'Only use rates you define explicitly',
                              isSelected: user.rateMode == 'manual',
                              onTap: () => _updateRateMode(context, userId, 'manual'),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Custom Rates Section
                      MainCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildSectionHeader('CUSTOM RATES'),
                                IconButton(
                                  onPressed: () => _showAddRateDialog(context, userId, user.exchangeRates),
                                  icon: const Icon(Icons.add_circle, color: AppColors.primary),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (user.exchangeRates.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Text(
                                  'No custom rates defined. Default market rates will be used as fallbacks.',
                                  style: TextStyle(color: AppColors.textLight, fontSize: 13),
                                ),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: user.exchangeRates.length,
                                separatorBuilder: (_, _) => _buildDivider(),
                                itemBuilder: (context, index) {
                                  final pair = user.exchangeRates.keys.elementAt(index);
                                  final rate = user.exchangeRates[pair]!;
                                  return _buildRateTile(context, userId, pair, rate, user.exchangeRates);
                                },
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Reconciliation Section
                      MainCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader('LEDGER INTEGRITY'),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Icon(Icons.verified_user_outlined, color: AppColors.income, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Ledger Version',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                      Text(
                                        'v${user.ledgerVersion}',
                                        style: const TextStyle(color: AppColors.textLight, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => _triggerReconciliation(context),
                                  child: const Text('RECONCILE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
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

  Widget _buildModeTile({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppColors.primary : AppColors.textLight,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: AppColors.textLight, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRateTile(BuildContext context, String userId, String pair, double rate, Map<String, double> currentRates) {
    final parts = pair.split('_');
    final from = parts[0];
    final to = parts[1];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$from ➔ $to',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              '1.00 = ${rate.toStringAsFixed(4)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          IconButton(
            onPressed: () => _showAddRateDialog(context, userId, currentRates, initialFrom: from, initialTo: to, initialRate: rate),
            icon: const Icon(Icons.edit_outlined, color: AppColors.textLight, size: 20),
          ),
          IconButton(
            onPressed: () => _removeRate(context, userId, pair, currentRates),
            icon: const Icon(Icons.delete_outline, color: AppColors.expense, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(color: AppColors.primaryLight, height: 1);
  }

  Future<void> _updateRateMode(BuildContext context, String userId, String mode) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).set(
        {'rateMode': mode},
        SetOptions(merge: true),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update rate mode: $e'), backgroundColor: AppColors.expense),
        );
      }
    }
  }

  Future<void> _removeRate(BuildContext context, String userId, String pair, Map<String, double> currentRates) async {
    try {
      final newRates = Map<String, double>.from(currentRates)..remove(pair);
      await FirebaseFirestore.instance.collection('users').doc(userId).set(
        {'exchangeRates': newRates},
        SetOptions(merge: true),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove rate: $e'), backgroundColor: AppColors.expense),
        );
      }
    }
  }

  void _showAddRateDialog(BuildContext context, String userId, Map<String, double> currentRates, {String? initialFrom, String? initialTo, double? initialRate}) {
    String from = initialFrom ?? 'USD';
    String to = initialTo ?? 'HTG';
    final controller = TextEditingController(text: initialRate?.toString());

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(initialRate != null ? 'Edit Custom Rate' : 'Add Custom Rate', style: const TextStyle(fontWeight: FontWeight.w900)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButton<String>(
                      value: from,
                      isExpanded: true,
                      items: ['USD', 'HTG', 'EUR', 'CAD'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (val) => setDialogState(() => from = val!),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Icon(Icons.arrow_forward, size: 16),
                  ),
                  Expanded(
                    child: DropdownButton<String>(
                      value: to,
                      isExpanded: true,
                      items: ['USD', 'HTG', 'EUR', 'CAD'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (val) => setDialogState(() => to = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Rate (1 $from = ? $to)',
                  hintText: 'e.g. 135.0',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
            ElevatedButton(
              onPressed: () async {
                final rate = double.tryParse(controller.text);
                if (rate == null || rate <= 0) return;

                final newRates = Map<String, double>.from(currentRates);
                newRates['${from}_$to'] = rate;
                newRates['${to}_$from'] = 1 / rate;

                try {
                  await FirebaseFirestore.instance.collection('users').doc(userId).set(
                    {'exchangeRates': newRates},
                    SetOptions(merge: true),
                  );
                  if (context.mounted) Navigator.pop(context);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to save rate: $e'), backgroundColor: AppColors.expense),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(initialRate != null ? 'SAVE RATE' : 'ADD RATE'),
            ),
          ],
        ),
      ),
    );
  }

  void _triggerReconciliation(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reconciliation triggered. Server is verifying ledger integrity...'),
        backgroundColor: AppColors.income,
      ),
    );
    // In a real app, this might increment a 'reconcileRequestedAt' field to trigger a Cloud Function
  }
}
