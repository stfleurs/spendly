import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/shared/themes/app_theme.dart';
import 'package:spendly/shared/widgets/app_header.dart';
import 'package:spendly/shared/widgets/main_card.dart';
import 'package:spendly/features/import/providers/import_provider.dart';
import 'package:spendly/features/accounts/repository/account_repository.dart';
import 'package:spendly/core/providers/firebase_providers.dart';
import 'package:spendly/features/import/view/csv_mapping_screen.dart';
import 'package:spendly/features/import/view/import_review_screen.dart';

class ImportScreen extends ConsumerStatefulWidget {
  final String? initialAccountId;
  const ImportScreen({super.key, this.initialAccountId});

  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  String? _selectedAccountId;

  @override
  void initState() {
    super.initState();
    _selectedAccountId = widget.initialAccountId;
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(authStateProvider).value?.uid ?? '';
    final accountsAsync = ref.watch(accountsStreamProvider(userId));
    final importState = ref.watch(importProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          const SliverAppHeader(title: 'IMPORT DATA', showBackButton: true),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SELECT TARGET ACCOUNT',
                    style: TextStyle(color: AppColors.textLight, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  accountsAsync.when(
                    data: (accounts) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedAccountId,
                          isExpanded: true,
                          hint: const Text('Choose Account'),
                          items: accounts.map((a) => DropdownMenuItem(value: a.id, child: Text(a.name))).toList(),
                          onChanged: (val) => setState(() => _selectedAccountId = val),
                        ),
                      ),
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (err, stack) => const Text('Error loading accounts'),
                  ),
                  const SizedBox(height: 32),
                  
                  const Text(
                    'CHOOSE FILE',
                    style: TextStyle(color: AppColors.textLight, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  MainCard(
                    child: InkWell(
                      onTap: _selectedAccountId == null ? null : () async {
                        final navigator = Navigator.of(context);
                        await ref.read(importProvider.notifier).pickFile();
                        
                        if (!mounted) return;
                        
                        final newState = ref.read(importProvider);
                        if (newState.selectedFile != null) {
                          if (newState.csvData.isNotEmpty) {
                            navigator.push(
                              MaterialPageRoute(builder: (context) => CsvMappingScreen(accountId: _selectedAccountId!)),
                            );
                          } else if (newState.parsedTransactions.isNotEmpty) {
                            navigator.push(
                              MaterialPageRoute(builder: (context) => ImportReviewScreen(accountId: _selectedAccountId!)),
                            );
                          }
                        }
                      },
                      child: Opacity(
                        opacity: _selectedAccountId == null ? 0.5 : 1.0,
                        child: Column(
                          children: [
                            const Icon(Icons.upload_file, size: 48, color: AppColors.primary),
                            const SizedBox(height: 16),
                            const Text(
                              'Tap to select CSV or PDF',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Supported formats: .csv, .pdf',
                              style: TextStyle(color: AppColors.textLight, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  if (importState.isLoading) ...[
                    const SizedBox(height: 32),
                    const Center(child: CircularProgressIndicator()),
                  ],
                  
                  if (importState.error != null) ...[
                    const SizedBox(height: 32),
                    Text(
                      'Error: ${importState.error}',
                      style: const TextStyle(color: AppColors.expense),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
