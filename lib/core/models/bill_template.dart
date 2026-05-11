import 'package:freezed_annotation/freezed_annotation.dart';

part 'bill_template.freezed.dart';
part 'bill_template.g.dart';

@freezed
abstract class BillTemplate with _$BillTemplate {
  const factory BillTemplate({
    required String id,
    required String userId,
    required String title,
    required int defaultAmount,  // default installment amount, in cents
    @Default('USD') String currency,
    required String categoryId,
    @Default('Monthly') String frequency, // One-time, Weekly, Monthly, Yearly
    // ── Plan / umbrella fields ──────────────────────────────────────────────
    int? totalAmount,     // total obligation (e.g. full year tuition), in cents
    String? description,  // human-readable note, e.g. "2025-26 school year"
    String? defaultAccountId,
    String? notes,
  }) = _BillTemplate;

  const BillTemplate._();
  factory BillTemplate.fromJson(Map<String, dynamic> json) =>
      _$BillTemplateFromJson(json);
}
