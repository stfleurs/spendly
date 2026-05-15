import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_user.freezed.dart';
part 'app_user.g.dart';

@freezed
abstract class AppUser with _$AppUser {
  const factory AppUser({
    required String id,
    required String name,
    required String baseCurrency,
    @Default(0) int readyToAssign, // Normalized in Base Currency
    required DateTime createdAt,
  }) = _AppUser;

  const AppUser._();
  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);
}
