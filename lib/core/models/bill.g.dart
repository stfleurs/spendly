// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Bill _$BillFromJson(Map<String, dynamic> json) => _Bill(
  id: json['id'] as String,
  userId: json['userId'] as String,
  title: json['title'] as String,
  amount: (json['amount'] as num).toInt(),
  currency: json['currency'] as String? ?? 'USD',
  paidAmount: (json['paidAmount'] as num?)?.toInt() ?? 0,
  dueDate: DateTime.parse(json['dueDate'] as String),
  status:
      $enumDecodeNullable(_$BillStatusEnumMap, json['status']) ??
      BillStatus.upcoming,
  categoryId: json['categoryId'] as String,
  templateId: json['templateId'] as String?,
  receiptId: json['receiptId'] as String?,
  linkedTransactionId: json['linkedTransactionId'] as String?,
  notes: json['notes'] as String?,
  searchTokens: (json['searchTokens'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$BillToJson(_Bill instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'title': instance.title,
  'amount': instance.amount,
  'currency': instance.currency,
  'paidAmount': instance.paidAmount,
  'dueDate': instance.dueDate.toIso8601String(),
  'status': _$BillStatusEnumMap[instance.status]!,
  'categoryId': instance.categoryId,
  'templateId': instance.templateId,
  'receiptId': instance.receiptId,
  'linkedTransactionId': instance.linkedTransactionId,
  'notes': instance.notes,
  'searchTokens': instance.searchTokens,
};

const _$BillStatusEnumMap = {
  BillStatus.upcoming: 'upcoming',
  BillStatus.dueSoon: 'dueSoon',
  BillStatus.overdue: 'overdue',
  BillStatus.partiallyPaid: 'partiallyPaid',
  BillStatus.paid: 'paid',
  BillStatus.cancelled: 'cancelled',
};
