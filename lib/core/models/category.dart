import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.freezed.dart';
part 'category.g.dart';

@freezed
abstract class Category with _$Category {
  const factory Category({
    required String id,
    required String userId,
    required String name,
    required String group,
    int? monthlyTarget,
    @Default(0) int availableBalance, // Envelope balance
    @Default('USD') String currency,
    @Default('Monthly') String recurrence,
  }) = _Category;

  const Category._();
  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);
}
