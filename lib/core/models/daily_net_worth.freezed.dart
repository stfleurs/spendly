// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_net_worth.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DailyNetWorth {

 String get id;// format: yyyy-mm-dd
 String get userId;@TimestampConverter() DateTime get date; int get netWorth;// Base Currency
 int get ledgerVersion;
/// Create a copy of DailyNetWorth
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DailyNetWorthCopyWith<DailyNetWorth> get copyWith => _$DailyNetWorthCopyWithImpl<DailyNetWorth>(this as DailyNetWorth, _$identity);

  /// Serializes this DailyNetWorth to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DailyNetWorth&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.date, date) || other.date == date)&&(identical(other.netWorth, netWorth) || other.netWorth == netWorth)&&(identical(other.ledgerVersion, ledgerVersion) || other.ledgerVersion == ledgerVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,date,netWorth,ledgerVersion);

@override
String toString() {
  return 'DailyNetWorth(id: $id, userId: $userId, date: $date, netWorth: $netWorth, ledgerVersion: $ledgerVersion)';
}


}

/// @nodoc
abstract mixin class $DailyNetWorthCopyWith<$Res>  {
  factory $DailyNetWorthCopyWith(DailyNetWorth value, $Res Function(DailyNetWorth) _then) = _$DailyNetWorthCopyWithImpl;
@useResult
$Res call({
 String id, String userId,@TimestampConverter() DateTime date, int netWorth, int ledgerVersion
});




}
/// @nodoc
class _$DailyNetWorthCopyWithImpl<$Res>
    implements $DailyNetWorthCopyWith<$Res> {
  _$DailyNetWorthCopyWithImpl(this._self, this._then);

  final DailyNetWorth _self;
  final $Res Function(DailyNetWorth) _then;

/// Create a copy of DailyNetWorth
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? date = null,Object? netWorth = null,Object? ledgerVersion = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,netWorth: null == netWorth ? _self.netWorth : netWorth // ignore: cast_nullable_to_non_nullable
as int,ledgerVersion: null == ledgerVersion ? _self.ledgerVersion : ledgerVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DailyNetWorth].
extension DailyNetWorthPatterns on DailyNetWorth {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DailyNetWorth value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DailyNetWorth() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DailyNetWorth value)  $default,){
final _that = this;
switch (_that) {
case _DailyNetWorth():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DailyNetWorth value)?  $default,){
final _that = this;
switch (_that) {
case _DailyNetWorth() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId, @TimestampConverter()  DateTime date,  int netWorth,  int ledgerVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DailyNetWorth() when $default != null:
return $default(_that.id,_that.userId,_that.date,_that.netWorth,_that.ledgerVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId, @TimestampConverter()  DateTime date,  int netWorth,  int ledgerVersion)  $default,) {final _that = this;
switch (_that) {
case _DailyNetWorth():
return $default(_that.id,_that.userId,_that.date,_that.netWorth,_that.ledgerVersion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId, @TimestampConverter()  DateTime date,  int netWorth,  int ledgerVersion)?  $default,) {final _that = this;
switch (_that) {
case _DailyNetWorth() when $default != null:
return $default(_that.id,_that.userId,_that.date,_that.netWorth,_that.ledgerVersion);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DailyNetWorth extends DailyNetWorth {
  const _DailyNetWorth({required this.id, required this.userId, @TimestampConverter() required this.date, required this.netWorth, this.ledgerVersion = 1}): super._();
  factory _DailyNetWorth.fromJson(Map<String, dynamic> json) => _$DailyNetWorthFromJson(json);

@override final  String id;
// format: yyyy-mm-dd
@override final  String userId;
@override@TimestampConverter() final  DateTime date;
@override final  int netWorth;
// Base Currency
@override@JsonKey() final  int ledgerVersion;

/// Create a copy of DailyNetWorth
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DailyNetWorthCopyWith<_DailyNetWorth> get copyWith => __$DailyNetWorthCopyWithImpl<_DailyNetWorth>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DailyNetWorthToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DailyNetWorth&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.date, date) || other.date == date)&&(identical(other.netWorth, netWorth) || other.netWorth == netWorth)&&(identical(other.ledgerVersion, ledgerVersion) || other.ledgerVersion == ledgerVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,date,netWorth,ledgerVersion);

@override
String toString() {
  return 'DailyNetWorth(id: $id, userId: $userId, date: $date, netWorth: $netWorth, ledgerVersion: $ledgerVersion)';
}


}

/// @nodoc
abstract mixin class _$DailyNetWorthCopyWith<$Res> implements $DailyNetWorthCopyWith<$Res> {
  factory _$DailyNetWorthCopyWith(_DailyNetWorth value, $Res Function(_DailyNetWorth) _then) = __$DailyNetWorthCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId,@TimestampConverter() DateTime date, int netWorth, int ledgerVersion
});




}
/// @nodoc
class __$DailyNetWorthCopyWithImpl<$Res>
    implements _$DailyNetWorthCopyWith<$Res> {
  __$DailyNetWorthCopyWithImpl(this._self, this._then);

  final _DailyNetWorth _self;
  final $Res Function(_DailyNetWorth) _then;

/// Create a copy of DailyNetWorth
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? date = null,Object? netWorth = null,Object? ledgerVersion = null,}) {
  return _then(_DailyNetWorth(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,netWorth: null == netWorth ? _self.netWorth : netWorth // ignore: cast_nullable_to_non_nullable
as int,ledgerVersion: null == ledgerVersion ? _self.ledgerVersion : ledgerVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
