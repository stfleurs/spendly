import 'package:flutter/material.dart';
import 'package:spendly/shared/widgets/app_header.dart';
import 'package:spendly/shared/widgets/main_card.dart';
import 'package:spendly/shared/themes/app_theme.dart';

class NewTransactionScreen extends StatelessWidget {
  const NewTransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          const SliverAppHeader(
            title: 'New Transaction',
            showBackButton: true,
            showDatePicker: false,
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 24),
                
                // Scan Receipt Section
                MainCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.primaryLight),
                          ),
                          child: const Text(
                            'Text or Scan Receipt',
                            style: TextStyle(color: AppColors.textLight, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('PARSE', style: TextStyle(fontWeight: FontWeight.w900)),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Transaction Type Toggle
                MainCard(
                  padding: const EdgeInsets.all(8),
                  borderRadius: 40,
                  child: Row(
                    children: [
                      _buildTypeItem('EXPENSE', isSelected: true),
                      _buildTypeItem('INCOME', isSelected: false),
                      _buildTypeItem('TRANSFER', isSelected: false),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Transaction Details
                MainCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ACCOUNT',
                        style: TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.1),
                      ),
                      const SizedBox(height: 8),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            r'Sogebank (USD) ($34,200.00)',
                            style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w900, fontSize: 18),
                          ),
                          Icon(Icons.keyboard_arrow_down, color: AppColors.textLight),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Divider(color: AppColors.primaryLight),
                      const SizedBox(height: 24),
                      const Text(
                        'AMOUNT',
                        style: TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.1),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              children: [
                                Text('USD', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900)),
                                Icon(Icons.keyboard_arrow_down, color: AppColors.primary, size: 16),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Text(
                              '0.00',
                              style: TextStyle(color: AppColors.textLight, fontSize: 56, fontWeight: FontWeight.w900),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Divider(color: AppColors.primaryLight),
                      const SizedBox(height: 24),
                      const Text(
                        'PAYEE',
                        style: TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.1),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '...',
                        style: TextStyle(color: AppColors.textLight, fontSize: 24, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeItem(String label, {required bool isSelected}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(32),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.textDark : AppColors.textLight,
              fontWeight: FontWeight.w900,
              fontSize: 12,
              letterSpacing: 1.1,
            ),
          ),
        ),
      ),
    );
  }
}
