// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'money.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Money _$MoneyFromJson(Map<String, dynamic> json) => _Money(
  amount: (json['amount'] as num).toInt(),
  currency: json['currency'] as String,
);

Map<String, dynamic> _$MoneyToJson(_Money instance) => <String, dynamic>{
  'amount': instance.amount,
  'currency': instance.currency,
};

_NormalizedMoney _$NormalizedMoneyFromJson(Map<String, dynamic> json) =>
    _NormalizedMoney(
      original: Money.fromJson(json['original'] as Map<String, dynamic>),
      baseAmount: (json['baseAmount'] as num).toInt(),
      baseCurrency: json['baseCurrency'] as String,
      exchangeRate: (json['exchangeRate'] as num).toDouble(),
      rateSource: json['rateSource'] as String? ?? 'manual',
    );

Map<String, dynamic> _$NormalizedMoneyToJson(_NormalizedMoney instance) =>
    <String, dynamic>{
      'original': instance.original,
      'baseAmount': instance.baseAmount,
      'baseCurrency': instance.baseCurrency,
      'exchangeRate': instance.exchangeRate,
      'rateSource': instance.rateSource,
    };
