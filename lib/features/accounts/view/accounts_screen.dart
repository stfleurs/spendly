import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/shared/widgets/app_header.dart';
import 'package:spendly/shared/widgets/main_card.dart';
import 'package:spendly/shared/themes/app_theme.dart';
import 'package:spendly/features/accounts/repository/account_repository.dart';
import 'package:spendly/features/accounts/view/new_account_screen.dart';
import 'package:spendly/core/providers/firebase_providers.dart';
import 'package:spendly/core/models/account.dart';
import 'package:spendly/core/providers/balance_provider.dart';
import 'package:spendly/generated/l10n/app_localizations.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final userId = ref.watch(authStateProvider).value?.uid ?? '';
    final accountsAsync = ref.watch(accountsStreamProvider(userId));

    return CustomScrollView(
      slivers: [
        SliverAppHeader(title: l10n.accounts),
        SliverToBoxAdapter(
          child: Column(
            children: [
              const SizedBox(height: 24),
              
              // Net Worth Card
              accountsAsync.when(
                data: (accounts) {
                  final totalCents = accounts.fold(0, (sum, acc) {
                    return sum + ref.watch(accountBalanceProvider((userId: userId, accountId: acc.id)));
                  });
                  return MainCard(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Column(
                      children: [
                        Text(
                          l10n.netWorth,
                          style: const TextStyle(
                            color: AppColors.textLight,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '\$${(totalCents / 100).toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const MainCard(child: Center(child: CircularProgressIndicator())),
                error: (e, s) => MainCard(child: Center(child: Text('Error: $e'))),
              ),
              
              const SizedBox(height: 24),
              
              // Accounts List Card
              accountsAsync.when(
                data: (accounts) {
                  return MainCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        if (accounts.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Text('No accounts yet. Tap the button below to add one!'),
                          ),
                        ...accounts.map((acc) => _buildAccountItem(context, ref, userId, acc)),
                        
                        // Add Account Button at the end of list
                        InkWell(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const NewAccountScreen()),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.add_circle_outline, color: AppColors.primary),
                                const SizedBox(width: 12),
                                Text(
                                  l10n.createAccount.toUpperCase(),
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const MainCard(child: Center(child: CircularProgressIndicator())),
                error: (e, s) => MainCard(child: Center(child: Text('Error: $e'))),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountItem(BuildContext context, WidgetRef ref, String userId, Account account) {
    final currentBalance = ref.watch(accountBalanceProvider((userId: userId, accountId: account.id)));
    final l10n = AppLocalizations.of(context)!;
    // Parse color from hex string
    Color accountColor = AppColors.primary;
    if (account.color != null && account.color!.startsWith('#')) {
      try {
        final hex = account.color!.substring(1);
        accountColor = Color(int.parse('FF$hex', radix: 16));
      } catch (_) {}
    }

    // Map type to icon and localized name
    IconData accountIcon = Icons.account_balance_wallet;
    String typeName = account.type;
    switch (account.type) {
      case 'CHECKING':
        accountIcon = Icons.account_balance;
        typeName = l10n.checking;
        break;
      case 'SAVINGS':
        accountIcon = Icons.savings;
        typeName = l10n.savings;
        break;
      case 'CASH':
        accountIcon = Icons.payments;
        typeName = l10n.cash;
        break;
      case 'CREDIT CARD':
        accountIcon = Icons.credit_card;
        typeName = l10n.creditCard;
        break;
    }

    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => NewAccountScreen(account: account)),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.primaryLight, width: 1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accountColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(accountIcon, color: accountColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.name,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    typeName.toUpperCase(),
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
                if (account.type.toUpperCase() == 'CREDIT CARD') ...[
                  Text(
                    'Limit: ${(account.creditLimit / 100).toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppColors.textLight,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'Available: ${(ref.watch(availableFundsProvider((userId: userId, accountId: account.id))) / 100).toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppColors.income,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  '${account.currency == 'USD' ? r'$ ' : '${account.currency} '}${(currentBalance / 100).toStringAsFixed(2)}',
                  style: TextStyle(
                    color: currentBalance < 0 ? AppColors.expense : AppColors.textDark,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }
}
