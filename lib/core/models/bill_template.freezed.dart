// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bill_template.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BillTemplate {

 String get id; String get userId; String get title; int get defaultAmount;// default installment amount, in cents
 String get currency; String get categoryId; String get frequency;// One-time, Weekly, Monthly, Yearly
// ── Plan / umbrella fields ──────────────────────────────────────────────
 int? get totalAmount;// total obligation (e.g. full year tuition), in cents
 String? get description;// human-readable note, e.g. "2025-26 school year"
 String? get defaultAccountId; String? get notes;
/// Create a copy of BillTemplate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BillTemplateCopyWith<BillTemplate> get copyWith => _$BillTemplateCopyWithImpl<BillTemplate>(this as BillTemplate, _$identity);

  /// Serializes this BillTemplate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BillTemplate&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.title, title) || other.title == title)&&(identical(other.defaultAmount, defaultAmount) || other.defaultAmount == defaultAmount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.description, description) || other.description == description)&&(identical(other.defaultAccountId, defaultAccountId) || other.defaultAccountId == defaultAccountId)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,title,defaultAmount,currency,categoryId,frequency,totalAmount,description,defaultAccountId,notes);

@override
String toString() {
  return 'BillTemplate(id: $id, userId: $userId, title: $title, defaultAmount: $defaultAmount, currency: $currency, categoryId: $categoryId, frequency: $frequency, totalAmount: $totalAmount, description: $description, defaultAccountId: $defaultAccountId, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $BillTemplateCopyWith<$Res>  {
  factory $BillTemplateCopyWith(BillTemplate value, $Res Function(BillTemplate) _then) = _$BillTemplateCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String title, int defaultAmount, String currency, String categoryId, String frequency, int? totalAmount, String? description, String? defaultAccountId, String? notes
});




}
/// @nodoc
class _$BillTemplateCopyWithImpl<$Res>
    implements $BillTemplateCopyWith<$Res> {
  _$BillTemplateCopyWithImpl(this._self, this._then);

  final BillTemplate _self;
  final $Res Function(BillTemplate) _then;

/// Create a copy of BillTemplate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? title = null,Object? defaultAmount = null,Object? currency = null,Object? categoryId = null,Object? frequency = null,Object? totalAmount = freezed,Object? description = freezed,Object? defaultAccountId = freezed,Object? notes = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,defaultAmount: null == defaultAmount ? _self.defaultAmount : defaultAmount // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as String,totalAmount: freezed == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as int?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,defaultAccountId: freezed == defaultAccountId ? _self.defaultAccountId : defaultAccountId // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BillTemplate].
extension BillTemplatePatterns on BillTemplate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BillTemplate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BillTemplate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BillTemplate value)  $default,){
final _that = this;
switch (_that) {
case _BillTemplate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BillTemplate value)?  $default,){
final _that = this;
switch (_that) {
case _BillTemplate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String title,  int defaultAmount,  String currency,  String categoryId,  String frequency,  int? totalAmount,  String? description,  String? defaultAccountId,  String? notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BillTemplate() when $default != null:
return $default(_that.id,_that.userId,_that.title,_that.defaultAmount,_that.currency,_that.categoryId,_that.frequency,_that.totalAmount,_that.description,_that.defaultAccountId,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String title,  int defaultAmount,  String currency,  String categoryId,  String frequency,  int? totalAmount,  String? description,  String? defaultAccountId,  String? notes)  $default,) {final _that = this;
switch (_that) {
case _BillTemplate():
return $default(_that.id,_that.userId,_that.title,_that.defaultAmount,_that.currency,_that.categoryId,_that.frequency,_that.totalAmount,_that.description,_that.defaultAccountId,_that.notes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String title,  int defaultAmount,  String currency,  String categoryId,  String frequency,  int? totalAmount,  String? description,  String? defaultAccountId,  String? notes)?  $default,) {final _that = this;
switch (_that) {
case _BillTemplate() when $default != null:
return $default(_that.id,_that.userId,_that.title,_that.defaultAmount,_that.currency,_that.categoryId,_that.frequency,_that.totalAmount,_that.description,_that.defaultAccountId,_that.notes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BillTemplate extends BillTemplate {
  const _BillTemplate({required this.id, required this.userId, required this.title, required this.defaultAmount, this.currency = 'USD', required this.categoryId, this.frequency = 'Monthly', this.totalAmount, this.description, this.defaultAccountId, this.notes}): super._();
  factory _BillTemplate.fromJson(Map<String, dynamic> json) => _$BillTemplateFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String title;
@override final  int defaultAmount;
// default installment amount, in cents
@override@JsonKey() final  String currency;
@override final  String categoryId;
@override@JsonKey() final  String frequency;
// One-time, Weekly, Monthly, Yearly
// ── Plan / umbrella fields ──────────────────────────────────────────────
@override final  int? totalAmount;
// total obligation (e.g. full year tuition), in cents
@override final  String? description;
// human-readable note, e.g. "2025-26 school year"
@override final  String? defaultAccountId;
@override final  String? notes;

/// Create a copy of BillTemplate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BillTemplateCopyWith<_BillTemplate> get copyWith => __$BillTemplateCopyWithImpl<_BillTemplate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BillTemplateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BillTemplate&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.title, title) || other.title == title)&&(identical(other.defaultAmount, defaultAmount) || other.defaultAmount == defaultAmount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.description, description) || other.description == description)&&(identical(other.defaultAccountId, defaultAccountId) || other.defaultAccountId == defaultAccountId)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,title,defaultAmount,currency,categoryId,frequency,totalAmount,description,defaultAccountId,notes);

@override
String toString() {
  return 'BillTemplate(id: $id, userId: $userId, title: $title, defaultAmount: $defaultAmount, currency: $currency, categoryId: $categoryId, frequency: $frequency, totalAmount: $totalAmount, description: $description, defaultAccountId: $defaultAccountId, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$BillTemplateCopyWith<$Res> implements $BillTemplateCopyWith<$Res> {
  factory _$BillTemplateCopyWith(_BillTemplate value, $Res Function(_BillTemplate) _then) = __$BillTemplateCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String title, int defaultAmount, String currency, String categoryId, String frequency, int? totalAmount, String? description, String? defaultAccountId, String? notes
});




}
/// @nodoc
class __$BillTemplateCopyWithImpl<$Res>
    implements _$BillTemplateCopyWith<$Res> {
  __$BillTemplateCopyWithImpl(this._self, this._then);

  final _BillTemplate _self;
  final $Res Function(_BillTemplate) _then;

/// Create a copy of BillTemplate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? title = null,Object? defaultAmount = null,Object? currency = null,Object? categoryId = null,Object? frequency = null,Object? totalAmount = freezed,Object? description = freezed,Object? defaultAccountId = freezed,Object? notes = freezed,}) {
  return _then(_BillTemplate(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,defaultAmount: null == defaultAmount ? _self.defaultAmount : defaultAmount // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as String,totalAmount: freezed == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as int?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,defaultAccountId: freezed == defaultAccountId ? _self.defaultAccountId : defaultAccountId // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
