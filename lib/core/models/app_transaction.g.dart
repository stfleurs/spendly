// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppTransaction _$AppTransactionFromJson(Map<String, dynamic> json) =>
    _AppTransaction(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: json['type'] as String,
      amount: (json['amount'] as num).toInt(),
      currency: json['currency'] as String,
      date: DateTime.parse(json['date'] as String),
      accountId: json['accountId'] as String,
      categoryId: json['categoryId'] as String,
      note: json['note'] as String?,
      receiptUrl: json['receiptUrl'] as String?,
      receiptId: json['receiptId'] as String?,
      originalAmount: (json['originalAmount'] as num?)?.toInt(),
      originalCurrency: json['originalCurrency'] as String?,
      exchangeRate: (json['exchangeRate'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$AppTransactionToJson(_AppTransaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'type': instance.type,
      'amount': instance.amount,
      'currency': instance.currency,
      'date': instance.date.toIso8601String(),
      'accountId': instance.accountId,
      'categoryId': instance.categoryId,
      'note': instance.note,
      'receiptUrl': instance.receiptUrl,
      'receiptId': instance.receiptId,
      'originalAmount': instance.originalAmount,
      'originalCurrency': instance.originalCurrency,
      'exchangeRate': instance.exchangeRate,
    };
