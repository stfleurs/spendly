// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'financial_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FinancialSummary _$FinancialSummaryFromJson(Map<String, dynamic> json) =>
    _FinancialSummary(
      userId: json['userId'] as String,
      netWorth: (json['netWorth'] as num?)?.toInt() ?? 0,
      totalAssets: (json['totalAssets'] as num?)?.toInt() ?? 0,
      totalDebt: (json['totalDebt'] as num?)?.toInt() ?? 0,
      cashFlow30d: (json['cashFlow30d'] as num?)?.toInt() ?? 0,
      baseCurrency: json['baseCurrency'] as String,
      updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
      ledgerVersion: (json['ledgerVersion'] as num?)?.toInt() ?? 1,
      reconciled: json['reconciled'] as bool? ?? false,
    );

Map<String, dynamic> _$FinancialSummaryToJson(_FinancialSummary instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'netWorth': instance.netWorth,
      'totalAssets': instance.totalAssets,
      'totalDebt': instance.totalDebt,
      'cashFlow30d': instance.cashFlow30d,
      'baseCurrency': instance.baseCurrency,
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
      'ledgerVersion': instance.ledgerVersion,
      'reconciled': instance.reconciled,
    };
