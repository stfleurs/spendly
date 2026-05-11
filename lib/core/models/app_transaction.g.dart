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
      date: const TimestampConverter().fromJson(json['date']),
      accountId: json['accountId'] as String,
      categoryId: json['categoryId'] as String,
      note: json['note'] as String?,
      receiptUrl: json['receiptUrl'] as String?,
      receiptId: json['receiptId'] as String?,
      amountInBaseCurrency:
          (json['amountInBaseCurrency'] as num?)?.toInt() ?? 0,
      baseCurrency: json['baseCurrency'] as String? ?? 'USD',
      exchangeRate: (json['exchangeRate'] as num?)?.toDouble() ?? 1.0,
      rateScale: (json['rateScale'] as num?)?.toInt() ?? 1000000,
      scaledRate: (json['scaledRate'] as num?)?.toInt() ?? 1000000,
      rateSource: json['rateSource'] as String? ?? 'manual',
      rateBaseCurrency: json['rateBaseCurrency'] as String? ?? 'USD',
      rateQuoteCurrency: json['rateQuoteCurrency'] as String? ?? 'USD',
      originalAmount: (json['originalAmount'] as num?)?.toInt(),
      originalCurrency: json['originalCurrency'] as String?,
      sourceHash: json['sourceHash'] as String?,
      searchTokens: (json['searchTokens'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$AppTransactionToJson(_AppTransaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'type': instance.type,
      'amount': instance.amount,
      'currency': instance.currency,
      'date': const TimestampConverter().toJson(instance.date),
      'accountId': instance.accountId,
      'categoryId': instance.categoryId,
      'note': instance.note,
      'receiptUrl': instance.receiptUrl,
      'receiptId': instance.receiptId,
      'amountInBaseCurrency': instance.amountInBaseCurrency,
      'baseCurrency': instance.baseCurrency,
      'exchangeRate': instance.exchangeRate,
      'rateScale': instance.rateScale,
      'scaledRate': instance.scaledRate,
      'rateSource': instance.rateSource,
      'rateBaseCurrency': instance.rateBaseCurrency,
      'rateQuoteCurrency': instance.rateQuoteCurrency,
      'originalAmount': instance.originalAmount,
      'originalCurrency': instance.originalCurrency,
      'sourceHash': instance.sourceHash,
      'searchTokens': instance.searchTokens,
    };
