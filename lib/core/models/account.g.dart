// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Account _$AccountFromJson(Map<String, dynamic> json) => _Account(
  id: json['id'] as String,
  userId: json['userId'] as String,
  name: json['name'] as String,
  type: json['type'] as String,
  currency: json['currency'] as String,
  balance: (json['balance'] as num).toInt(),
  currentBalance: (json['currentBalance'] as num?)?.toInt(),
  transactionCount: (json['transactionCount'] as num?)?.toInt() ?? 0,
  lastTransactionAt: const TimestampNullableConverter().fromJson(
    json['lastTransactionAt'],
  ),
  ledgerVersion: (json['ledgerVersion'] as num?)?.toInt() ?? 1,
  lastCalculatedAt: const TimestampNullableConverter().fromJson(
    json['lastCalculatedAt'],
  ),
  lastLedgerMutationId: json['lastLedgerMutationId'] as String?,
  creditLimit: (json['creditLimit'] as num?)?.toInt() ?? 0,
  snapshotHealthy: json['snapshotHealthy'] as bool? ?? true,
  lastReconciledAt: const TimestampNullableConverter().fromJson(
    json['lastReconciledAt'],
  ),
  color: json['color'] as String?,
);

Map<String, dynamic> _$AccountToJson(_Account instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'name': instance.name,
  'type': instance.type,
  'currency': instance.currency,
  'balance': instance.balance,
  'currentBalance': instance.currentBalance,
  'transactionCount': instance.transactionCount,
  'lastTransactionAt': const TimestampNullableConverter().toJson(
    instance.lastTransactionAt,
  ),
  'ledgerVersion': instance.ledgerVersion,
  'lastCalculatedAt': const TimestampNullableConverter().toJson(
    instance.lastCalculatedAt,
  ),
  'lastLedgerMutationId': instance.lastLedgerMutationId,
  'creditLimit': instance.creditLimit,
  'snapshotHealthy': instance.snapshotHealthy,
  'lastReconciledAt': const TimestampNullableConverter().toJson(
    instance.lastReconciledAt,
  ),
  'color': instance.color,
};
