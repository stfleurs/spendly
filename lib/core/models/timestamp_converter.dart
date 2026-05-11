import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

class TimestampConverter implements JsonConverter<DateTime, dynamic> {
  const TimestampConverter();

  @override
  DateTime fromJson(dynamic json) {
    if (json is Timestamp) return json.toDate();
    if (json is String) return DateTime.parse(json);
    throw FormatException('Invalid timestamp format: $json');
  }

  @override
  dynamic toJson(DateTime date) => Timestamp.fromDate(date);
}

class TimestampNullableConverter implements JsonConverter<DateTime?, dynamic> {
  const TimestampNullableConverter();

  @override
  DateTime? fromJson(dynamic json) {
    if (json == null) return null;
    if (json is Timestamp) return json.toDate();
    if (json is String) return DateTime.parse(json);
    return null;
  }

  @override
  dynamic toJson(DateTime? date) =>
      date == null ? null : Timestamp.fromDate(date);
}
