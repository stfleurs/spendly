import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:spendly/core/models/app_transaction.dart';
import 'package:spendly/core/models/account.dart';
import 'package:spendly/core/models/category.dart';

class DataExportService {
  Future<void> exportToCsv({
    required List<AppTransaction> transactions,
    required List<Account> accounts,
    required Map<String, Category> catMap,
  }) async {
    final List<List<dynamic>> rows = [];

    // Header
    rows.add([
      'Date',
      'Merchant/Note',
      'Amount',
      'Type',
      'Category',
      'Account',
      'Has Receipt',
      'Receipt URL'
    ]);

    final accountMap = {for (var a in accounts) a.id: a.name};

    for (var t in transactions) {
      rows.add([
        t.date.toIso8601String(),
        t.note ?? '',
        t.amount,
        t.type,
        catMap[t.categoryId]?.name ?? 'Uncategorized',
        accountMap[t.accountId] ?? 'Unknown',
        t.receiptUrl != null ? 'Yes' : 'No',
        t.receiptUrl ?? '',
      ]);
    }

    final csvString = const ListToCsvConverter().convert(rows);
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/receetpro_export_${DateTime.now().millisecondsSinceEpoch}.csv');

    await file.writeAsString(csvString);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        subject: 'Receet Pro Data Export (CSV)',
      ),
    );
  }

  Future<void> exportToJson({
    required List<AppTransaction> transactions,
    required List<Account> accounts,
  }) async {
    final data = {
      'export_date': DateTime.now().toIso8601String(),
      'transactions': transactions.map((t) => (t as dynamic).toJson()).toList(),
      'accounts': accounts.map((a) => (a as dynamic).toJson()).toList(),
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(data);
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/receetpro_backup_${DateTime.now().millisecondsSinceEpoch}.json');

    await file.writeAsString(jsonString);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        subject: 'Receet Pro Data Backup (JSON)',
      ),
    );
  }
}
