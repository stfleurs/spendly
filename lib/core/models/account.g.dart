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
  color: json['color'] as String?,
);

Map<String, dynamic> _$AccountToJson(_Account instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'name': instance.name,
  'type': instance.type,
  'currency': instance.currency,
  'balance': instance.balance,
  'color': instance.color,
};
