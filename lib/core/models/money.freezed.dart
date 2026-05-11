// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'money.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Money {

 int get amount;// Cents/Smallest unit
 String get currency;
/// Create a copy of Money
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MoneyCopyWith<Money> get copyWith => _$MoneyCopyWithImpl<Money>(this as Money, _$identity);

  /// Serializes this Money to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Money&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,amount,currency);



}

/// @nodoc
abstract mixin class $MoneyCopyWith<$Res>  {
  factory $MoneyCopyWith(Money value, $Res Function(Money) _then) = _$MoneyCopyWithImpl;
@useResult
$Res call({
 int amount, String currency
});




}
/// @nodoc
class _$MoneyCopyWithImpl<$Res>
    implements $MoneyCopyWith<$Res> {
  _$MoneyCopyWithImpl(this._self, this._then);

  final Money _self;
  final $Res Function(Money) _then;

/// Create a copy of Money
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? amount = null,Object? currency = null,}) {
  return _then(_self.copyWith(
amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Money].
extension MoneyPatterns on Money {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Money value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Money() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Money value)  $default,){
final _that = this;
switch (_that) {
case _Money():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Money value)?  $default,){
final _that = this;
switch (_that) {
case _Money() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int amount,  String currency)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Money() when $default != null:
return $default(_that.amount,_that.currency);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int amount,  String currency)  $default,) {final _that = this;
switch (_that) {
case _Money():
return $default(_that.amount,_that.currency);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int amount,  String currency)?  $default,) {final _that = this;
switch (_that) {
case _Money() when $default != null:
return $default(_that.amount,_that.currency);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Money extends Money {
  const _Money({required this.amount, required this.currency}): super._();
  factory _Money.fromJson(Map<String, dynamic> json) => _$MoneyFromJson(json);

@override final  int amount;
// Cents/Smallest unit
@override final  String currency;

/// Create a copy of Money
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MoneyCopyWith<_Money> get copyWith => __$MoneyCopyWithImpl<_Money>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MoneyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Money&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,amount,currency);



}

/// @nodoc
abstract mixin class _$MoneyCopyWith<$Res> implements $MoneyCopyWith<$Res> {
  factory _$MoneyCopyWith(_Money value, $Res Function(_Money) _then) = __$MoneyCopyWithImpl;
@override @useResult
$Res call({
 int amount, String currency
});




}
/// @nodoc
class __$MoneyCopyWithImpl<$Res>
    implements _$MoneyCopyWith<$Res> {
  __$MoneyCopyWithImpl(this._self, this._then);

  final _Money _self;
  final $Res Function(_Money) _then;

/// Create a copy of Money
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? amount = null,Object? currency = null,}) {
  return _then(_Money(
amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$NormalizedMoney {

 Money get original; int get baseAmount;// Amount in User's Base Currency
 String get baseCurrency; double get exchangeRate; String get rateSource;
/// Create a copy of NormalizedMoney
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NormalizedMoneyCopyWith<NormalizedMoney> get copyWith => _$NormalizedMoneyCopyWithImpl<NormalizedMoney>(this as NormalizedMoney, _$identity);

  /// Serializes this NormalizedMoney to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NormalizedMoney&&(identical(other.original, original) || other.original == original)&&(identical(other.baseAmount, baseAmount) || other.baseAmount == baseAmount)&&(identical(other.baseCurrency, baseCurrency) || other.baseCurrency == baseCurrency)&&(identical(other.exchangeRate, exchangeRate) || other.exchangeRate == exchangeRate)&&(identical(other.rateSource, rateSource) || other.rateSource == rateSource));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,original,baseAmount,baseCurrency,exchangeRate,rateSource);

@override
String toString() {
  return 'NormalizedMoney(original: $original, baseAmount: $baseAmount, baseCurrency: $baseCurrency, exchangeRate: $exchangeRate, rateSource: $rateSource)';
}


}

/// @nodoc
abstract mixin class $NormalizedMoneyCopyWith<$Res>  {
  factory $NormalizedMoneyCopyWith(NormalizedMoney value, $Res Function(NormalizedMoney) _then) = _$NormalizedMoneyCopyWithImpl;
@useResult
$Res call({
 Money original, int baseAmount, String baseCurrency, double exchangeRate, String rateSource
});


$MoneyCopyWith<$Res> get original;

}
/// @nodoc
class _$NormalizedMoneyCopyWithImpl<$Res>
    implements $NormalizedMoneyCopyWith<$Res> {
  _$NormalizedMoneyCopyWithImpl(this._self, this._then);

  final NormalizedMoney _self;
  final $Res Function(NormalizedMoney) _then;

/// Create a copy of NormalizedMoney
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? original = null,Object? baseAmount = null,Object? baseCurrency = null,Object? exchangeRate = null,Object? rateSource = null,}) {
  return _then(_self.copyWith(
original: null == original ? _self.original : original // ignore: cast_nullable_to_non_nullable
as Money,baseAmount: null == baseAmount ? _self.baseAmount : baseAmount // ignore: cast_nullable_to_non_nullable
as int,baseCurrency: null == baseCurrency ? _self.baseCurrency : baseCurrency // ignore: cast_nullable_to_non_nullable
as String,exchangeRate: null == exchangeRate ? _self.exchangeRate : exchangeRate // ignore: cast_nullable_to_non_nullable
as double,rateSource: null == rateSource ? _self.rateSource : rateSource // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of NormalizedMoney
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MoneyCopyWith<$Res> get original {
  
  return $MoneyCopyWith<$Res>(_self.original, (value) {
    return _then(_self.copyWith(original: value));
  });
}
}


/// Adds pattern-matching-related methods to [NormalizedMoney].
extension NormalizedMoneyPatterns on NormalizedMoney {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NormalizedMoney value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NormalizedMoney() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NormalizedMoney value)  $default,){
final _that = this;
switch (_that) {
case _NormalizedMoney():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NormalizedMoney value)?  $default,){
final _that = this;
switch (_that) {
case _NormalizedMoney() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Money original,  int baseAmount,  String baseCurrency,  double exchangeRate,  String rateSource)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NormalizedMoney() when $default != null:
return $default(_that.original,_that.baseAmount,_that.baseCurrency,_that.exchangeRate,_that.rateSource);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Money original,  int baseAmount,  String baseCurrency,  double exchangeRate,  String rateSource)  $default,) {final _that = this;
switch (_that) {
case _NormalizedMoney():
return $default(_that.original,_that.baseAmount,_that.baseCurrency,_that.exchangeRate,_that.rateSource);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Money original,  int baseAmount,  String baseCurrency,  double exchangeRate,  String rateSource)?  $default,) {final _that = this;
switch (_that) {
case _NormalizedMoney() when $default != null:
return $default(_that.original,_that.baseAmount,_that.baseCurrency,_that.exchangeRate,_that.rateSource);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NormalizedMoney extends NormalizedMoney {
  const _NormalizedMoney({required this.original, required this.baseAmount, required this.baseCurrency, required this.exchangeRate, this.rateSource = 'manual'}): super._();
  factory _NormalizedMoney.fromJson(Map<String, dynamic> json) => _$NormalizedMoneyFromJson(json);

@override final  Money original;
@override final  int baseAmount;
// Amount in User's Base Currency
@override final  String baseCurrency;
@override final  double exchangeRate;
@override@JsonKey() final  String rateSource;

/// Create a copy of NormalizedMoney
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NormalizedMoneyCopyWith<_NormalizedMoney> get copyWith => __$NormalizedMoneyCopyWithImpl<_NormalizedMoney>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NormalizedMoneyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NormalizedMoney&&(identical(other.original, original) || other.original == original)&&(identical(other.baseAmount, baseAmount) || other.baseAmount == baseAmount)&&(identical(other.baseCurrency, baseCurrency) || other.baseCurrency == baseCurrency)&&(identical(other.exchangeRate, exchangeRate) || other.exchangeRate == exchangeRate)&&(identical(other.rateSource, rateSource) || other.rateSource == rateSource));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,original,baseAmount,baseCurrency,exchangeRate,rateSource);

@override
String toString() {
  return 'NormalizedMoney(original: $original, baseAmount: $baseAmount, baseCurrency: $baseCurrency, exchangeRate: $exchangeRate, rateSource: $rateSource)';
}


}

/// @nodoc
abstract mixin class _$NormalizedMoneyCopyWith<$Res> implements $NormalizedMoneyCopyWith<$Res> {
  factory _$NormalizedMoneyCopyWith(_NormalizedMoney value, $Res Function(_NormalizedMoney) _then) = __$NormalizedMoneyCopyWithImpl;
@override @useResult
$Res call({
 Money original, int baseAmount, String baseCurrency, double exchangeRate, String rateSource
});


@override $MoneyCopyWith<$Res> get original;

}
/// @nodoc
class __$NormalizedMoneyCopyWithImpl<$Res>
    implements _$NormalizedMoneyCopyWith<$Res> {
  __$NormalizedMoneyCopyWithImpl(this._self, this._then);

  final _NormalizedMoney _self;
  final $Res Function(_NormalizedMoney) _then;

/// Create a copy of NormalizedMoney
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? original = null,Object? baseAmount = null,Object? baseCurrency = null,Object? exchangeRate = null,Object? rateSource = null,}) {
  return _then(_NormalizedMoney(
original: null == original ? _self.original : original // ignore: cast_nullable_to_non_nullable
as Money,baseAmount: null == baseAmount ? _self.baseAmount : baseAmount // ignore: cast_nullable_to_non_nullable
as int,baseCurrency: null == baseCurrency ? _self.baseCurrency : baseCurrency // ignore: cast_nullable_to_non_nullable
as String,exchangeRate: null == exchangeRate ? _self.exchangeRate : exchangeRate // ignore: cast_nullable_to_non_nullable
as double,rateSource: null == rateSource ? _self.rateSource : rateSource // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of NormalizedMoney
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MoneyCopyWith<$Res> get original {
  
  return $MoneyCopyWith<$Res>(_self.original, (value) {
    return _then(_self.copyWith(original: value));
  });
}
}

// dart format on
