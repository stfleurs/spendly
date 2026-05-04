// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Category _$CategoryFromJson(Map<String, dynamic> json) => _Category(
  id: json['id'] as String,
  userId: json['userId'] as String,
  name: json['name'] as String,
  group: json['group'] as String,
  monthlyTarget: (json['monthlyTarget'] as num?)?.toInt(),
  currency: json['currency'] as String? ?? 'USD',
  recurrence: json['recurrence'] as String? ?? 'Monthly',
);

Map<String, dynamic> _$CategoryToJson(_Category instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'name': instance.name,
  'group': instance.group,
  'monthlyTarget': instance.monthlyTarget,
  'currency': instance.currency,
  'recurrence': instance.recurrence,
};
