// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_net_worth.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DailyNetWorth _$DailyNetWorthFromJson(Map<String, dynamic> json) =>
    _DailyNetWorth(
      id: json['id'] as String,
      userId: json['userId'] as String,
      date: const TimestampConverter().fromJson(json['date']),
      netWorth: (json['netWorth'] as num).toInt(),
      ledgerVersion: (json['ledgerVersion'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$DailyNetWorthToJson(_DailyNetWorth instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'date': const TimestampConverter().toJson(instance.date),
      'netWorth': instance.netWorth,
      'ledgerVersion': instance.ledgerVersion,
    };
