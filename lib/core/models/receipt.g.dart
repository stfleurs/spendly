// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receipt.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OCRLine _$OCRLineFromJson(Map<String, dynamic> json) => _OCRLine(
  text: json['text'] as String,
  bounds: const RectConverter().fromJson(
    json['bounds'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$OCRLineToJson(_OCRLine instance) => <String, dynamic>{
  'text': instance.text,
  'bounds': const RectConverter().toJson(instance.bounds),
};

_ReceiptItem _$ReceiptItemFromJson(Map<String, dynamic> json) => _ReceiptItem(
  description: json['description'] as String,
  amount: (json['amount'] as num).toInt(),
  quantity: (json['quantity'] as num?)?.toInt(),
  unitPrice: (json['unitPrice'] as num?)?.toInt(),
);

Map<String, dynamic> _$ReceiptItemToJson(_ReceiptItem instance) =>
    <String, dynamic>{
      'description': instance.description,
      'amount': instance.amount,
      'quantity': instance.quantity,
      'unitPrice': instance.unitPrice,
    };

_Receipt _$ReceiptFromJson(Map<String, dynamic> json) => _Receipt(
  id: json['id'] as String,
  userId: json['userId'] as String,
  imageUrl: json['imageUrl'] as String,
  extractedText: json['extractedText'] as String,
  lines: (json['lines'] as List<dynamic>)
      .map((e) => OCRLine.fromJson(e as Map<String, dynamic>))
      .toList(),
  merchant: json['merchant'] as String?,
  address: json['address'] as String?,
  phone: json['phone'] as String?,
  email: json['email'] as String?,
  subtotal: (json['subtotal'] as num?)?.toInt(),
  tax: (json['tax'] as num?)?.toInt(),
  total: (json['total'] as num?)?.toInt(),
  date: json['date'] == null ? null : DateTime.parse(json['date'] as String),
  paymentMethod: json['paymentMethod'] as String?,
  receiptNumber: json['receiptNumber'] as String?,
  confidence: (json['confidence'] as num).toDouble(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  processed: json['processed'] as bool? ?? false,
  items: (json['items'] as List<dynamic>?)
      ?.map((e) => ReceiptItem.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ReceiptToJson(_Receipt instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'imageUrl': instance.imageUrl,
  'extractedText': instance.extractedText,
  'lines': instance.lines,
  'merchant': instance.merchant,
  'address': instance.address,
  'phone': instance.phone,
  'email': instance.email,
  'subtotal': instance.subtotal,
  'tax': instance.tax,
  'total': instance.total,
  'date': instance.date?.toIso8601String(),
  'paymentMethod': instance.paymentMethod,
  'receiptNumber': instance.receiptNumber,
  'confidence': instance.confidence,
  'createdAt': instance.createdAt.toIso8601String(),
  'processed': instance.processed,
  'items': instance.items,
};
