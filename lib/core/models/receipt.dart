import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'receipt.freezed.dart';
part 'receipt.g.dart';

class RectConverter implements JsonConverter<Rect, Map<String, dynamic>> {
  const RectConverter();

  @override
  Rect fromJson(Map<String, dynamic> json) {
    return Rect.fromLTRB(
      (json['left'] as num).toDouble(),
      (json['top'] as num).toDouble(),
      (json['right'] as num).toDouble(),
      (json['bottom'] as num).toDouble(),
    );
  }

  @override
  Map<String, dynamic> toJson(Rect rect) {
    return {
      'left': rect.left,
      'top': rect.top,
      'right': rect.right,
      'bottom': rect.bottom,
    };
  }
}

@freezed
abstract class OCRLine with _$OCRLine {
  const OCRLine._();

  const factory OCRLine({
    required String text,
    @RectConverter() required Rect bounds,
  }) = _OCRLine;

  double get top => bounds.top;
  double get left => bounds.left;
  double get right => bounds.right;
  double get bottom => bounds.bottom;
  double get centerY => bounds.top + (bounds.height / 2);

  factory OCRLine.fromJson(Map<String, dynamic> json) => _$OCRLineFromJson(json);
}

@freezed
abstract class ReceiptItem with _$ReceiptItem {
  const factory ReceiptItem({
    required String description,
    required int amount, // Cents
    int? quantity,
    int? unitPrice, // Cents
  }) = _ReceiptItem;

  factory ReceiptItem.fromJson(Map<String, dynamic> json) => _$ReceiptItemFromJson(json);
}

@freezed
abstract class Receipt with _$Receipt {
  const Receipt._();

  const factory Receipt({
    required String id,
    required String userId,
    required String imageUrl,
    required String extractedText,
    required List<OCRLine> lines,
    String? merchant,
    String? address,
    String? phone,
    String? email,
    int? subtotal, // Cents
    int? tax,      // Cents
    int? total,    // Cents
    DateTime? date,
    String? paymentMethod,
    String? receiptNumber,
    required double confidence,
    required DateTime createdAt,
    @Default(false) bool processed,
    List<ReceiptItem>? items,
  }) = _Receipt;

  factory Receipt.fromJson(Map<String, dynamic> json) => _$ReceiptFromJson(json);
}
