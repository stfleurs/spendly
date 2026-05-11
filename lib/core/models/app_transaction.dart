import 'package:freezed_annotation/freezed_annotation.dart';
import 'timestamp_converter.dart';

part 'app_transaction.freezed.dart';
part 'app_transaction.g.dart';

@freezed
abstract class AppTransaction with _$AppTransaction {
  const factory AppTransaction({
    required String id,
    required String userId,
    required String type, // income | expense | transfer
    required int amount,
    required String currency,
    @TimestampConverter() required DateTime date,
    required String accountId,
    required String categoryId,
    String? note,
    String? receiptUrl,
    String? receiptId,

    // Normalized accounting fields (The Immutable Truth)
    @Default(0) int amountInBaseCurrency,
    @Default('USD') String baseCurrency,
    @Default(1.0) double exchangeRate, // User still sees this as decimal
    @Default(1000000) int rateScale, // 1,000,000 for integer math
    @Default(1000000) int scaledRate, // (exchangeRate * rateScale).round()
    @Default('manual') String rateSource,
    
    // FX Metadata
    @Default('USD') String rateBaseCurrency,
    @Default('USD') String rateQuoteCurrency,

    // Original payment data
    int? originalAmount,
    String? originalCurrency,
    
    String? sourceHash,
    List<String>? searchTokens,
  }) = _AppTransaction;

  const AppTransaction._();
  factory AppTransaction.fromJson(Map<String, dynamic> json) =>
      _$AppTransactionFromJson(json);

  static List<String> createSearchTokens(String? note, String? categoryName) {
    final tokens = <String>{};
    if (note != null && note.isNotEmpty) {
      final words = note.toLowerCase().split(RegExp(r'[^a-z0-9]')).where((w) => w.length >= 2);
      tokens.addAll(words);
    }
    if (categoryName != null && categoryName.isNotEmpty) {
      final words = categoryName.toLowerCase().split(RegExp(r'[^a-z0-9]')).where((w) => w.length >= 2);
      tokens.addAll(words);
    }
    return tokens.toList();
  }
}
