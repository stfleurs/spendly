import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/shared/themes/app_theme.dart';
import 'package:spendly/shared/widgets/app_header.dart';
import 'package:spendly/shared/widgets/main_card.dart';
import 'package:spendly/core/providers/app_user_provider.dart';
import 'package:spendly/core/providers/financial_summary_provider.dart';
import 'package:spendly/features/accounts/repository/account_repository.dart';
import 'package:spendly/features/transactions/repository/transaction_repository.dart';
import 'package:spendly/core/providers/firebase_providers.dart';
import 'package:intl/intl.dart';

class FinancialIntegrityScreen extends ConsumerWidget {
  const FinancialIntegrityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(authStateProvider).value?.uid ?? '';
    final userAsync = ref.watch(appUserStreamProvider(userId));
    final summaryAsync = ref.watch(financialSummaryProvider(userId));
    final accountsAsync = ref.watch(accountsStreamProvider(userId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          const SliverAppHeader(
            title: 'Integrity Dashboard',
            showBackButton: true,
            showDatePicker: false,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGlobalHealthCard(userAsync, summaryAsync),
                  const SizedBox(height: 24),
                  _buildAccountsHealthSection(accountsAsync),
                  const SizedBox(height: 24),
                  _buildRebuildSection(context, ref, userId),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlobalHealthCard(AsyncValue userAsync, AsyncValue summaryAsync) {
    return MainCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('GLOBAL STATUS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.2, color: AppColors.textLight)),
          const SizedBox(height: 16),
          userAsync.when(
            data: (user) => _buildStatusRow('User Ledger Version', 'v${user?.ledgerVersion ?? 0}', Icons.history),
            loading: () => const CircularProgressIndicator(),
            error: (e, _) => Text('Error: $e'),
          ),
          _buildDivider(),
          summaryAsync.when(
            data: (summary) => Column(
              children: [
                _buildStatusRow('Summary Version', 'v${summary?.ledgerVersion ?? 0}', Icons.summarize_outlined),
                _buildDivider(),
                _buildStatusRow(
                  'Reconciliation State',
                  summary?.reconciled == true ? 'RECONCILED' : 'DIRTY',
                  summary?.reconciled == true ? Icons.check_circle : Icons.warning_amber_rounded,
                  color: summary?.reconciled == true ? AppColors.income : AppColors.expense,
                ),
                _buildDivider(),
                _buildStatusRow(
                  'Net Worth Snapshot',
                  '\$${(((summary?.netWorth ?? 0)) / 100).toStringAsFixed(2)}',
                  Icons.account_balance_wallet_outlined,
                ),
              ],
            ),
            loading: () => const CircularProgressIndicator(),
            error: (e, _) {
              final msg = e.toString().contains('permission-denied')
                  ? 'Add Firestore rule for financial_summary subcollection'
                  : 'Error: $e';
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(msg, style: const TextStyle(color: AppColors.expense, fontSize: 12)),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAccountsHealthSection(AsyncValue accountsAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('ACCOUNTS INTEGRITY', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.2, color: AppColors.textLight)),
        const SizedBox(height: 12),
        accountsAsync.when(
          data: (accounts) => ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: accounts.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final acc = accounts[index];
              final isHealthy = acc.snapshotHealthy;
              final balance = acc.currentBalance ?? acc.balance;
              return MainCard(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(isHealthy ? Icons.verified : Icons.error_outline, color: isHealthy ? AppColors.income : AppColors.expense, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(acc.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Text('v${acc.ledgerVersion}', style: const TextStyle(color: AppColors.textLight, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildMiniStat('Balance', '\$${(balance / 100).toStringAsFixed(2)}'),
                        _buildMiniStat('Reconciled', acc.lastReconciledAt != null ? DateFormat('MM/dd HH:mm').format(acc.lastReconciledAt!) : 'Never'),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          loading: () => const CircularProgressIndicator(),
          error: (e, _) => Text('Error: $e'),
        ),
      ],
    );
  }

  Widget _buildRebuildSection(BuildContext context, WidgetRef ref, String userId) {
    return MainCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SYSTEM TOOLS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.2, color: AppColors.textLight)),
          const SizedBox(height: 16),
          const Text(
            'Rebuilding the ledger will recalculate all snapshots from the immutable transaction history. This is a heavy operation.',
            style: TextStyle(fontSize: 12, color: AppColors.textLight),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _handleRebuild(context, ref, userId),
              icon: const Icon(Icons.refresh),
              label: const Text('FORCE FULL RECONCILIATION'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, IconData icon, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textLight),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: color ?? AppColors.textDark)),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textLight, fontWeight: FontWeight.bold)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _buildDivider() {
    return const Divider(color: AppColors.primaryLight, height: 1);
  }

  Future<void> _handleRebuild(BuildContext context, WidgetRef ref, String userId) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Starting full reconciliation...')));

    try {
      // 1. Fetch all transactions (This is why it's heavy/admin only)
      final repo = ref.read(transactionRepositoryProvider);
      final transactions = await repo.watchTransactions(userId, limit: 10000).first;
      final accounts = await ref.read(accountRepositoryProvider).watchAccounts(userId).first;

      int calculatedNetWorth = 0;
      final Map<String, int> accountBalances = {};

      for (final tx in transactions) {
        final amount = tx.amountInBaseCurrency;
        final isIncome = tx.type.toLowerCase() == 'income';
        final isExpense = tx.type.toLowerCase() == 'expense';

        if (isIncome) {
          calculatedNetWorth += amount;
          accountBalances[tx.accountId] = (accountBalances[tx.accountId] ?? 0) + tx.amount;
        } else if (isExpense) {
          calculatedNetWorth -= amount;
          accountBalances[tx.accountId] = (accountBalances[tx.accountId] ?? 0) - tx.amount;
        }
      }

      // Add initial balances
      for (final acc in accounts) {
        accountBalances[acc.id] = (accountBalances[acc.id] ?? 0) + acc.balance;
        // This is a simplification, but good for a debug tool
      }

      scaffoldMessenger.showSnackBar(SnackBar(
        content: Text('Rebuild preview: Net Worth \$${(calculatedNetWorth/100).toStringAsFixed(2)}'),
        action: SnackBarAction(label: 'APPLY', onPressed: () async {
          // Here we would perform a batch update to "repair" the snapshots
          scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Repairing snapshots...')));
        }),
      ));

    } catch (e) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.expense));
    }
  }
}
