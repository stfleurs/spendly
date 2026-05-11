// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill_template.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BillTemplate _$BillTemplateFromJson(Map<String, dynamic> json) =>
    _BillTemplate(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      defaultAmount: (json['defaultAmount'] as num).toInt(),
      categoryId: json['categoryId'] as String,
      frequency: json['frequency'] as String? ?? 'Monthly',
      totalAmount: (json['totalAmount'] as num?)?.toInt(),
      description: json['description'] as String?,
      defaultAccountId: json['defaultAccountId'] as String?,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$BillTemplateToJson(_BillTemplate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'title': instance.title,
      'defaultAmount': instance.defaultAmount,
      'categoryId': instance.categoryId,
      'frequency': instance.frequency,
      'totalAmount': instance.totalAmount,
      'description': instance.description,
      'defaultAccountId': instance.defaultAccountId,
      'notes': instance.notes,
    };
