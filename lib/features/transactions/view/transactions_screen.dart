import 'package:flutter/material.dart';
import 'package:spendly/shared/widgets/app_header.dart';
import 'package:spendly/shared/widgets/main_card.dart';
import 'package:spendly/shared/themes/app_theme.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverAppHeader(title: 'Activity'),
        SliverToBoxAdapter(
          child: Column(
            children: [
              const SizedBox(height: 24),
              
              MainCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _buildActivityItem('Restò / Fritay', '2026-05-02 • SÒTI / LWAZI • MON...', r'-$37.04', isExpense: true, secondaryInfo: 'HTG 5,000.00'),
                    _buildActivityItem('EDH / Canal+', '2026-05-01 • FAKTIR (STARLINK / EDH) ...', r'-$30.00', isExpense: true),
                    _buildActivityItem('Starlink Haiti', '2026-05-01 • FAKTIR (STARLINK / EDH) ...', r'-$120.00', isExpense: true),
                    _buildActivityItem('Mèt Kay la', '2026-05-01 • LWAYE (RENT) • BUH (U...', r'-$800.00', isExpense: true),
                    _buildActivityItem('Total Gaz Station', '2026-05-01 • GAZ / TRANSPÒ • B...', r'-$74.07', isExpense: true, secondaryInfo: 'HTG 10,000.00'),
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

  Widget _buildActivityItem(String merchant, String info, String amount, {required bool isExpense, String? secondaryInfo}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.primaryLight, width: 1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isExpense ? Icons.arrow_upward : Icons.arrow_downward,
              color: AppColors.textLight,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  merchant,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  info,
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                    letterSpacing: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
                  fontSize: 18,
                ),
              ),
              if (secondaryInfo != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.public, size: 10, color: AppColors.textLight),
                    const SizedBox(width: 4),
                    Text(
                      secondaryInfo,
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          const SizedBox(width: 12),
          const Icon(Icons.delete_outline, color: AppColors.expense, size: 20),
        ],
      ),
    );
  }
}
