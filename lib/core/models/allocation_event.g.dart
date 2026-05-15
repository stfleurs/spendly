// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'allocation_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AllocationEvent _$AllocationEventFromJson(Map<String, dynamic> json) =>
    _AllocationEvent(
      id: json['id'] as String,
      userId: json['userId'] as String,
      amount: (json['amount'] as num).toInt(),
      fromEntityId: json['fromEntityId'] as String,
      toEntityId: json['toEntityId'] as String,
      monthId: json['monthId'] as String,
      timestamp: const TimestampConverter().fromJson(json['timestamp']),
    );

Map<String, dynamic> _$AllocationEventToJson(_AllocationEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'amount': instance.amount,
      'fromEntityId': instance.fromEntityId,
      'toEntityId': instance.toEntityId,
      'monthId': instance.monthId,
      'timestamp': const TimestampConverter().toJson(instance.timestamp),
    };
