// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppUser {

 String get id; String get name; String get baseCurrency; int get readyToAssign;// Normalized in Base Currency
 DateTime get createdAt; Map<String, double> get exchangeRates; String get rateMode; int get ledgerVersion;
/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppUserCopyWith<AppUser> get copyWith => _$AppUserCopyWithImpl<AppUser>(this as AppUser, _$identity);

  /// Serializes this AppUser to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppUser&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.baseCurrency, baseCurrency) || other.baseCurrency == baseCurrency)&&(identical(other.readyToAssign, readyToAssign) || other.readyToAssign == readyToAssign)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other.exchangeRates, exchangeRates)&&(identical(other.rateMode, rateMode) || other.rateMode == rateMode)&&(identical(other.ledgerVersion, ledgerVersion) || other.ledgerVersion == ledgerVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,baseCurrency,readyToAssign,createdAt,const DeepCollectionEquality().hash(exchangeRates),rateMode,ledgerVersion);

@override
String toString() {
  return 'AppUser(id: $id, name: $name, baseCurrency: $baseCurrency, readyToAssign: $readyToAssign, createdAt: $createdAt, exchangeRates: $exchangeRates, rateMode: $rateMode, ledgerVersion: $ledgerVersion)';
}


}

/// @nodoc
abstract mixin class $AppUserCopyWith<$Res>  {
  factory $AppUserCopyWith(AppUser value, $Res Function(AppUser) _then) = _$AppUserCopyWithImpl;
@useResult
$Res call({
 String id, String name, String baseCurrency, int readyToAssign, DateTime createdAt, Map<String, double> exchangeRates, String rateMode, int ledgerVersion
});




}
/// @nodoc
class _$AppUserCopyWithImpl<$Res>
    implements $AppUserCopyWith<$Res> {
  _$AppUserCopyWithImpl(this._self, this._then);

  final AppUser _self;
  final $Res Function(AppUser) _then;

/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? baseCurrency = null,Object? readyToAssign = null,Object? createdAt = null,Object? exchangeRates = null,Object? rateMode = null,Object? ledgerVersion = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,baseCurrency: null == baseCurrency ? _self.baseCurrency : baseCurrency // ignore: cast_nullable_to_non_nullable
as String,readyToAssign: null == readyToAssign ? _self.readyToAssign : readyToAssign // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,exchangeRates: null == exchangeRates ? _self.exchangeRates : exchangeRates // ignore: cast_nullable_to_non_nullable
as Map<String, double>,rateMode: null == rateMode ? _self.rateMode : rateMode // ignore: cast_nullable_to_non_nullable
as String,ledgerVersion: null == ledgerVersion ? _self.ledgerVersion : ledgerVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AppUser].
extension AppUserPatterns on AppUser {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppUser value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppUser() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppUser value)  $default,){
final _that = this;
switch (_that) {
case _AppUser():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppUser value)?  $default,){
final _that = this;
switch (_that) {
case _AppUser() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String baseCurrency,  int readyToAssign,  DateTime createdAt,  Map<String, double> exchangeRates,  String rateMode,  int ledgerVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppUser() when $default != null:
return $default(_that.id,_that.name,_that.baseCurrency,_that.readyToAssign,_that.createdAt,_that.exchangeRates,_that.rateMode,_that.ledgerVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String baseCurrency,  int readyToAssign,  DateTime createdAt,  Map<String, double> exchangeRates,  String rateMode,  int ledgerVersion)  $default,) {final _that = this;
switch (_that) {
case _AppUser():
return $default(_that.id,_that.name,_that.baseCurrency,_that.readyToAssign,_that.createdAt,_that.exchangeRates,_that.rateMode,_that.ledgerVersion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String baseCurrency,  int readyToAssign,  DateTime createdAt,  Map<String, double> exchangeRates,  String rateMode,  int ledgerVersion)?  $default,) {final _that = this;
switch (_that) {
case _AppUser() when $default != null:
return $default(_that.id,_that.name,_that.baseCurrency,_that.readyToAssign,_that.createdAt,_that.exchangeRates,_that.rateMode,_that.ledgerVersion);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppUser extends AppUser {
  const _AppUser({required this.id, required this.name, required this.baseCurrency, this.readyToAssign = 0, required this.createdAt, final  Map<String, double> exchangeRates = const {}, this.rateMode = 'manual', this.ledgerVersion = 1}): _exchangeRates = exchangeRates,super._();
  factory _AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);

@override final  String id;
@override final  String name;
@override final  String baseCurrency;
@override@JsonKey() final  int readyToAssign;
// Normalized in Base Currency
@override final  DateTime createdAt;
 final  Map<String, double> _exchangeRates;
@override@JsonKey() Map<String, double> get exchangeRates {
  if (_exchangeRates is EqualUnmodifiableMapView) return _exchangeRates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_exchangeRates);
}

@override@JsonKey() final  String rateMode;
@override@JsonKey() final  int ledgerVersion;

/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppUserCopyWith<_AppUser> get copyWith => __$AppUserCopyWithImpl<_AppUser>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppUserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppUser&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.baseCurrency, baseCurrency) || other.baseCurrency == baseCurrency)&&(identical(other.readyToAssign, readyToAssign) || other.readyToAssign == readyToAssign)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other._exchangeRates, _exchangeRates)&&(identical(other.rateMode, rateMode) || other.rateMode == rateMode)&&(identical(other.ledgerVersion, ledgerVersion) || other.ledgerVersion == ledgerVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,baseCurrency,readyToAssign,createdAt,const DeepCollectionEquality().hash(_exchangeRates),rateMode,ledgerVersion);

@override
String toString() {
  return 'AppUser(id: $id, name: $name, baseCurrency: $baseCurrency, readyToAssign: $readyToAssign, createdAt: $createdAt, exchangeRates: $exchangeRates, rateMode: $rateMode, ledgerVersion: $ledgerVersion)';
}


}

/// @nodoc
abstract mixin class _$AppUserCopyWith<$Res> implements $AppUserCopyWith<$Res> {
  factory _$AppUserCopyWith(_AppUser value, $Res Function(_AppUser) _then) = __$AppUserCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String baseCurrency, int readyToAssign, DateTime createdAt, Map<String, double> exchangeRates, String rateMode, int ledgerVersion
});




}
/// @nodoc
class __$AppUserCopyWithImpl<$Res>
    implements _$AppUserCopyWith<$Res> {
  __$AppUserCopyWithImpl(this._self, this._then);

  final _AppUser _self;
  final $Res Function(_AppUser) _then;

/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? baseCurrency = null,Object? readyToAssign = null,Object? createdAt = null,Object? exchangeRates = null,Object? rateMode = null,Object? ledgerVersion = null,}) {
  return _then(_AppUser(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,baseCurrency: null == baseCurrency ? _self.baseCurrency : baseCurrency // ignore: cast_nullable_to_non_nullable
as String,readyToAssign: null == readyToAssign ? _self.readyToAssign : readyToAssign // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,exchangeRates: null == exchangeRates ? _self._exchangeRates : exchangeRates // ignore: cast_nullable_to_non_nullable
as Map<String, double>,rateMode: null == rateMode ? _self.rateMode : rateMode // ignore: cast_nullable_to_non_nullable
as String,ledgerVersion: null == ledgerVersion ? _self.ledgerVersion : ledgerVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
