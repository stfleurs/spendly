// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receipt.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Receipt _$ReceiptFromJson(Map<String, dynamic> json) => _Receipt(
  id: json['id'] as String,
  userId: json['userId'] as String,
  imageUrl: json['imageUrl'] as String,
  extractedText: json['extractedText'] as String,
  rawLines: (json['rawLines'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  merchant: json['merchant'] as String?,
  total: (json['total'] as num?)?.toInt(),
  date: json['date'] == null ? null : DateTime.parse(json['date'] as String),
  confidence: (json['confidence'] as num).toDouble(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  processed: json['processed'] as bool? ?? false,
);

Map<String, dynamic> _$ReceiptToJson(_Receipt instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'imageUrl': instance.imageUrl,
  'extractedText': instance.extractedText,
  'rawLines': instance.rawLines,
  'merchant': instance.merchant,
  'total': instance.total,
  'date': instance.date?.toIso8601String(),
  'confidence': instance.confidence,
  'createdAt': instance.createdAt.toIso8601String(),
  'processed': instance.processed,
};
