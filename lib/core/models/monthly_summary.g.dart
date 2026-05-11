// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MonthlySummary _$MonthlySummaryFromJson(Map<String, dynamic> json) =>
    _MonthlySummary(
      id: json['id'] as String,
      userId: json['userId'] as String,
      income: (json['income'] as num?)?.toInt() ?? 0,
      expenses: (json['expenses'] as num?)?.toInt() ?? 0,
      netChange: (json['netChange'] as num?)?.toInt() ?? 0,
      categoryTotals:
          (json['categoryTotals'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
      accountTotals:
          (json['accountTotals'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
      currencyBreakdown:
          (json['currencyBreakdown'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, Map<String, int>.from(e as Map)),
          ) ??
          const {},
      transactionCount: (json['transactionCount'] as num?)?.toInt() ?? 0,
      lastUpdatedAt: const TimestampConverter().fromJson(json['lastUpdatedAt']),
    );

Map<String, dynamic> _$MonthlySummaryToJson(
  _MonthlySummary instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'income': instance.income,
  'expenses': instance.expenses,
  'netChange': instance.netChange,
  'categoryTotals': instance.categoryTotals,
  'accountTotals': instance.accountTotals,
  'currencyBreakdown': instance.currencyBreakdown,
  'transactionCount': instance.transactionCount,
  'lastUpdatedAt': const TimestampConverter().toJson(instance.lastUpdatedAt),
};
