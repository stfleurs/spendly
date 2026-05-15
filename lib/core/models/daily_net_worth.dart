import 'package:freezed_annotation/freezed_annotation.dart';
import 'timestamp_converter.dart';

part 'daily_net_worth.freezed.dart';
part 'daily_net_worth.g.dart';

@freezed
abstract class DailyNetWorth with _$DailyNetWorth {
  const factory DailyNetWorth({
    required String id, // format: yyyy-mm-dd
    required String userId,
    @TimestampConverter() required DateTime date,
    required int netWorth, // Base Currency
    @Default(1) int ledgerVersion,
  }) = _DailyNetWorth;

  const DailyNetWorth._();
  factory DailyNetWorth.fromJson(Map<String, dynamic> json) =>
      _$DailyNetWorthFromJson(json);
}
