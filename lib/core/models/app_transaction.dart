import 'package:freezed_annotation/freezed_annotation.dart';

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
    required DateTime date,
    required String accountId,
    required String categoryId,
    String? note,
    String? receiptUrl,
  }) = _AppTransaction;

  const AppTransaction._();
  factory AppTransaction.fromJson(Map<String, dynamic> json) =>
      _$AppTransactionFromJson(json);
}
