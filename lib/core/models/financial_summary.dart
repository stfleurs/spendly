import 'package:freezed_annotation/freezed_annotation.dart';
import 'timestamp_converter.dart';

part 'financial_summary.freezed.dart';
part 'financial_summary.g.dart';

@freezed
abstract class FinancialSummary with _$FinancialSummary {
  const factory FinancialSummary({
    required String userId,
    @Default(0) int netWorth, // Base Currency
    @Default(0) int totalAssets, // Base Currency
    @Default(0) int totalDebt, // Base Currency
    @Default(0) int cashFlow30d, // Base Currency
    required String baseCurrency,
    @TimestampConverter() required DateTime updatedAt,
    @Default(1) int ledgerVersion,
    @Default(false) bool reconciled,
  }) = _FinancialSummary;

  const FinancialSummary._();
  factory FinancialSummary.fromJson(Map<String, dynamic> json) =>
      _$FinancialSummaryFromJson(json);
}
