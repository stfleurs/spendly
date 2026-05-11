// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Account {

 String get id; String get userId; String get name; String get type; String get currency; int get balance;// This represents the INITIAL starting balance of the account
 int? get currentBalance;// Running total (cents) - handled by Atomic Ledger
 int get transactionCount;@TimestampNullableConverter() DateTime? get lastTransactionAt; int get ledgerVersion;// Version stamp for audit/reconciliation
@TimestampNullableConverter() DateTime? get lastCalculatedAt;// Last time the snapshot was verified against history
 String? get lastLedgerMutationId;// ID of the last transaction that modified this account
 int get creditLimit; String? get color;
/// Create a copy of Account
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccountCopyWith<Account> get copyWith => _$AccountCopyWithImpl<Account>(this as Account, _$identity);

  /// Serializes this Account to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Account&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.currentBalance, currentBalance) || other.currentBalance == currentBalance)&&(identical(other.transactionCount, transactionCount) || other.transactionCount == transactionCount)&&(identical(other.lastTransactionAt, lastTransactionAt) || other.lastTransactionAt == lastTransactionAt)&&(identical(other.ledgerVersion, ledgerVersion) || other.ledgerVersion == ledgerVersion)&&(identical(other.lastCalculatedAt, lastCalculatedAt) || other.lastCalculatedAt == lastCalculatedAt)&&(identical(other.lastLedgerMutationId, lastLedgerMutationId) || other.lastLedgerMutationId == lastLedgerMutationId)&&(identical(other.creditLimit, creditLimit) || other.creditLimit == creditLimit)&&(identical(other.color, color) || other.color == color));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,name,type,currency,balance,currentBalance,transactionCount,lastTransactionAt,ledgerVersion,lastCalculatedAt,lastLedgerMutationId,creditLimit,color);

@override
String toString() {
  return 'Account(id: $id, userId: $userId, name: $name, type: $type, currency: $currency, balance: $balance, currentBalance: $currentBalance, transactionCount: $transactionCount, lastTransactionAt: $lastTransactionAt, ledgerVersion: $ledgerVersion, lastCalculatedAt: $lastCalculatedAt, lastLedgerMutationId: $lastLedgerMutationId, creditLimit: $creditLimit, color: $color)';
}


}

/// @nodoc
abstract mixin class $AccountCopyWith<$Res>  {
  factory $AccountCopyWith(Account value, $Res Function(Account) _then) = _$AccountCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String name, String type, String currency, int balance, int? currentBalance, int transactionCount,@TimestampNullableConverter() DateTime? lastTransactionAt, int ledgerVersion,@TimestampNullableConverter() DateTime? lastCalculatedAt, String? lastLedgerMutationId, int creditLimit, String? color
});




}
/// @nodoc
class _$AccountCopyWithImpl<$Res>
    implements $AccountCopyWith<$Res> {
  _$AccountCopyWithImpl(this._self, this._then);

  final Account _self;
  final $Res Function(Account) _then;

/// Create a copy of Account
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? name = null,Object? type = null,Object? currency = null,Object? balance = null,Object? currentBalance = freezed,Object? transactionCount = null,Object? lastTransactionAt = freezed,Object? ledgerVersion = null,Object? lastCalculatedAt = freezed,Object? lastLedgerMutationId = freezed,Object? creditLimit = null,Object? color = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as int,currentBalance: freezed == currentBalance ? _self.currentBalance : currentBalance // ignore: cast_nullable_to_non_nullable
as int?,transactionCount: null == transactionCount ? _self.transactionCount : transactionCount // ignore: cast_nullable_to_non_nullable
as int,lastTransactionAt: freezed == lastTransactionAt ? _self.lastTransactionAt : lastTransactionAt // ignore: cast_nullable_to_non_nullable
as DateTime?,ledgerVersion: null == ledgerVersion ? _self.ledgerVersion : ledgerVersion // ignore: cast_nullable_to_non_nullable
as int,lastCalculatedAt: freezed == lastCalculatedAt ? _self.lastCalculatedAt : lastCalculatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastLedgerMutationId: freezed == lastLedgerMutationId ? _self.lastLedgerMutationId : lastLedgerMutationId // ignore: cast_nullable_to_non_nullable
as String?,creditLimit: null == creditLimit ? _self.creditLimit : creditLimit // ignore: cast_nullable_to_non_nullable
as int,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Account].
extension AccountPatterns on Account {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Account value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Account() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Account value)  $default,){
final _that = this;
switch (_that) {
case _Account():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Account value)?  $default,){
final _that = this;
switch (_that) {
case _Account() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String name,  String type,  String currency,  int balance,  int? currentBalance,  int transactionCount, @TimestampNullableConverter()  DateTime? lastTransactionAt,  int ledgerVersion, @TimestampNullableConverter()  DateTime? lastCalculatedAt,  String? lastLedgerMutationId,  int creditLimit,  String? color)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Account() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.type,_that.currency,_that.balance,_that.currentBalance,_that.transactionCount,_that.lastTransactionAt,_that.ledgerVersion,_that.lastCalculatedAt,_that.lastLedgerMutationId,_that.creditLimit,_that.color);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String name,  String type,  String currency,  int balance,  int? currentBalance,  int transactionCount, @TimestampNullableConverter()  DateTime? lastTransactionAt,  int ledgerVersion, @TimestampNullableConverter()  DateTime? lastCalculatedAt,  String? lastLedgerMutationId,  int creditLimit,  String? color)  $default,) {final _that = this;
switch (_that) {
case _Account():
return $default(_that.id,_that.userId,_that.name,_that.type,_that.currency,_that.balance,_that.currentBalance,_that.transactionCount,_that.lastTransactionAt,_that.ledgerVersion,_that.lastCalculatedAt,_that.lastLedgerMutationId,_that.creditLimit,_that.color);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String name,  String type,  String currency,  int balance,  int? currentBalance,  int transactionCount, @TimestampNullableConverter()  DateTime? lastTransactionAt,  int ledgerVersion, @TimestampNullableConverter()  DateTime? lastCalculatedAt,  String? lastLedgerMutationId,  int creditLimit,  String? color)?  $default,) {final _that = this;
switch (_that) {
case _Account() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.type,_that.currency,_that.balance,_that.currentBalance,_that.transactionCount,_that.lastTransactionAt,_that.ledgerVersion,_that.lastCalculatedAt,_that.lastLedgerMutationId,_that.creditLimit,_that.color);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Account extends Account {
  const _Account({required this.id, required this.userId, required this.name, required this.type, required this.currency, required this.balance, this.currentBalance, this.transactionCount = 0, @TimestampNullableConverter() this.lastTransactionAt, this.ledgerVersion = 1, @TimestampNullableConverter() this.lastCalculatedAt, this.lastLedgerMutationId, this.creditLimit = 0, this.color}): super._();
  factory _Account.fromJson(Map<String, dynamic> json) => _$AccountFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String name;
@override final  String type;
@override final  String currency;
@override final  int balance;
// This represents the INITIAL starting balance of the account
@override final  int? currentBalance;
// Running total (cents) - handled by Atomic Ledger
@override@JsonKey() final  int transactionCount;
@override@TimestampNullableConverter() final  DateTime? lastTransactionAt;
@override@JsonKey() final  int ledgerVersion;
// Version stamp for audit/reconciliation
@override@TimestampNullableConverter() final  DateTime? lastCalculatedAt;
// Last time the snapshot was verified against history
@override final  String? lastLedgerMutationId;
// ID of the last transaction that modified this account
@override@JsonKey() final  int creditLimit;
@override final  String? color;

/// Create a copy of Account
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccountCopyWith<_Account> get copyWith => __$AccountCopyWithImpl<_Account>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AccountToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Account&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.currentBalance, currentBalance) || other.currentBalance == currentBalance)&&(identical(other.transactionCount, transactionCount) || other.transactionCount == transactionCount)&&(identical(other.lastTransactionAt, lastTransactionAt) || other.lastTransactionAt == lastTransactionAt)&&(identical(other.ledgerVersion, ledgerVersion) || other.ledgerVersion == ledgerVersion)&&(identical(other.lastCalculatedAt, lastCalculatedAt) || other.lastCalculatedAt == lastCalculatedAt)&&(identical(other.lastLedgerMutationId, lastLedgerMutationId) || other.lastLedgerMutationId == lastLedgerMutationId)&&(identical(other.creditLimit, creditLimit) || other.creditLimit == creditLimit)&&(identical(other.color, color) || other.color == color));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,name,type,currency,balance,currentBalance,transactionCount,lastTransactionAt,ledgerVersion,lastCalculatedAt,lastLedgerMutationId,creditLimit,color);

@override
String toString() {
  return 'Account(id: $id, userId: $userId, name: $name, type: $type, currency: $currency, balance: $balance, currentBalance: $currentBalance, transactionCount: $transactionCount, lastTransactionAt: $lastTransactionAt, ledgerVersion: $ledgerVersion, lastCalculatedAt: $lastCalculatedAt, lastLedgerMutationId: $lastLedgerMutationId, creditLimit: $creditLimit, color: $color)';
}


}

/// @nodoc
abstract mixin class _$AccountCopyWith<$Res> implements $AccountCopyWith<$Res> {
  factory _$AccountCopyWith(_Account value, $Res Function(_Account) _then) = __$AccountCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String name, String type, String currency, int balance, int? currentBalance, int transactionCount,@TimestampNullableConverter() DateTime? lastTransactionAt, int ledgerVersion,@TimestampNullableConverter() DateTime? lastCalculatedAt, String? lastLedgerMutationId, int creditLimit, String? color
});




}
/// @nodoc
class __$AccountCopyWithImpl<$Res>
    implements _$AccountCopyWith<$Res> {
  __$AccountCopyWithImpl(this._self, this._then);

  final _Account _self;
  final $Res Function(_Account) _then;

/// Create a copy of Account
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? name = null,Object? type = null,Object? currency = null,Object? balance = null,Object? currentBalance = freezed,Object? transactionCount = null,Object? lastTransactionAt = freezed,Object? ledgerVersion = null,Object? lastCalculatedAt = freezed,Object? lastLedgerMutationId = freezed,Object? creditLimit = null,Object? color = freezed,}) {
  return _then(_Account(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as int,currentBalance: freezed == currentBalance ? _self.currentBalance : currentBalance // ignore: cast_nullable_to_non_nullable
as int?,transactionCount: null == transactionCount ? _self.transactionCount : transactionCount // ignore: cast_nullable_to_non_nullable
as int,lastTransactionAt: freezed == lastTransactionAt ? _self.lastTransactionAt : lastTransactionAt // ignore: cast_nullable_to_non_nullable
as DateTime?,ledgerVersion: null == ledgerVersion ? _self.ledgerVersion : ledgerVersion // ignore: cast_nullable_to_non_nullable
as int,lastCalculatedAt: freezed == lastCalculatedAt ? _self.lastCalculatedAt : lastCalculatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastLedgerMutationId: freezed == lastLedgerMutationId ? _self.lastLedgerMutationId : lastLedgerMutationId // ignore: cast_nullable_to_non_nullable
as String?,creditLimit: null == creditLimit ? _self.creditLimit : creditLimit // ignore: cast_nullable_to_non_nullable
as int,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
