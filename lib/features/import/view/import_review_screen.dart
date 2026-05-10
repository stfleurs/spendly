import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/shared/themes/app_theme.dart';
import 'package:spendly/shared/widgets/app_header.dart';
import 'package:spendly/features/import/providers/import_provider.dart';
import 'package:spendly/features/budget/providers/budget_provider.dart';
import 'package:spendly/features/transactions/repository/transaction_repository.dart';
import 'package:spendly/core/models/app_transaction.dart';
import 'package:spendly/core/providers/firebase_providers.dart';
import 'package:uuid/uuid.dart';

class ImportReviewScreen extends ConsumerStatefulWidget {
  final String accountId;
  const ImportReviewScreen({super.key, required this.accountId});

  @override
  ConsumerState<ImportReviewScreen> createState() => _ImportReviewScreenState();
}

class _ImportReviewScreenState extends ConsumerState<ImportReviewScreen> {
  final Map<int, String?> _selectedCategoryIds = {};
  bool _isImporting = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(importProvider);
    final userId = ref.watch(authStateProvider).value?.uid ?? '';
    final budgetAsync = ref.watch(budgetProvider(userId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          const SliverAppHeader(title: 'REVIEW DATA', showBackButton: true),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${state.parsedTransactions.length} TRANSACTIONS FOUND',
                    style: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final tx = state.parsedTransactions[index];
                return budgetAsync.when(
                  data: (budget) => _buildTransactionItem(index, tx, budget.items.map((i) => i.category).toList()),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Text('Error: $err'),
                );
              },
              childCount: state.parsedTransactions.length,
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isImporting ? null : () => _finalizeImport(userId, state.parsedTransactions),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: _isImporting 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('IMPORT ALL TRANSACTIONS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(int index, dynamic tx, List<dynamic> categories) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(tx.date, style: const TextStyle(color: AppColors.textLight, fontSize: 12, fontWeight: FontWeight.bold)),
              Text(
                tx.amount,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.textDark),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            tx.description,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _selectedCategoryIds[index],
            decoration: const InputDecoration(
              labelText: 'CATEGORY',
              labelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: categories.map((c) => DropdownMenuItem<String>(value: c.id as String, child: Text(c.name as String))).toList(),
            onChanged: (val) => setState(() => _selectedCategoryIds[index] = val),
          ),
        ],
      ),
    );
  }

  Future<void> _finalizeImport(String userId, List<dynamic> rawTxs) async {
    setState(() => _isImporting = true);
    
    try {
      final repo = ref.read(transactionRepositoryProvider);
      
      for (int i = 0; i < rawTxs.length; i++) {
        final raw = rawTxs[i];
        final catId = _selectedCategoryIds[i] ?? 'default'; // In a real app, handle default better
        
        // Very basic parsing for date and amount
        // In a real app, use better parsing based on local format
        DateTime date;
        try {
          date = DateTime.parse(raw.date.replaceAll('/', '-'));
        } catch (_) {
          date = DateTime.now();
        }
        
        double amount = 0;
        try {
          final String rawAmount = raw.amount.toString();
          final String cleaned = rawAmount.replaceAll(',', '').replaceAll('HTG', '').replaceAll(r'$', '').trim();
          amount = double.parse(cleaned);
        } catch (_) {}

        final tx = AppTransaction(
          id: const Uuid().v4(),
          userId: userId,
          accountId: widget.accountId,
          amount: (amount * 100).toInt(),
          categoryId: catId,
          note: raw.description,
          type: amount < 0 ? 'expense' : 'income',
          date: date,
          currency: 'USD', // Default or fetch from account
        );

        await repo.addTransaction(tx);
      }

      if (mounted) {
        Navigator.popUntil(context, (route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Import completed successfully!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }
}
