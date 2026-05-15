// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppUser _$AppUserFromJson(Map<String, dynamic> json) => _AppUser(
  id: json['id'] as String,
  name: json['name'] as String,
  baseCurrency: json['baseCurrency'] as String,
  readyToAssign: (json['readyToAssign'] as num?)?.toInt() ?? 0,
  createdAt: DateTime.parse(json['createdAt'] as String),
  exchangeRates:
      (json['exchangeRates'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ) ??
      const {},
  rateMode: json['rateMode'] as String? ?? 'manual',
  ledgerVersion: (json['ledgerVersion'] as num?)?.toInt() ?? 1,
);

Map<String, dynamic> _$AppUserToJson(_AppUser instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'baseCurrency': instance.baseCurrency,
  'readyToAssign': instance.readyToAssign,
  'createdAt': instance.createdAt.toIso8601String(),
  'exchangeRates': instance.exchangeRates,
  'rateMode': instance.rateMode,
  'ledgerVersion': instance.ledgerVersion,
};
