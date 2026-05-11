// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bill.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Bill {

 String get id; String get userId; String get title; int get amount;// expected total, in cents
 String get currency; int get paidAmount;// actual paid so far, in cents
 DateTime get dueDate; BillStatus get status; String get categoryId; String? get templateId; String? get receiptId; String? get linkedTransactionId; String? get notes; List<String>? get searchTokens;
/// Create a copy of Bill
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BillCopyWith<Bill> get copyWith => _$BillCopyWithImpl<Bill>(this as Bill, _$identity);

  /// Serializes this Bill to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Bill&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.title, title) || other.title == title)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.paidAmount, paidAmount) || other.paidAmount == paidAmount)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.templateId, templateId) || other.templateId == templateId)&&(identical(other.receiptId, receiptId) || other.receiptId == receiptId)&&(identical(other.linkedTransactionId, linkedTransactionId) || other.linkedTransactionId == linkedTransactionId)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other.searchTokens, searchTokens));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,title,amount,currency,paidAmount,dueDate,status,categoryId,templateId,receiptId,linkedTransactionId,notes,const DeepCollectionEquality().hash(searchTokens));

@override
String toString() {
  return 'Bill(id: $id, userId: $userId, title: $title, amount: $amount, currency: $currency, paidAmount: $paidAmount, dueDate: $dueDate, status: $status, categoryId: $categoryId, templateId: $templateId, receiptId: $receiptId, linkedTransactionId: $linkedTransactionId, notes: $notes, searchTokens: $searchTokens)';
}


}

/// @nodoc
abstract mixin class $BillCopyWith<$Res>  {
  factory $BillCopyWith(Bill value, $Res Function(Bill) _then) = _$BillCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String title, int amount, String currency, int paidAmount, DateTime dueDate, BillStatus status, String categoryId, String? templateId, String? receiptId, String? linkedTransactionId, String? notes, List<String>? searchTokens
});




}
/// @nodoc
class _$BillCopyWithImpl<$Res>
    implements $BillCopyWith<$Res> {
  _$BillCopyWithImpl(this._self, this._then);

  final Bill _self;
  final $Res Function(Bill) _then;

/// Create a copy of Bill
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? title = null,Object? amount = null,Object? currency = null,Object? paidAmount = null,Object? dueDate = null,Object? status = null,Object? categoryId = null,Object? templateId = freezed,Object? receiptId = freezed,Object? linkedTransactionId = freezed,Object? notes = freezed,Object? searchTokens = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,paidAmount: null == paidAmount ? _self.paidAmount : paidAmount // ignore: cast_nullable_to_non_nullable
as int,dueDate: null == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BillStatus,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,templateId: freezed == templateId ? _self.templateId : templateId // ignore: cast_nullable_to_non_nullable
as String?,receiptId: freezed == receiptId ? _self.receiptId : receiptId // ignore: cast_nullable_to_non_nullable
as String?,linkedTransactionId: freezed == linkedTransactionId ? _self.linkedTransactionId : linkedTransactionId // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,searchTokens: freezed == searchTokens ? _self.searchTokens : searchTokens // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [Bill].
extension BillPatterns on Bill {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Bill value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Bill() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Bill value)  $default,){
final _that = this;
switch (_that) {
case _Bill():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Bill value)?  $default,){
final _that = this;
switch (_that) {
case _Bill() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String title,  int amount,  String currency,  int paidAmount,  DateTime dueDate,  BillStatus status,  String categoryId,  String? templateId,  String? receiptId,  String? linkedTransactionId,  String? notes,  List<String>? searchTokens)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Bill() when $default != null:
return $default(_that.id,_that.userId,_that.title,_that.amount,_that.currency,_that.paidAmount,_that.dueDate,_that.status,_that.categoryId,_that.templateId,_that.receiptId,_that.linkedTransactionId,_that.notes,_that.searchTokens);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String title,  int amount,  String currency,  int paidAmount,  DateTime dueDate,  BillStatus status,  String categoryId,  String? templateId,  String? receiptId,  String? linkedTransactionId,  String? notes,  List<String>? searchTokens)  $default,) {final _that = this;
switch (_that) {
case _Bill():
return $default(_that.id,_that.userId,_that.title,_that.amount,_that.currency,_that.paidAmount,_that.dueDate,_that.status,_that.categoryId,_that.templateId,_that.receiptId,_that.linkedTransactionId,_that.notes,_that.searchTokens);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String title,  int amount,  String currency,  int paidAmount,  DateTime dueDate,  BillStatus status,  String categoryId,  String? templateId,  String? receiptId,  String? linkedTransactionId,  String? notes,  List<String>? searchTokens)?  $default,) {final _that = this;
switch (_that) {
case _Bill() when $default != null:
return $default(_that.id,_that.userId,_that.title,_that.amount,_that.currency,_that.paidAmount,_that.dueDate,_that.status,_that.categoryId,_that.templateId,_that.receiptId,_that.linkedTransactionId,_that.notes,_that.searchTokens);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Bill extends Bill {
  const _Bill({required this.id, required this.userId, required this.title, required this.amount, this.currency = 'USD', this.paidAmount = 0, required this.dueDate, this.status = BillStatus.upcoming, required this.categoryId, this.templateId, this.receiptId, this.linkedTransactionId, this.notes, final  List<String>? searchTokens}): _searchTokens = searchTokens,super._();
  factory _Bill.fromJson(Map<String, dynamic> json) => _$BillFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String title;
@override final  int amount;
// expected total, in cents
@override@JsonKey() final  String currency;
@override@JsonKey() final  int paidAmount;
// actual paid so far, in cents
@override final  DateTime dueDate;
@override@JsonKey() final  BillStatus status;
@override final  String categoryId;
@override final  String? templateId;
@override final  String? receiptId;
@override final  String? linkedTransactionId;
@override final  String? notes;
 final  List<String>? _searchTokens;
@override List<String>? get searchTokens {
  final value = _searchTokens;
  if (value == null) return null;
  if (_searchTokens is EqualUnmodifiableListView) return _searchTokens;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of Bill
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BillCopyWith<_Bill> get copyWith => __$BillCopyWithImpl<_Bill>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BillToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Bill&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.title, title) || other.title == title)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.paidAmount, paidAmount) || other.paidAmount == paidAmount)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.templateId, templateId) || other.templateId == templateId)&&(identical(other.receiptId, receiptId) || other.receiptId == receiptId)&&(identical(other.linkedTransactionId, linkedTransactionId) || other.linkedTransactionId == linkedTransactionId)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other._searchTokens, _searchTokens));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,title,amount,currency,paidAmount,dueDate,status,categoryId,templateId,receiptId,linkedTransactionId,notes,const DeepCollectionEquality().hash(_searchTokens));

@override
String toString() {
  return 'Bill(id: $id, userId: $userId, title: $title, amount: $amount, currency: $currency, paidAmount: $paidAmount, dueDate: $dueDate, status: $status, categoryId: $categoryId, templateId: $templateId, receiptId: $receiptId, linkedTransactionId: $linkedTransactionId, notes: $notes, searchTokens: $searchTokens)';
}


}

/// @nodoc
abstract mixin class _$BillCopyWith<$Res> implements $BillCopyWith<$Res> {
  factory _$BillCopyWith(_Bill value, $Res Function(_Bill) _then) = __$BillCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String title, int amount, String currency, int paidAmount, DateTime dueDate, BillStatus status, String categoryId, String? templateId, String? receiptId, String? linkedTransactionId, String? notes, List<String>? searchTokens
});




}
/// @nodoc
class __$BillCopyWithImpl<$Res>
    implements _$BillCopyWith<$Res> {
  __$BillCopyWithImpl(this._self, this._then);

  final _Bill _self;
  final $Res Function(_Bill) _then;

/// Create a copy of Bill
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? title = null,Object? amount = null,Object? currency = null,Object? paidAmount = null,Object? dueDate = null,Object? status = null,Object? categoryId = null,Object? templateId = freezed,Object? receiptId = freezed,Object? linkedTransactionId = freezed,Object? notes = freezed,Object? searchTokens = freezed,}) {
  return _then(_Bill(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,paidAmount: null == paidAmount ? _self.paidAmount : paidAmount // ignore: cast_nullable_to_non_nullable
as int,dueDate: null == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BillStatus,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,templateId: freezed == templateId ? _self.templateId : templateId // ignore: cast_nullable_to_non_nullable
as String?,receiptId: freezed == receiptId ? _self.receiptId : receiptId // ignore: cast_nullable_to_non_nullable
as String?,linkedTransactionId: freezed == linkedTransactionId ? _self.linkedTransactionId : linkedTransactionId // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,searchTokens: freezed == searchTokens ? _self._searchTokens : searchTokens // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}


}

// dart format on
