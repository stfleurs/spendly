import 'package:freezed_annotation/freezed_annotation.dart';

part 'bill.freezed.dart';
part 'bill.g.dart';

/// Represents the lifecycle state of a planned payment.
///
/// [computedStatus] derives this automatically from dates + amounts.
/// Store [status] directly only for manual overrides (e.g. [cancelled]).
enum BillStatus {
  @JsonValue('upcoming') upcoming,
  @JsonValue('dueSoon') dueSoon, // within the next 7 days
  @JsonValue('overdue') overdue,
  @JsonValue('partiallyPaid') partiallyPaid,
  @JsonValue('paid') paid,
  @JsonValue('cancelled') cancelled,
}

@freezed
abstract class Bill with _$Bill {
  const factory Bill({
    required String id,
    required String userId,
    required String title,
    required int amount, // expected total, in cents
    @Default(0) int paidAmount, // actual paid so far, in cents
    required DateTime dueDate,
    @Default(BillStatus.upcoming) BillStatus status,
    required String categoryId,
    String? templateId,
    String? receiptId,
    String? linkedTransactionId,
    String? notes,
    List<String>? searchTokens, // Lightweight keywords for V1 search
  }) = _Bill;

  const Bill._();

  // ── Convenience getters ───────────────────────────────────────────────────

  /// True only when the bill has been fully settled.
  bool get isPaid => status == BillStatus.paid;

  bool get isCancelled => status == BillStatus.cancelled;

  int get remainingAmount => (amount - paidAmount).clamp(0, amount);

  /// Auto-derives the correct status from payment amounts and due date.
  /// Respects a manually-set [cancelled] status.
  BillStatus get computedStatus {
    if (status == BillStatus.cancelled) return BillStatus.cancelled;
    if (paidAmount >= amount) return BillStatus.paid;
    if (paidAmount > 0) return BillStatus.partiallyPaid;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (dueDate.isBefore(today)) return BillStatus.overdue;
    if (dueDate.difference(today).inDays <= 7) return BillStatus.dueSoon;
    return BillStatus.upcoming;
  }

  factory Bill.fromJson(Map<String, dynamic> json) => _$BillFromJson(json);
}
