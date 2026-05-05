import 'package:freezed_annotation/freezed_annotation.dart';

part 'receipt.freezed.dart';
part 'receipt.g.dart';

@freezed
abstract class Receipt with _$Receipt {
  const Receipt._();

  const factory Receipt({
    required String id,
    required String userId,
    required String imageUrl,
    required String extractedText,
    required List<String> rawLines,
    String? merchant,
    int? total,
    DateTime? date,
    required double confidence,
    required DateTime createdAt,
    @Default(false) bool processed,
  }) = _Receipt;

  factory Receipt.fromJson(Map<String, dynamic> json) => _$ReceiptFromJson(json);
}
