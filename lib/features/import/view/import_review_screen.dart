import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/shared/themes/app_theme.dart';
import 'package:spendly/shared/widgets/app_header.dart';
import 'package:spendly/features/import/providers/import_provider.dart';
import 'package:spendly/features/import/repository/import_repository.dart';
import 'package:spendly/features/budget/providers/budget_provider.dart';
import 'package:spendly/features/transactions/repository/transaction_repository.dart';
import 'package:spendly/core/models/app_transaction.dart';
import 'package:spendly/core/providers/firebase_providers.dart';
import 'package:spendly/features/ocr/repository/financial_intelligence_repository.dart';
import 'package:spendly/core/providers/date_provider.dart';
import 'package:spendly/core/providers/currency_provider.dart';
import 'package:spendly/features/accounts/repository/account_repository.dart';
import 'package:spendly/core/providers/exchange_rate_provider.dart';
import 'package:spendly/core/providers/device_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class ImportReviewScreen extends ConsumerStatefulWidget {
  final String accountId;
  const ImportReviewScreen({super.key, required this.accountId});

  @override
  ConsumerState<ImportReviewScreen> createState() => _ImportReviewScreenState();
}

class _ImportReviewScreenState extends ConsumerState<ImportReviewScreen> {
  final Map<int, String?> _selectedCategoryIds = {};
  final Map<int, String> _normalizedMerchants = {};
  bool _isImporting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _guessAllCategories();
    });
  }

  Future<void> _guessAllCategories() async {
    final state = ref.read(importProvider);
    final userId = ref.read(authStateProvider).value?.uid ?? '';
    final intelligence = ref.read(financialIntelligenceRepositoryProvider);
    final budgetAsync = ref.read(budgetProvider(userId));

    final budget = budgetAsync.value;
    if (budget == null) return;

    for (int i = 0; i < state.parsedTransactions.length; i++) {
      final tx = state.parsedTransactions[i];
      final prediction = await intelligence.predictMerchant(userId, tx.description);

      if (mounted) {
        setState(() {
          _normalizedMerchants[i] = prediction.merchant;
        });

        if (prediction.categoryId != null) {
          final category = budget.items.map((item) => item.category).firstWhere(
                (c) => c.id == prediction.categoryId,
                orElse: () => budget.items.first.category,
              );

          setState(() {
            _selectedCategoryIds[i] = category.id;
          });
        }
      }
    }
  }

  String _generateSourceHash(dynamic raw, String accountId) {
    final input = '${raw.date}|${raw.amount}|${raw.description}|$accountId';
    return sha256.convert(utf8.encode(input)).toString();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(importProvider);
    final userId = ref.watch(authStateProvider).value?.uid ?? '';
    final budgetAsync = ref.watch(budgetProvider(userId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          const SliverAppHeader(title: 'Import', showBackButton: true),
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
                  if (state.parserType == PDFParserType.fallback || state.parserType == PDFParserType.ocr) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: state.parserType == PDFParserType.ocr ? AppColors.primary.withValues(alpha: 0.1) : Colors.amber.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: state.parserType == PDFParserType.ocr ? AppColors.primary.withValues(alpha: 0.3) : Colors.amber.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            state.parserType == PDFParserType.ocr ? Icons.psychology : Icons.auto_awesome, 
                            color: state.parserType == PDFParserType.ocr ? AppColors.primary : Colors.amber, 
                            size: 16
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              state.parserType == PDFParserType.ocr 
                                ? 'AI Compatibility Mode: Used visual recognition (OCR) for this statement.'
                                : 'Compatibility Mode Active: Used fallback extraction for this statement.',
                              style: TextStyle(
                                color: state.parserType == PDFParserType.ocr ? AppColors.primary : Colors.amber, 
                                fontSize: 11, 
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
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
        ),
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
            _normalizedMerchants[index] ?? tx.description,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (_normalizedMerchants[index] != null &&
              _normalizedMerchants[index] != tx.description)
            Text(
              'Original: ${tx.description}',
              style: const TextStyle(color: AppColors.textLight, fontSize: 10),
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

  DateTime _parseSmartDate(String rawDate) {
    final now = DateTime.now();
    final clean = rawDate.trim().toLowerCase();
    
    // Try DD MMM YYYY or DD MMM (English/French)
    final textMonthRegex = RegExp(r'^(\d{1,2})[\s-]+([a-z]{3,6})(?:[\s-]+(\d{2,4}))?$');
    final match = textMonthRegex.firstMatch(clean);
    if (match != null) {
      final day = int.parse(match.group(1)!);
      final monthStr = match.group(2)!;
      final yearStr = match.group(3);
      
      int year = now.year;
      if (yearStr != null) {
        year = int.parse(yearStr);
        if (year < 100) year += 2000;
      }

      int month = 1;
      if (monthStr.startsWith('jan')) { month = 1; }
      else if (monthStr.startsWith('feb') || monthStr.startsWith('fev') || monthStr.startsWith('fév')) { month = 2; }
      else if (monthStr.startsWith('mar')) { month = 3; }
      else if (monthStr.startsWith('apr') || monthStr.startsWith('avr')) { month = 4; }
      else if (monthStr.startsWith('may') || monthStr.startsWith('mai')) { month = 5; }
      else if (monthStr.startsWith('jun') || monthStr.startsWith('juin')) { month = 6; }
      else if (monthStr.startsWith('jul') || monthStr.startsWith('juil')) { month = 7; }
      else if (monthStr.startsWith('aug') || monthStr.startsWith('août') || monthStr.startsWith('aou')) { month = 8; }
      else if (monthStr.startsWith('sep')) { month = 9; }
      else if (monthStr.startsWith('oct')) { month = 10; }
      else if (monthStr.startsWith('nov')) { month = 11; }
      else if (monthStr.startsWith('dec') || monthStr.startsWith('déc')) { month = 12; }

      return DateTime(year, month, day);
    }

    // Try DD/MM/YYYY or DD-MM-YYYY or DD.MM.YYYY
    final numRegex = RegExp(r'^(\d{1,2})[/.-](\d{1,2})[/.-](\d{2,4})$');
    final numMatch = numRegex.firstMatch(clean);
    if (numMatch != null) {
      final p1 = int.parse(numMatch.group(1)!);
      final p2 = int.parse(numMatch.group(2)!);
      int p3 = int.parse(numMatch.group(3)!);
      if (p3 < 100) p3 += 2000;
      
      // Default to DD/MM/YYYY. If p2 > 12, then it must be MM/DD/YYYY
      int day = p1;
      int month = p2;
      if (p2 > 12) {
        month = p1;
        day = p2;
      }
      return DateTime(p3, month, day);
    }
    
    // Fallback to strict ISO parse
    try {
      return DateTime.parse(clean.replaceAll('/', '-'));
    } catch (_) {
      return now;
    }
  }

  Future<void> _finalizeImport(String userId, List<dynamic> rawTxs) async {
    setState(() => _isImporting = true);
    
    try {
      final repo = ref.read(transactionRepositoryProvider);
      
      // Track occurrences of identical hashes within this import batch
      // to handle cases where there are legitimately multiple identical transactions on the same day
      final Map<String, int> occurrenceCounter = {};
      
      int successCount = 0;
      int duplicateCount = 0;
      int errorCount = 0;
      
      for (int i = 0; i < rawTxs.length; i++) {
        try {
          final raw = rawTxs[i];
          final catId = _selectedCategoryIds[i] ?? 'default'; // In a real app, handle default better
          
          final DateTime date = _parseSmartDate(raw.date);
          
          double amount = 0;
          try {
            String rawAmount = raw.amount.toString();
            // Handle European format: "1.234,56" -> "1234.56"
            if (rawAmount.contains(',') && rawAmount.contains('.')) {
              if (rawAmount.indexOf('.') < rawAmount.indexOf(',')) {
                rawAmount = rawAmount.replaceAll('.', '').replaceAll(',', '.');
              } else {
                rawAmount = rawAmount.replaceAll(',', '');
              }
            } else if (rawAmount.contains(',')) {
              // If only comma, it might be the decimal separator "1234,56" or thousands "1,234"
              // We'll assume it's decimal if there's only 2 digits after it
              final parts = rawAmount.split(',');
              if (parts.last.length == 2) {
                rawAmount = rawAmount.replaceAll(',', '.');
              } else {
                rawAmount = rawAmount.replaceAll(',', '');
              }
            }
            
            final String cleaned = rawAmount.replaceAll(RegExp(r'[^0-9.-]'), '').trim();
            amount = double.parse(cleaned);
          } catch (e) {
             debugPrint('Spendly: Amount parse failed for "${raw.amount}": $e');
          }

          final baseHash = _generateSourceHash(raw, widget.accountId);
          
          // Increment occurrence for this exact hash
          final currentCount = (occurrenceCounter[baseHash] ?? 0) + 1;
          occurrenceCounter[baseHash] = currentCount;
          
          final uniqueSourceHash = '${baseHash}_$currentCount';

          final accountAsync = ref.read(accountsStreamProvider(userId));
          final accounts = accountAsync.value;
          final account = accounts?.firstWhere((a) => a.id == widget.accountId);
          final String txCurrency = account?.currency ?? 'USD';
          final baseCurrency = ref.read(currencyProvider);
          final double rate = ref.read(exchangeRateProvider((userId: userId, from: txCurrency, to: baseCurrency)));
          
          // Rule #2: Scaled Integer Math
          const int rateScale = 1000000;
          final int scaledRate = (rate * rateScale).round();
          final int amountCents = (amount.abs() * 100).toInt();
          final int normalizedAmount = (amountCents * scaledRate) ~/ rateScale;



          final deviceId = ref.read(deviceIdProvider).value;
          final sequence = await ref.read(mutationSequenceProvider.notifier).increment();

          final tx = AppTransaction(
            id: const Uuid().v4(),
            idempotencyKey: uniqueSourceHash,
            mutationSource: 'import',
            deviceId: deviceId,
            mutationSequence: sequence,
            userId: userId,
            accountId: widget.accountId,
            amount: amountCents,
            amountInBaseCurrency: normalizedAmount,
            baseCurrency: baseCurrency,
            exchangeRate: rate,
            scaledRate: scaledRate,
            rateScale: rateScale,
            rateSource: 'import',
            rateBaseCurrency: baseCurrency,
            rateQuoteCurrency: txCurrency,
            categoryId: catId,
            note: raw.description,
            type: amount < 0 ? 'expense' : 'income',
            date: date,
            currency: txCurrency,
            sourceHash: uniqueSourceHash,
          );

          // Historical imports use TransactionSource.import which securely bypasses balance validation
          final result = await repo.addTransaction(tx, source: TransactionSource.import);
          
          if (result == TransactionInsertResult.success) {
            successCount++;
            // Record interaction for intelligence learning
            await ref
                .read(financialIntelligenceRepositoryProvider)
                .recordMerchantInteraction(
                  userId: userId,
                  rawMerchant: raw.description,
                  correctedMerchant: _normalizedMerchants[i] ?? raw.description,
                  categoryId: catId,
                  accountId: widget.accountId,
                  currency: txCurrency,
                );
          } else if (result == TransactionInsertResult.duplicate) {
            duplicateCount++;
          } else {
            errorCount++;
          }
        } catch (e) {
          debugPrint('Spendly: Failed to import row $i: $e');
          errorCount++;
          continue;
        }
      }

      if (mounted) {
        if (successCount > 0 && rawTxs.isNotEmpty) {
          // Automatically switch the global app date to the month of the imported statement
          // so the user immediately sees their transactions in the Activity Tab instead of an empty current month.
          final lastDate = _parseSmartDate(rawTxs.last.date);
          ref.read(selectedDateProvider.notifier).select(DateTime(lastDate.year, lastDate.month, 1));
        }

        Navigator.popUntil(context, (route) => route.isFirst);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Import Complete'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${rawTxs.length} transactions detected', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('✅ $successCount imported successfully', style: const TextStyle(color: Colors.green)),
                if (duplicateCount > 0) 
                  Text('⏭️ $duplicateCount duplicates skipped', style: const TextStyle(color: Colors.orange)),
                if (errorCount > 0) 
                  Text('❌ $errorCount errors', style: const TextStyle(color: Colors.red)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('DONE'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fatal Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }
}
