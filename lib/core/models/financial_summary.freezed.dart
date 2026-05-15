// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'financial_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FinancialSummary {

 String get userId; int get netWorth;// Base Currency
 int get totalAssets;// Base Currency
 int get totalDebt;// Base Currency
 int get cashFlow30d;// Base Currency
 String get baseCurrency;@TimestampConverter() DateTime get updatedAt; int get ledgerVersion; bool get reconciled;
/// Create a copy of FinancialSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FinancialSummaryCopyWith<FinancialSummary> get copyWith => _$FinancialSummaryCopyWithImpl<FinancialSummary>(this as FinancialSummary, _$identity);

  /// Serializes this FinancialSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FinancialSummary&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.netWorth, netWorth) || other.netWorth == netWorth)&&(identical(other.totalAssets, totalAssets) || other.totalAssets == totalAssets)&&(identical(other.totalDebt, totalDebt) || other.totalDebt == totalDebt)&&(identical(other.cashFlow30d, cashFlow30d) || other.cashFlow30d == cashFlow30d)&&(identical(other.baseCurrency, baseCurrency) || other.baseCurrency == baseCurrency)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.ledgerVersion, ledgerVersion) || other.ledgerVersion == ledgerVersion)&&(identical(other.reconciled, reconciled) || other.reconciled == reconciled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,netWorth,totalAssets,totalDebt,cashFlow30d,baseCurrency,updatedAt,ledgerVersion,reconciled);

@override
String toString() {
  return 'FinancialSummary(userId: $userId, netWorth: $netWorth, totalAssets: $totalAssets, totalDebt: $totalDebt, cashFlow30d: $cashFlow30d, baseCurrency: $baseCurrency, updatedAt: $updatedAt, ledgerVersion: $ledgerVersion, reconciled: $reconciled)';
}


}

/// @nodoc
abstract mixin class $FinancialSummaryCopyWith<$Res>  {
  factory $FinancialSummaryCopyWith(FinancialSummary value, $Res Function(FinancialSummary) _then) = _$FinancialSummaryCopyWithImpl;
@useResult
$Res call({
 String userId, int netWorth, int totalAssets, int totalDebt, int cashFlow30d, String baseCurrency,@TimestampConverter() DateTime updatedAt, int ledgerVersion, bool reconciled
});




}
/// @nodoc
class _$FinancialSummaryCopyWithImpl<$Res>
    implements $FinancialSummaryCopyWith<$Res> {
  _$FinancialSummaryCopyWithImpl(this._self, this._then);

  final FinancialSummary _self;
  final $Res Function(FinancialSummary) _then;

/// Create a copy of FinancialSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? netWorth = null,Object? totalAssets = null,Object? totalDebt = null,Object? cashFlow30d = null,Object? baseCurrency = null,Object? updatedAt = null,Object? ledgerVersion = null,Object? reconciled = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,netWorth: null == netWorth ? _self.netWorth : netWorth // ignore: cast_nullable_to_non_nullable
as int,totalAssets: null == totalAssets ? _self.totalAssets : totalAssets // ignore: cast_nullable_to_non_nullable
as int,totalDebt: null == totalDebt ? _self.totalDebt : totalDebt // ignore: cast_nullable_to_non_nullable
as int,cashFlow30d: null == cashFlow30d ? _self.cashFlow30d : cashFlow30d // ignore: cast_nullable_to_non_nullable
as int,baseCurrency: null == baseCurrency ? _self.baseCurrency : baseCurrency // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,ledgerVersion: null == ledgerVersion ? _self.ledgerVersion : ledgerVersion // ignore: cast_nullable_to_non_nullable
as int,reconciled: null == reconciled ? _self.reconciled : reconciled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [FinancialSummary].
extension FinancialSummaryPatterns on FinancialSummary {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FinancialSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FinancialSummary() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FinancialSummary value)  $default,){
final _that = this;
switch (_that) {
case _FinancialSummary():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FinancialSummary value)?  $default,){
final _that = this;
switch (_that) {
case _FinancialSummary() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  int netWorth,  int totalAssets,  int totalDebt,  int cashFlow30d,  String baseCurrency, @TimestampConverter()  DateTime updatedAt,  int ledgerVersion,  bool reconciled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FinancialSummary() when $default != null:
return $default(_that.userId,_that.netWorth,_that.totalAssets,_that.totalDebt,_that.cashFlow30d,_that.baseCurrency,_that.updatedAt,_that.ledgerVersion,_that.reconciled);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  int netWorth,  int totalAssets,  int totalDebt,  int cashFlow30d,  String baseCurrency, @TimestampConverter()  DateTime updatedAt,  int ledgerVersion,  bool reconciled)  $default,) {final _that = this;
switch (_that) {
case _FinancialSummary():
return $default(_that.userId,_that.netWorth,_that.totalAssets,_that.totalDebt,_that.cashFlow30d,_that.baseCurrency,_that.updatedAt,_that.ledgerVersion,_that.reconciled);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  int netWorth,  int totalAssets,  int totalDebt,  int cashFlow30d,  String baseCurrency, @TimestampConverter()  DateTime updatedAt,  int ledgerVersion,  bool reconciled)?  $default,) {final _that = this;
switch (_that) {
case _FinancialSummary() when $default != null:
return $default(_that.userId,_that.netWorth,_that.totalAssets,_that.totalDebt,_that.cashFlow30d,_that.baseCurrency,_that.updatedAt,_that.ledgerVersion,_that.reconciled);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FinancialSummary extends FinancialSummary {
  const _FinancialSummary({required this.userId, this.netWorth = 0, this.totalAssets = 0, this.totalDebt = 0, this.cashFlow30d = 0, required this.baseCurrency, @TimestampConverter() required this.updatedAt, this.ledgerVersion = 1, this.reconciled = false}): super._();
  factory _FinancialSummary.fromJson(Map<String, dynamic> json) => _$FinancialSummaryFromJson(json);

@override final  String userId;
@override@JsonKey() final  int netWorth;
// Base Currency
@override@JsonKey() final  int totalAssets;
// Base Currency
@override@JsonKey() final  int totalDebt;
// Base Currency
@override@JsonKey() final  int cashFlow30d;
// Base Currency
@override final  String baseCurrency;
@override@TimestampConverter() final  DateTime updatedAt;
@override@JsonKey() final  int ledgerVersion;
@override@JsonKey() final  bool reconciled;

/// Create a copy of FinancialSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FinancialSummaryCopyWith<_FinancialSummary> get copyWith => __$FinancialSummaryCopyWithImpl<_FinancialSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FinancialSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FinancialSummary&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.netWorth, netWorth) || other.netWorth == netWorth)&&(identical(other.totalAssets, totalAssets) || other.totalAssets == totalAssets)&&(identical(other.totalDebt, totalDebt) || other.totalDebt == totalDebt)&&(identical(other.cashFlow30d, cashFlow30d) || other.cashFlow30d == cashFlow30d)&&(identical(other.baseCurrency, baseCurrency) || other.baseCurrency == baseCurrency)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.ledgerVersion, ledgerVersion) || other.ledgerVersion == ledgerVersion)&&(identical(other.reconciled, reconciled) || other.reconciled == reconciled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,netWorth,totalAssets,totalDebt,cashFlow30d,baseCurrency,updatedAt,ledgerVersion,reconciled);

@override
String toString() {
  return 'FinancialSummary(userId: $userId, netWorth: $netWorth, totalAssets: $totalAssets, totalDebt: $totalDebt, cashFlow30d: $cashFlow30d, baseCurrency: $baseCurrency, updatedAt: $updatedAt, ledgerVersion: $ledgerVersion, reconciled: $reconciled)';
}


}

/// @nodoc
abstract mixin class _$FinancialSummaryCopyWith<$Res> implements $FinancialSummaryCopyWith<$Res> {
  factory _$FinancialSummaryCopyWith(_FinancialSummary value, $Res Function(_FinancialSummary) _then) = __$FinancialSummaryCopyWithImpl;
@override @useResult
$Res call({
 String userId, int netWorth, int totalAssets, int totalDebt, int cashFlow30d, String baseCurrency,@TimestampConverter() DateTime updatedAt, int ledgerVersion, bool reconciled
});




}
/// @nodoc
class __$FinancialSummaryCopyWithImpl<$Res>
    implements _$FinancialSummaryCopyWith<$Res> {
  __$FinancialSummaryCopyWithImpl(this._self, this._then);

  final _FinancialSummary _self;
  final $Res Function(_FinancialSummary) _then;

/// Create a copy of FinancialSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? netWorth = null,Object? totalAssets = null,Object? totalDebt = null,Object? cashFlow30d = null,Object? baseCurrency = null,Object? updatedAt = null,Object? ledgerVersion = null,Object? reconciled = null,}) {
  return _then(_FinancialSummary(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,netWorth: null == netWorth ? _self.netWorth : netWorth // ignore: cast_nullable_to_non_nullable
as int,totalAssets: null == totalAssets ? _self.totalAssets : totalAssets // ignore: cast_nullable_to_non_nullable
as int,totalDebt: null == totalDebt ? _self.totalDebt : totalDebt // ignore: cast_nullable_to_non_nullable
as int,cashFlow30d: null == cashFlow30d ? _self.cashFlow30d : cashFlow30d // ignore: cast_nullable_to_non_nullable
as int,baseCurrency: null == baseCurrency ? _self.baseCurrency : baseCurrency // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,ledgerVersion: null == ledgerVersion ? _self.ledgerVersion : ledgerVersion // ignore: cast_nullable_to_non_nullable
as int,reconciled: null == reconciled ? _self.reconciled : reconciled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
