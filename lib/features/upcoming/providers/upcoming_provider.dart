import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/core/models/bill.dart';
import 'package:spendly/core/models/bill_template.dart';
import 'package:spendly/core/providers/firebase_providers.dart';
import 'package:spendly/features/upcoming/repository/upcoming_repository.dart';

final upcomingRepositoryProvider = Provider<UpcomingRepository>((ref) {
  return UpcomingRepository(ref.watch(firestoreProvider));
});

final billsProvider = StreamProvider.family<List<Bill>, String>((ref, userId) {
  final repository = ref.watch(upcomingRepositoryProvider);
  return repository.getBills(userId).map((bills) {
    bills.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return bills;
  });
});

final billTemplatesProvider =
    StreamProvider.family<List<BillTemplate>, String>((ref, userId) {
  final repository = ref.watch(upcomingRepositoryProvider);
  return repository.getBillTemplates(userId);
});

/// Computes aggregated stats for the dashboard card using [Bill.computedStatus].
final upcomingBillsStatsProvider =
    Provider.family<Map<String, dynamic>, String>((ref, userId) {
  final billsState = ref.watch(billsProvider(userId));

  return billsState.maybeWhen(
    data: (bills) {
      int upcomingTotal = 0;
      int overdueTotal = 0;
      int paidTotal = 0;
      int overdueCount = 0;
      int dueSoonCount = 0;

      for (final bill in bills) {
        switch (bill.computedStatus) {
          case BillStatus.paid:
            paidTotal += bill.amount;
          case BillStatus.overdue:
            overdueTotal += bill.remainingAmount;
            overdueCount++;
          case BillStatus.dueSoon:
            upcomingTotal += bill.remainingAmount;
            dueSoonCount++;
          case BillStatus.partiallyPaid:
          case BillStatus.upcoming:
            upcomingTotal += bill.remainingAmount;
          case BillStatus.cancelled:
            break; // exclude from all totals
        }
      }

      return {
        'upcomingTotal': upcomingTotal,
        'overdueTotal': overdueTotal,
        'paidTotal': paidTotal,
        'overdueCount': overdueCount,
        'dueSoonCount': dueSoonCount,
        'totalItems': bills.length,
      };
    },
    orElse: () => {
      'upcomingTotal': 0,
      'overdueTotal': 0,
      'paidTotal': 0,
      'overdueCount': 0,
      'dueSoonCount': 0,
      'totalItems': 0,
    },
  );
});
