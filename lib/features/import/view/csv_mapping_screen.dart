import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/shared/themes/app_theme.dart';
import 'package:spendly/shared/widgets/app_header.dart';
import 'package:spendly/features/import/providers/import_provider.dart';
import 'package:spendly/features/import/view/import_review_screen.dart';

class CsvMappingScreen extends ConsumerWidget {
  final String accountId;
  const CsvMappingScreen({super.key, required this.accountId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(importProvider);
    final notifier = ref.read(importProvider.notifier);

    if (state.csvData.isEmpty) {
      return const Scaffold(body: Center(child: Text('No data found')));
    }

    final headers = state.csvData[state.headerRowIndex];
    final previewRows = state.csvData.skip(state.headerRowIndex + 1).take(5).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          const SliverAppHeader(title: 'MAP COLUMNS', showBackButton: true),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'MAP CSV COLUMNS TO FIELDS',
                    style: TextStyle(color: AppColors.textLight, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  _buildMappingDropdown(
                    label: 'DATE',
                    field: 'date',
                    headers: headers,
                    currentValue: state.columnMapping['date'],
                    onChanged: (val) => notifier.updateMapping('date', val!),
                  ),
                  const SizedBox(height: 16),
                  _buildMappingDropdown(
                    label: 'DESCRIPTION / MERCHANT',
                    field: 'description',
                    headers: headers,
                    currentValue: state.columnMapping['description'],
                    onChanged: (val) => notifier.updateMapping('description', val!),
                  ),
                  const SizedBox(height: 16),
                  _buildMappingDropdown(
                    label: 'AMOUNT (UNIFIED)',
                    field: 'amount',
                    headers: headers,
                    currentValue: state.columnMapping['amount'],
                    onChanged: (val) => notifier.updateMapping('amount', val!),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'OR IF AMOUNTS ARE SPLIT:',
                    style: TextStyle(color: AppColors.textLight, fontWeight: FontWeight.bold, fontSize: 10),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMappingDropdown(
                          label: 'DEBIT (EXPENSE)',
                          field: 'debit',
                          headers: headers,
                          currentValue: state.columnMapping['debit'],
                          onChanged: (val) => notifier.updateMapping('debit', val!),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildMappingDropdown(
                          label: 'CREDIT (INCOME)',
                          field: 'credit',
                          headers: headers,
                          currentValue: state.columnMapping['credit'],
                          onChanged: (val) => notifier.updateMapping('credit', val!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  const Text(
                    'DATA PREVIEW (TOP 5 ROWS)',
                    style: TextStyle(color: AppColors.textLight, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(AppColors.primary.withValues(alpha: 0.1)),
                      columns: headers.map((h) => DataColumn(label: Text(h.toString().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)))).toList(),
                      rows: previewRows.map((row) => DataRow(cells: row.map((c) => DataCell(Text(c.toString()))).toList())).toList(),
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        notifier.parseCsvWithMapping();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ImportReviewScreen(accountId: accountId)),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('CONTINUE TO REVIEW', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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

  Widget _buildMappingDropdown({
    required String label,
    required String field,
    required List<dynamic> headers,
    required int? currentValue,
    required ValueChanged<int?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          Text(label, style: const TextStyle(color: AppColors.textLight, fontSize: 10, fontWeight: FontWeight.bold)),
          DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: currentValue,
              isExpanded: true,
              hint: const Text('Select column'),
              items: List.generate(headers.length, (index) => DropdownMenuItem(value: index, child: Text(headers[index].toString()))),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
