import 'package:flutter/material.dart';
import 'package:spendly/shared/widgets/app_header.dart';
import 'package:spendly/shared/widgets/main_card.dart';
import 'package:spendly/shared/themes/app_theme.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverAppHeader(title: 'Reports'),
        SliverToBoxAdapter(
          child: Column(
            children: [
              const SizedBox(height: 24),
              
              // Income/Expense/Net Card
              MainCard(
                child: Column(
                  children: [
                    _buildSummaryItem('INCOME', r'$0.00', AppColors.income, Icons.trending_up),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Divider(color: AppColors.primaryLight, height: 1),
                    ),
                    _buildSummaryItem('EXPENSE', r'$1,061.11', AppColors.expense, Icons.trending_down),
                    const SizedBox(height: 32),
                    
                    // Net Amount Box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: const Column(
                        children: [
                          Text(
                            'NET',
                            style: TextStyle(
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w900,
                              fontSize: 11,
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            r'-$1,061.11',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Budget Categories Card
              MainCard(
                child: Column(
                  children: [
                    _buildCategoryItem('LWAYE (RENT)', r'$800.00', 1.0),
                    _buildCategoryItem('FAKTIR (STARLINK / EDH)', r'$150.00', 0.4),
                    _buildCategoryItem('GAZ / TRANSPÒ', r'$74.07', 0.2),
                    _buildCategoryItem('SÒTI / LWAZI', r'$37.04', 0.1),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(String label, String amount, Color color, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textLight,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              amount,
              style: TextStyle(
                color: color,
                fontSize: 32,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        Icon(icon, color: color, size: 32),
      ],
    );
  }

  Widget _buildCategoryItem(String label, String amount, double progress) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
              Text(
                amount,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.primaryLight,
              color: AppColors.primary,
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }
}
