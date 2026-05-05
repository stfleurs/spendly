// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'receipt.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Receipt {

 String get id; String get userId; String get imageUrl; String get extractedText; List<String> get rawLines; String? get merchant; int? get total; DateTime? get date; double get confidence; DateTime get createdAt; bool get processed;
/// Create a copy of Receipt
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReceiptCopyWith<Receipt> get copyWith => _$ReceiptCopyWithImpl<Receipt>(this as Receipt, _$identity);

  /// Serializes this Receipt to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Receipt&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.extractedText, extractedText) || other.extractedText == extractedText)&&const DeepCollectionEquality().equals(other.rawLines, rawLines)&&(identical(other.merchant, merchant) || other.merchant == merchant)&&(identical(other.total, total) || other.total == total)&&(identical(other.date, date) || other.date == date)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.processed, processed) || other.processed == processed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,imageUrl,extractedText,const DeepCollectionEquality().hash(rawLines),merchant,total,date,confidence,createdAt,processed);

@override
String toString() {
  return 'Receipt(id: $id, userId: $userId, imageUrl: $imageUrl, extractedText: $extractedText, rawLines: $rawLines, merchant: $merchant, total: $total, date: $date, confidence: $confidence, createdAt: $createdAt, processed: $processed)';
}


}

/// @nodoc
abstract mixin class $ReceiptCopyWith<$Res>  {
  factory $ReceiptCopyWith(Receipt value, $Res Function(Receipt) _then) = _$ReceiptCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String imageUrl, String extractedText, List<String> rawLines, String? merchant, int? total, DateTime? date, double confidence, DateTime createdAt, bool processed
});




}
/// @nodoc
class _$ReceiptCopyWithImpl<$Res>
    implements $ReceiptCopyWith<$Res> {
  _$ReceiptCopyWithImpl(this._self, this._then);

  final Receipt _self;
  final $Res Function(Receipt) _then;

/// Create a copy of Receipt
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? imageUrl = null,Object? extractedText = null,Object? rawLines = null,Object? merchant = freezed,Object? total = freezed,Object? date = freezed,Object? confidence = null,Object? createdAt = null,Object? processed = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,extractedText: null == extractedText ? _self.extractedText : extractedText // ignore: cast_nullable_to_non_nullable
as String,rawLines: null == rawLines ? _self.rawLines : rawLines // ignore: cast_nullable_to_non_nullable
as List<String>,merchant: freezed == merchant ? _self.merchant : merchant // ignore: cast_nullable_to_non_nullable
as String?,total: freezed == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int?,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime?,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,processed: null == processed ? _self.processed : processed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Receipt].
extension ReceiptPatterns on Receipt {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Receipt value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Receipt() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Receipt value)  $default,){
final _that = this;
switch (_that) {
case _Receipt():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Receipt value)?  $default,){
final _that = this;
switch (_that) {
case _Receipt() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String imageUrl,  String extractedText,  List<String> rawLines,  String? merchant,  int? total,  DateTime? date,  double confidence,  DateTime createdAt,  bool processed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Receipt() when $default != null:
return $default(_that.id,_that.userId,_that.imageUrl,_that.extractedText,_that.rawLines,_that.merchant,_that.total,_that.date,_that.confidence,_that.createdAt,_that.processed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String imageUrl,  String extractedText,  List<String> rawLines,  String? merchant,  int? total,  DateTime? date,  double confidence,  DateTime createdAt,  bool processed)  $default,) {final _that = this;
switch (_that) {
case _Receipt():
return $default(_that.id,_that.userId,_that.imageUrl,_that.extractedText,_that.rawLines,_that.merchant,_that.total,_that.date,_that.confidence,_that.createdAt,_that.processed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String imageUrl,  String extractedText,  List<String> rawLines,  String? merchant,  int? total,  DateTime? date,  double confidence,  DateTime createdAt,  bool processed)?  $default,) {final _that = this;
switch (_that) {
case _Receipt() when $default != null:
return $default(_that.id,_that.userId,_that.imageUrl,_that.extractedText,_that.rawLines,_that.merchant,_that.total,_that.date,_that.confidence,_that.createdAt,_that.processed);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Receipt extends Receipt {
  const _Receipt({required this.id, required this.userId, required this.imageUrl, required this.extractedText, required final  List<String> rawLines, this.merchant, this.total, this.date, required this.confidence, required this.createdAt, this.processed = false}): _rawLines = rawLines,super._();
  factory _Receipt.fromJson(Map<String, dynamic> json) => _$ReceiptFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String imageUrl;
@override final  String extractedText;
 final  List<String> _rawLines;
@override List<String> get rawLines {
  if (_rawLines is EqualUnmodifiableListView) return _rawLines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rawLines);
}

@override final  String? merchant;
@override final  int? total;
@override final  DateTime? date;
@override final  double confidence;
@override final  DateTime createdAt;
@override@JsonKey() final  bool processed;

/// Create a copy of Receipt
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReceiptCopyWith<_Receipt> get copyWith => __$ReceiptCopyWithImpl<_Receipt>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReceiptToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Receipt&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.extractedText, extractedText) || other.extractedText == extractedText)&&const DeepCollectionEquality().equals(other._rawLines, _rawLines)&&(identical(other.merchant, merchant) || other.merchant == merchant)&&(identical(other.total, total) || other.total == total)&&(identical(other.date, date) || other.date == date)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.processed, processed) || other.processed == processed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,imageUrl,extractedText,const DeepCollectionEquality().hash(_rawLines),merchant,total,date,confidence,createdAt,processed);

@override
String toString() {
  return 'Receipt(id: $id, userId: $userId, imageUrl: $imageUrl, extractedText: $extractedText, rawLines: $rawLines, merchant: $merchant, total: $total, date: $date, confidence: $confidence, createdAt: $createdAt, processed: $processed)';
}


}

/// @nodoc
abstract mixin class _$ReceiptCopyWith<$Res> implements $ReceiptCopyWith<$Res> {
  factory _$ReceiptCopyWith(_Receipt value, $Res Function(_Receipt) _then) = __$ReceiptCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String imageUrl, String extractedText, List<String> rawLines, String? merchant, int? total, DateTime? date, double confidence, DateTime createdAt, bool processed
});




}
/// @nodoc
class __$ReceiptCopyWithImpl<$Res>
    implements _$ReceiptCopyWith<$Res> {
  __$ReceiptCopyWithImpl(this._self, this._then);

  final _Receipt _self;
  final $Res Function(_Receipt) _then;

/// Create a copy of Receipt
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? imageUrl = null,Object? extractedText = null,Object? rawLines = null,Object? merchant = freezed,Object? total = freezed,Object? date = freezed,Object? confidence = null,Object? createdAt = null,Object? processed = null,}) {
  return _then(_Receipt(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,extractedText: null == extractedText ? _self.extractedText : extractedText // ignore: cast_nullable_to_non_nullable
as String,rawLines: null == rawLines ? _self._rawLines : rawLines // ignore: cast_nullable_to_non_nullable
as List<String>,merchant: freezed == merchant ? _self.merchant : merchant // ignore: cast_nullable_to_non_nullable
as String?,total: freezed == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int?,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime?,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,processed: null == processed ? _self.processed : processed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
