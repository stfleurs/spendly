import 'package:freezed_annotation/freezed_annotation.dart';

part 'money.freezed.dart';
part 'money.g.dart';

@freezed
abstract class Money with _$Money {
  const factory Money({
    required int amount, // Cents/Smallest unit
    required String currency,
  }) = _Money;

  const Money._();
  factory Money.fromJson(Map<String, dynamic> json) => _$MoneyFromJson(json);

  @override
  String toString() => '$currency ${amount / 100}';
}

@freezed
abstract class NormalizedMoney with _$NormalizedMoney {
  const factory NormalizedMoney({
    required Money original,
    required int baseAmount, // Amount in User's Base Currency
    required String baseCurrency,
    required double exchangeRate,
    @Default('manual') String rateSource, // manual | api | bank
  }) = _NormalizedMoney;

  const NormalizedMoney._();
  factory NormalizedMoney.fromJson(Map<String, dynamic> json) =>
      _$NormalizedMoneyFromJson(json);
}
