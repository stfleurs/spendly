// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'monthly_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MonthlySummary {

 String get id;// format: yyyy_mm
 String get userId; int get income;// Normalized in Base Currency
 int get expenses;// Normalized in Base Currency
 int get netChange;// Normalized in Base Currency
 Map<String, int> get categoryTotals;// Normalized in Base Currency
 Map<String, int> get accountTotals;// Normalized in Base Currency
 Map<String, Map<String, int>> get currencyBreakdown;// Namespaced RAW amounts (Rule #5)
 int get transactionCount;@TimestampConverter() DateTime get lastUpdatedAt;
/// Create a copy of MonthlySummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MonthlySummaryCopyWith<MonthlySummary> get copyWith => _$MonthlySummaryCopyWithImpl<MonthlySummary>(this as MonthlySummary, _$identity);

  /// Serializes this MonthlySummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MonthlySummary&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.income, income) || other.income == income)&&(identical(other.expenses, expenses) || other.expenses == expenses)&&(identical(other.netChange, netChange) || other.netChange == netChange)&&const DeepCollectionEquality().equals(other.categoryTotals, categoryTotals)&&const DeepCollectionEquality().equals(other.accountTotals, accountTotals)&&const DeepCollectionEquality().equals(other.currencyBreakdown, currencyBreakdown)&&(identical(other.transactionCount, transactionCount) || other.transactionCount == transactionCount)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,income,expenses,netChange,const DeepCollectionEquality().hash(categoryTotals),const DeepCollectionEquality().hash(accountTotals),const DeepCollectionEquality().hash(currencyBreakdown),transactionCount,lastUpdatedAt);

@override
String toString() {
  return 'MonthlySummary(id: $id, userId: $userId, income: $income, expenses: $expenses, netChange: $netChange, categoryTotals: $categoryTotals, accountTotals: $accountTotals, currencyBreakdown: $currencyBreakdown, transactionCount: $transactionCount, lastUpdatedAt: $lastUpdatedAt)';
}


}

/// @nodoc
abstract mixin class $MonthlySummaryCopyWith<$Res>  {
  factory $MonthlySummaryCopyWith(MonthlySummary value, $Res Function(MonthlySummary) _then) = _$MonthlySummaryCopyWithImpl;
@useResult
$Res call({
 String id, String userId, int income, int expenses, int netChange, Map<String, int> categoryTotals, Map<String, int> accountTotals, Map<String, Map<String, int>> currencyBreakdown, int transactionCount,@TimestampConverter() DateTime lastUpdatedAt
});




}
/// @nodoc
class _$MonthlySummaryCopyWithImpl<$Res>
    implements $MonthlySummaryCopyWith<$Res> {
  _$MonthlySummaryCopyWithImpl(this._self, this._then);

  final MonthlySummary _self;
  final $Res Function(MonthlySummary) _then;

/// Create a copy of MonthlySummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? income = null,Object? expenses = null,Object? netChange = null,Object? categoryTotals = null,Object? accountTotals = null,Object? currencyBreakdown = null,Object? transactionCount = null,Object? lastUpdatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,income: null == income ? _self.income : income // ignore: cast_nullable_to_non_nullable
as int,expenses: null == expenses ? _self.expenses : expenses // ignore: cast_nullable_to_non_nullable
as int,netChange: null == netChange ? _self.netChange : netChange // ignore: cast_nullable_to_non_nullable
as int,categoryTotals: null == categoryTotals ? _self.categoryTotals : categoryTotals // ignore: cast_nullable_to_non_nullable
as Map<String, int>,accountTotals: null == accountTotals ? _self.accountTotals : accountTotals // ignore: cast_nullable_to_non_nullable
as Map<String, int>,currencyBreakdown: null == currencyBreakdown ? _self.currencyBreakdown : currencyBreakdown // ignore: cast_nullable_to_non_nullable
as Map<String, Map<String, int>>,transactionCount: null == transactionCount ? _self.transactionCount : transactionCount // ignore: cast_nullable_to_non_nullable
as int,lastUpdatedAt: null == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [MonthlySummary].
extension MonthlySummaryPatterns on MonthlySummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MonthlySummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MonthlySummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MonthlySummary value)  $default,){
final _that = this;
switch (_that) {
case _MonthlySummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MonthlySummary value)?  $default,){
final _that = this;
switch (_that) {
case _MonthlySummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  int income,  int expenses,  int netChange,  Map<String, int> categoryTotals,  Map<String, int> accountTotals,  Map<String, Map<String, int>> currencyBreakdown,  int transactionCount, @TimestampConverter()  DateTime lastUpdatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MonthlySummary() when $default != null:
return $default(_that.id,_that.userId,_that.income,_that.expenses,_that.netChange,_that.categoryTotals,_that.accountTotals,_that.currencyBreakdown,_that.transactionCount,_that.lastUpdatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  int income,  int expenses,  int netChange,  Map<String, int> categoryTotals,  Map<String, int> accountTotals,  Map<String, Map<String, int>> currencyBreakdown,  int transactionCount, @TimestampConverter()  DateTime lastUpdatedAt)  $default,) {final _that = this;
switch (_that) {
case _MonthlySummary():
return $default(_that.id,_that.userId,_that.income,_that.expenses,_that.netChange,_that.categoryTotals,_that.accountTotals,_that.currencyBreakdown,_that.transactionCount,_that.lastUpdatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  int income,  int expenses,  int netChange,  Map<String, int> categoryTotals,  Map<String, int> accountTotals,  Map<String, Map<String, int>> currencyBreakdown,  int transactionCount, @TimestampConverter()  DateTime lastUpdatedAt)?  $default,) {final _that = this;
switch (_that) {
case _MonthlySummary() when $default != null:
return $default(_that.id,_that.userId,_that.income,_that.expenses,_that.netChange,_that.categoryTotals,_that.accountTotals,_that.currencyBreakdown,_that.transactionCount,_that.lastUpdatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MonthlySummary extends MonthlySummary {
  const _MonthlySummary({required this.id, required this.userId, this.income = 0, this.expenses = 0, this.netChange = 0, final  Map<String, int> categoryTotals = const {}, final  Map<String, int> accountTotals = const {}, final  Map<String, Map<String, int>> currencyBreakdown = const {}, this.transactionCount = 0, @TimestampConverter() required this.lastUpdatedAt}): _categoryTotals = categoryTotals,_accountTotals = accountTotals,_currencyBreakdown = currencyBreakdown,super._();
  factory _MonthlySummary.fromJson(Map<String, dynamic> json) => _$MonthlySummaryFromJson(json);

@override final  String id;
// format: yyyy_mm
@override final  String userId;
@override@JsonKey() final  int income;
// Normalized in Base Currency
@override@JsonKey() final  int expenses;
// Normalized in Base Currency
@override@JsonKey() final  int netChange;
// Normalized in Base Currency
 final  Map<String, int> _categoryTotals;
// Normalized in Base Currency
@override@JsonKey() Map<String, int> get categoryTotals {
  if (_categoryTotals is EqualUnmodifiableMapView) return _categoryTotals;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_categoryTotals);
}

// Normalized in Base Currency
 final  Map<String, int> _accountTotals;
// Normalized in Base Currency
@override@JsonKey() Map<String, int> get accountTotals {
  if (_accountTotals is EqualUnmodifiableMapView) return _accountTotals;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_accountTotals);
}

// Normalized in Base Currency
 final  Map<String, Map<String, int>> _currencyBreakdown;
// Normalized in Base Currency
@override@JsonKey() Map<String, Map<String, int>> get currencyBreakdown {
  if (_currencyBreakdown is EqualUnmodifiableMapView) return _currencyBreakdown;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_currencyBreakdown);
}

// Namespaced RAW amounts (Rule #5)
@override@JsonKey() final  int transactionCount;
@override@TimestampConverter() final  DateTime lastUpdatedAt;

/// Create a copy of MonthlySummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MonthlySummaryCopyWith<_MonthlySummary> get copyWith => __$MonthlySummaryCopyWithImpl<_MonthlySummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MonthlySummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MonthlySummary&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.income, income) || other.income == income)&&(identical(other.expenses, expenses) || other.expenses == expenses)&&(identical(other.netChange, netChange) || other.netChange == netChange)&&const DeepCollectionEquality().equals(other._categoryTotals, _categoryTotals)&&const DeepCollectionEquality().equals(other._accountTotals, _accountTotals)&&const DeepCollectionEquality().equals(other._currencyBreakdown, _currencyBreakdown)&&(identical(other.transactionCount, transactionCount) || other.transactionCount == transactionCount)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,income,expenses,netChange,const DeepCollectionEquality().hash(_categoryTotals),const DeepCollectionEquality().hash(_accountTotals),const DeepCollectionEquality().hash(_currencyBreakdown),transactionCount,lastUpdatedAt);

@override
String toString() {
  return 'MonthlySummary(id: $id, userId: $userId, income: $income, expenses: $expenses, netChange: $netChange, categoryTotals: $categoryTotals, accountTotals: $accountTotals, currencyBreakdown: $currencyBreakdown, transactionCount: $transactionCount, lastUpdatedAt: $lastUpdatedAt)';
}


}

/// @nodoc
abstract mixin class _$MonthlySummaryCopyWith<$Res> implements $MonthlySummaryCopyWith<$Res> {
  factory _$MonthlySummaryCopyWith(_MonthlySummary value, $Res Function(_MonthlySummary) _then) = __$MonthlySummaryCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, int income, int expenses, int netChange, Map<String, int> categoryTotals, Map<String, int> accountTotals, Map<String, Map<String, int>> currencyBreakdown, int transactionCount,@TimestampConverter() DateTime lastUpdatedAt
});




}
/// @nodoc
class __$MonthlySummaryCopyWithImpl<$Res>
    implements _$MonthlySummaryCopyWith<$Res> {
  __$MonthlySummaryCopyWithImpl(this._self, this._then);

  final _MonthlySummary _self;
  final $Res Function(_MonthlySummary) _then;

/// Create a copy of MonthlySummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? income = null,Object? expenses = null,Object? netChange = null,Object? categoryTotals = null,Object? accountTotals = null,Object? currencyBreakdown = null,Object? transactionCount = null,Object? lastUpdatedAt = null,}) {
  return _then(_MonthlySummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,income: null == income ? _self.income : income // ignore: cast_nullable_to_non_nullable
as int,expenses: null == expenses ? _self.expenses : expenses // ignore: cast_nullable_to_non_nullable
as int,netChange: null == netChange ? _self.netChange : netChange // ignore: cast_nullable_to_non_nullable
as int,categoryTotals: null == categoryTotals ? _self._categoryTotals : categoryTotals // ignore: cast_nullable_to_non_nullable
as Map<String, int>,accountTotals: null == accountTotals ? _self._accountTotals : accountTotals // ignore: cast_nullable_to_non_nullable
as Map<String, int>,currencyBreakdown: null == currencyBreakdown ? _self._currencyBreakdown : currencyBreakdown // ignore: cast_nullable_to_non_nullable
as Map<String, Map<String, int>>,transactionCount: null == transactionCount ? _self.transactionCount : transactionCount // ignore: cast_nullable_to_non_nullable
as int,lastUpdatedAt: null == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
