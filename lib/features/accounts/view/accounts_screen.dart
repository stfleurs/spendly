import 'package:flutter/material.dart';
import 'package:spendly/shared/widgets/app_header.dart';
import 'package:spendly/shared/widgets/main_card.dart';
import 'package:spendly/shared/themes/app_theme.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverAppHeader(title: 'Accounts'),
        SliverToBoxAdapter(
          child: Column(
            children: [
              const SizedBox(height: 24),
              
              // Net Worth Card
              MainCard(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: const Column(
                  children: [
                    Text(
                      'NET WORTH',
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      r'$11,081.49',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Accounts List Card
              MainCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _buildAccountItem('Sogebank (USD)', 'CHECKING', r'$34,200.00'),
                    _buildAccountItem('Unibank (HTG)', 'CHECKING', r'-HTG 1,040,000.00', secondaryAmount: r'-$7,703.70'),
                    _buildAccountItem('BNC (HTG)', 'CHECKING', r'-HTG 520,000.00', secondaryAmount: r'-$3,851.85'),
                    _buildAccountItem('BUH (USD)', 'CHECKING', r'-$9,600.00'),
                    _buildAccountItem('MonCash', 'CASH', r'-HTG 265,000.00', secondaryAmount: r'-$1,962.96'),
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

  Widget _buildAccountItem(String name, String type, String amount, {String? secondaryAmount}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.primaryLight, width: 1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.account_balance_wallet, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  type,
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              if (secondaryAmount != null) ...[
                const SizedBox(height: 4),
                Text(
                  secondaryAmount,
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
