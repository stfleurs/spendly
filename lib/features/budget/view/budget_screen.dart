import 'package:flutter/material.dart';
import 'package:spendly/shared/widgets/app_header.dart';
import 'package:spendly/shared/widgets/main_card.dart';
import 'package:spendly/shared/themes/app_theme.dart';

class MyBudgetScreen extends StatelessWidget {
  const MyBudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverAppHeader(title: 'My Budget'),
        SliverToBoxAdapter(
          child: Column(
            children: [
              const SizedBox(height: 24),
              
              // Budget Summary Card
              MainCard(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    const Text(
                      'LEFT TO SPEND',
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      r'$1,438.89',
                      style: TextStyle(
                        color: AppColors.income,
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: AppColors.primaryLight),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSummaryStat('BUDGET', r'$2,500.00'),
                        Container(width: 1, height: 40, color: AppColors.primaryLight),
                        _buildSummaryStat('SPENT', r'$1,061.11'),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Category Budgets
              MainCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CATEGORY BUDGETS',
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildBudgetItem('Food & Dining', r'$400.00', r'$250.00', 0.625, AppColors.primary),
                    _buildBudgetItem('Transport', r'$200.00', r'$150.00', 0.75, Colors.orange),
                    _buildBudgetItem('Entertainment', r'$150.00', r'$37.04', 0.25, Colors.blue),
                    _buildBudgetItem('Housing', r'$1,000.00', r'$800.00', 0.8, Colors.purple),
                    _buildBudgetItem('Services', r'$500.00', r'$150.00', 0.3, Colors.teal),
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

  Widget _buildSummaryStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textLight,
            fontWeight: FontWeight.w900,
            fontSize: 10,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetItem(String category, String budget, String spent, double progress, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: spent,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                    TextSpan(
                      text: ' of $budget',
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                      ),
                    ),
                  ],
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
              color: color,
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }
}
