import 'package:freezed_annotation/freezed_annotation.dart';
import 'timestamp_converter.dart';

part 'account.freezed.dart';
part 'account.g.dart';

@freezed
abstract class Account with _$Account {
  const factory Account({
    required String id,
    required String userId,
    required String name,
    required String type,
    required String currency,
    required int balance, // This represents the INITIAL starting balance of the account
    int? currentBalance, // Running total (cents) - handled by Atomic Ledger
    @Default(0) int transactionCount,
    @TimestampNullableConverter() DateTime? lastTransactionAt,
    @Default(1) int ledgerVersion, // Version stamp for audit/reconciliation
    @TimestampNullableConverter() DateTime? lastCalculatedAt, // Last time the snapshot was verified against history
    String? lastLedgerMutationId, // ID of the last transaction that modified this account
    @Default(0) int creditLimit,
    @Default(true) bool snapshotHealthy,
    @TimestampNullableConverter() DateTime? lastReconciledAt,
    String? color,
  }) = _Account;

  const Account._();
  factory Account.fromJson(Map<String, dynamic> json) =>
      _$AccountFromJson(json);
}
