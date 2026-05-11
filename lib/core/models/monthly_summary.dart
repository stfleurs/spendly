import 'package:freezed_annotation/freezed_annotation.dart';
import 'timestamp_converter.dart';

part 'monthly_summary.freezed.dart';
part 'monthly_summary.g.dart';

@freezed
abstract class MonthlySummary with _$MonthlySummary {
  const MonthlySummary._();

  const factory MonthlySummary({
    required String id, // format: yyyy_mm
    required String userId,
    @Default(0) int income, // Normalized in Base Currency
    @Default(0) int expenses, // Normalized in Base Currency
    @Default(0) int netChange, // Normalized in Base Currency
    @Default({}) Map<String, int> categoryTotals, // Normalized in Base Currency
    @Default({}) Map<String, int> accountTotals, // Normalized in Base Currency
    @Default({}) Map<String, Map<String, int>> currencyBreakdown, // Namespaced RAW amounts (Rule #5)
    @Default(0) int transactionCount,
    @TimestampConverter() required DateTime lastUpdatedAt,
  }) = _MonthlySummary;

  factory MonthlySummary.fromJson(Map<String, dynamic> json) =>
      _$MonthlySummaryFromJson(json);
}
