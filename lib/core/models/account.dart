import 'package:freezed_annotation/freezed_annotation.dart';

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
    required int balance,
  }) = _Account;

  const Account._();
  factory Account.fromJson(Map<String, dynamic> json) =>
      _$AccountFromJson(json);
}
