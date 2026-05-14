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
mixin _$OCRLine {

 String get text;@RectConverter() Rect get bounds;
/// Create a copy of OCRLine
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OCRLineCopyWith<OCRLine> get copyWith => _$OCRLineCopyWithImpl<OCRLine>(this as OCRLine, _$identity);

  /// Serializes this OCRLine to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OCRLine&&(identical(other.text, text) || other.text == text)&&(identical(other.bounds, bounds) || other.bounds == bounds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,text,bounds);

@override
String toString() {
  return 'OCRLine(text: $text, bounds: $bounds)';
}


}

/// @nodoc
abstract mixin class $OCRLineCopyWith<$Res>  {
  factory $OCRLineCopyWith(OCRLine value, $Res Function(OCRLine) _then) = _$OCRLineCopyWithImpl;
@useResult
$Res call({
 String text,@RectConverter() Rect bounds
});




}
/// @nodoc
class _$OCRLineCopyWithImpl<$Res>
    implements $OCRLineCopyWith<$Res> {
  _$OCRLineCopyWithImpl(this._self, this._then);

  final OCRLine _self;
  final $Res Function(OCRLine) _then;

/// Create a copy of OCRLine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? text = null,Object? bounds = null,}) {
  return _then(_self.copyWith(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,bounds: null == bounds ? _self.bounds : bounds // ignore: cast_nullable_to_non_nullable
as Rect,
  ));
}

}


/// Adds pattern-matching-related methods to [OCRLine].
extension OCRLinePatterns on OCRLine {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OCRLine value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OCRLine() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OCRLine value)  $default,){
final _that = this;
switch (_that) {
case _OCRLine():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OCRLine value)?  $default,){
final _that = this;
switch (_that) {
case _OCRLine() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String text, @RectConverter()  Rect bounds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OCRLine() when $default != null:
return $default(_that.text,_that.bounds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String text, @RectConverter()  Rect bounds)  $default,) {final _that = this;
switch (_that) {
case _OCRLine():
return $default(_that.text,_that.bounds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String text, @RectConverter()  Rect bounds)?  $default,) {final _that = this;
switch (_that) {
case _OCRLine() when $default != null:
return $default(_that.text,_that.bounds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OCRLine extends OCRLine {
  const _OCRLine({required this.text, @RectConverter() required this.bounds}): super._();
  factory _OCRLine.fromJson(Map<String, dynamic> json) => _$OCRLineFromJson(json);

@override final  String text;
@override@RectConverter() final  Rect bounds;

/// Create a copy of OCRLine
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OCRLineCopyWith<_OCRLine> get copyWith => __$OCRLineCopyWithImpl<_OCRLine>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OCRLineToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OCRLine&&(identical(other.text, text) || other.text == text)&&(identical(other.bounds, bounds) || other.bounds == bounds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,text,bounds);

@override
String toString() {
  return 'OCRLine(text: $text, bounds: $bounds)';
}


}

/// @nodoc
abstract mixin class _$OCRLineCopyWith<$Res> implements $OCRLineCopyWith<$Res> {
  factory _$OCRLineCopyWith(_OCRLine value, $Res Function(_OCRLine) _then) = __$OCRLineCopyWithImpl;
@override @useResult
$Res call({
 String text,@RectConverter() Rect bounds
});




}
/// @nodoc
class __$OCRLineCopyWithImpl<$Res>
    implements _$OCRLineCopyWith<$Res> {
  __$OCRLineCopyWithImpl(this._self, this._then);

  final _OCRLine _self;
  final $Res Function(_OCRLine) _then;

/// Create a copy of OCRLine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = null,Object? bounds = null,}) {
  return _then(_OCRLine(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,bounds: null == bounds ? _self.bounds : bounds // ignore: cast_nullable_to_non_nullable
as Rect,
  ));
}


}


/// @nodoc
mixin _$ReceiptItem {

 String get description; int get amount;// Cents
 int? get quantity; int? get unitPrice;// Cents
 double? get confidence;
/// Create a copy of ReceiptItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReceiptItemCopyWith<ReceiptItem> get copyWith => _$ReceiptItemCopyWithImpl<ReceiptItem>(this as ReceiptItem, _$identity);

  /// Serializes this ReceiptItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReceiptItem&&(identical(other.description, description) || other.description == description)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.confidence, confidence) || other.confidence == confidence));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,description,amount,quantity,unitPrice,confidence);

@override
String toString() {
  return 'ReceiptItem(description: $description, amount: $amount, quantity: $quantity, unitPrice: $unitPrice, confidence: $confidence)';
}


}

/// @nodoc
abstract mixin class $ReceiptItemCopyWith<$Res>  {
  factory $ReceiptItemCopyWith(ReceiptItem value, $Res Function(ReceiptItem) _then) = _$ReceiptItemCopyWithImpl;
@useResult
$Res call({
 String description, int amount, int? quantity, int? unitPrice, double? confidence
});




}
/// @nodoc
class _$ReceiptItemCopyWithImpl<$Res>
    implements $ReceiptItemCopyWith<$Res> {
  _$ReceiptItemCopyWithImpl(this._self, this._then);

  final ReceiptItem _self;
  final $Res Function(ReceiptItem) _then;

/// Create a copy of ReceiptItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? description = null,Object? amount = null,Object? quantity = freezed,Object? unitPrice = freezed,Object? confidence = freezed,}) {
  return _then(_self.copyWith(
description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,quantity: freezed == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int?,unitPrice: freezed == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as int?,confidence: freezed == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [ReceiptItem].
extension ReceiptItemPatterns on ReceiptItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReceiptItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReceiptItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReceiptItem value)  $default,){
final _that = this;
switch (_that) {
case _ReceiptItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReceiptItem value)?  $default,){
final _that = this;
switch (_that) {
case _ReceiptItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String description,  int amount,  int? quantity,  int? unitPrice,  double? confidence)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReceiptItem() when $default != null:
return $default(_that.description,_that.amount,_that.quantity,_that.unitPrice,_that.confidence);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String description,  int amount,  int? quantity,  int? unitPrice,  double? confidence)  $default,) {final _that = this;
switch (_that) {
case _ReceiptItem():
return $default(_that.description,_that.amount,_that.quantity,_that.unitPrice,_that.confidence);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String description,  int amount,  int? quantity,  int? unitPrice,  double? confidence)?  $default,) {final _that = this;
switch (_that) {
case _ReceiptItem() when $default != null:
return $default(_that.description,_that.amount,_that.quantity,_that.unitPrice,_that.confidence);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReceiptItem implements ReceiptItem {
  const _ReceiptItem({required this.description, required this.amount, this.quantity, this.unitPrice, this.confidence});
  factory _ReceiptItem.fromJson(Map<String, dynamic> json) => _$ReceiptItemFromJson(json);

@override final  String description;
@override final  int amount;
// Cents
@override final  int? quantity;
@override final  int? unitPrice;
// Cents
@override final  double? confidence;

/// Create a copy of ReceiptItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReceiptItemCopyWith<_ReceiptItem> get copyWith => __$ReceiptItemCopyWithImpl<_ReceiptItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReceiptItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReceiptItem&&(identical(other.description, description) || other.description == description)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.confidence, confidence) || other.confidence == confidence));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,description,amount,quantity,unitPrice,confidence);

@override
String toString() {
  return 'ReceiptItem(description: $description, amount: $amount, quantity: $quantity, unitPrice: $unitPrice, confidence: $confidence)';
}


}

/// @nodoc
abstract mixin class _$ReceiptItemCopyWith<$Res> implements $ReceiptItemCopyWith<$Res> {
  factory _$ReceiptItemCopyWith(_ReceiptItem value, $Res Function(_ReceiptItem) _then) = __$ReceiptItemCopyWithImpl;
@override @useResult
$Res call({
 String description, int amount, int? quantity, int? unitPrice, double? confidence
});




}
/// @nodoc
class __$ReceiptItemCopyWithImpl<$Res>
    implements _$ReceiptItemCopyWith<$Res> {
  __$ReceiptItemCopyWithImpl(this._self, this._then);

  final _ReceiptItem _self;
  final $Res Function(_ReceiptItem) _then;

/// Create a copy of ReceiptItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? description = null,Object? amount = null,Object? quantity = freezed,Object? unitPrice = freezed,Object? confidence = freezed,}) {
  return _then(_ReceiptItem(
description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,quantity: freezed == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int?,unitPrice: freezed == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as int?,confidence: freezed == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$Receipt {

 String get id; String get userId; String get imageUrl; String get extractedText; List<OCRLine> get lines; String? get merchant; String? get address; String? get phone; String? get email; int? get subtotal;// Cents
 int? get tax;// Cents
 int? get total;// Cents
 DateTime? get date; String? get paymentMethod; String? get receiptNumber; double get confidence; DateTime get createdAt; bool get processed; List<ReceiptItem>? get items; List<String>? get extractedTokens;// Normalized tokens for search
// Audit fields for currency conversion
 String? get originalCurrency; int? get originalTotal; int? get originalSubtotal; int? get originalTax; double? get exchangeRate; String? get archetype;// 'thermal', 'invoice', 'restaurant', etc.
 Map<String, double>? get fieldConfidences;
/// Create a copy of Receipt
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReceiptCopyWith<Receipt> get copyWith => _$ReceiptCopyWithImpl<Receipt>(this as Receipt, _$identity);

  /// Serializes this Receipt to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Receipt&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.extractedText, extractedText) || other.extractedText == extractedText)&&const DeepCollectionEquality().equals(other.lines, lines)&&(identical(other.merchant, merchant) || other.merchant == merchant)&&(identical(other.address, address) || other.address == address)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal)&&(identical(other.tax, tax) || other.tax == tax)&&(identical(other.total, total) || other.total == total)&&(identical(other.date, date) || other.date == date)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.receiptNumber, receiptNumber) || other.receiptNumber == receiptNumber)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.processed, processed) || other.processed == processed)&&const DeepCollectionEquality().equals(other.items, items)&&const DeepCollectionEquality().equals(other.extractedTokens, extractedTokens)&&(identical(other.originalCurrency, originalCurrency) || other.originalCurrency == originalCurrency)&&(identical(other.originalTotal, originalTotal) || other.originalTotal == originalTotal)&&(identical(other.originalSubtotal, originalSubtotal) || other.originalSubtotal == originalSubtotal)&&(identical(other.originalTax, originalTax) || other.originalTax == originalTax)&&(identical(other.exchangeRate, exchangeRate) || other.exchangeRate == exchangeRate)&&(identical(other.archetype, archetype) || other.archetype == archetype)&&const DeepCollectionEquality().equals(other.fieldConfidences, fieldConfidences));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,userId,imageUrl,extractedText,const DeepCollectionEquality().hash(lines),merchant,address,phone,email,subtotal,tax,total,date,paymentMethod,receiptNumber,confidence,createdAt,processed,const DeepCollectionEquality().hash(items),const DeepCollectionEquality().hash(extractedTokens),originalCurrency,originalTotal,originalSubtotal,originalTax,exchangeRate,archetype,const DeepCollectionEquality().hash(fieldConfidences)]);

@override
String toString() {
  return 'Receipt(id: $id, userId: $userId, imageUrl: $imageUrl, extractedText: $extractedText, lines: $lines, merchant: $merchant, address: $address, phone: $phone, email: $email, subtotal: $subtotal, tax: $tax, total: $total, date: $date, paymentMethod: $paymentMethod, receiptNumber: $receiptNumber, confidence: $confidence, createdAt: $createdAt, processed: $processed, items: $items, extractedTokens: $extractedTokens, originalCurrency: $originalCurrency, originalTotal: $originalTotal, originalSubtotal: $originalSubtotal, originalTax: $originalTax, exchangeRate: $exchangeRate, archetype: $archetype, fieldConfidences: $fieldConfidences)';
}


}

/// @nodoc
abstract mixin class $ReceiptCopyWith<$Res>  {
  factory $ReceiptCopyWith(Receipt value, $Res Function(Receipt) _then) = _$ReceiptCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String imageUrl, String extractedText, List<OCRLine> lines, String? merchant, String? address, String? phone, String? email, int? subtotal, int? tax, int? total, DateTime? date, String? paymentMethod, String? receiptNumber, double confidence, DateTime createdAt, bool processed, List<ReceiptItem>? items, List<String>? extractedTokens, String? originalCurrency, int? originalTotal, int? originalSubtotal, int? originalTax, double? exchangeRate, String? archetype, Map<String, double>? fieldConfidences
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? imageUrl = null,Object? extractedText = null,Object? lines = null,Object? merchant = freezed,Object? address = freezed,Object? phone = freezed,Object? email = freezed,Object? subtotal = freezed,Object? tax = freezed,Object? total = freezed,Object? date = freezed,Object? paymentMethod = freezed,Object? receiptNumber = freezed,Object? confidence = null,Object? createdAt = null,Object? processed = null,Object? items = freezed,Object? extractedTokens = freezed,Object? originalCurrency = freezed,Object? originalTotal = freezed,Object? originalSubtotal = freezed,Object? originalTax = freezed,Object? exchangeRate = freezed,Object? archetype = freezed,Object? fieldConfidences = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,extractedText: null == extractedText ? _self.extractedText : extractedText // ignore: cast_nullable_to_non_nullable
as String,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<OCRLine>,merchant: freezed == merchant ? _self.merchant : merchant // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,subtotal: freezed == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as int?,tax: freezed == tax ? _self.tax : tax // ignore: cast_nullable_to_non_nullable
as int?,total: freezed == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int?,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime?,paymentMethod: freezed == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String?,receiptNumber: freezed == receiptNumber ? _self.receiptNumber : receiptNumber // ignore: cast_nullable_to_non_nullable
as String?,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,processed: null == processed ? _self.processed : processed // ignore: cast_nullable_to_non_nullable
as bool,items: freezed == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<ReceiptItem>?,extractedTokens: freezed == extractedTokens ? _self.extractedTokens : extractedTokens // ignore: cast_nullable_to_non_nullable
as List<String>?,originalCurrency: freezed == originalCurrency ? _self.originalCurrency : originalCurrency // ignore: cast_nullable_to_non_nullable
as String?,originalTotal: freezed == originalTotal ? _self.originalTotal : originalTotal // ignore: cast_nullable_to_non_nullable
as int?,originalSubtotal: freezed == originalSubtotal ? _self.originalSubtotal : originalSubtotal // ignore: cast_nullable_to_non_nullable
as int?,originalTax: freezed == originalTax ? _self.originalTax : originalTax // ignore: cast_nullable_to_non_nullable
as int?,exchangeRate: freezed == exchangeRate ? _self.exchangeRate : exchangeRate // ignore: cast_nullable_to_non_nullable
as double?,archetype: freezed == archetype ? _self.archetype : archetype // ignore: cast_nullable_to_non_nullable
as String?,fieldConfidences: freezed == fieldConfidences ? _self.fieldConfidences : fieldConfidences // ignore: cast_nullable_to_non_nullable
as Map<String, double>?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String imageUrl,  String extractedText,  List<OCRLine> lines,  String? merchant,  String? address,  String? phone,  String? email,  int? subtotal,  int? tax,  int? total,  DateTime? date,  String? paymentMethod,  String? receiptNumber,  double confidence,  DateTime createdAt,  bool processed,  List<ReceiptItem>? items,  List<String>? extractedTokens,  String? originalCurrency,  int? originalTotal,  int? originalSubtotal,  int? originalTax,  double? exchangeRate,  String? archetype,  Map<String, double>? fieldConfidences)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Receipt() when $default != null:
return $default(_that.id,_that.userId,_that.imageUrl,_that.extractedText,_that.lines,_that.merchant,_that.address,_that.phone,_that.email,_that.subtotal,_that.tax,_that.total,_that.date,_that.paymentMethod,_that.receiptNumber,_that.confidence,_that.createdAt,_that.processed,_that.items,_that.extractedTokens,_that.originalCurrency,_that.originalTotal,_that.originalSubtotal,_that.originalTax,_that.exchangeRate,_that.archetype,_that.fieldConfidences);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String imageUrl,  String extractedText,  List<OCRLine> lines,  String? merchant,  String? address,  String? phone,  String? email,  int? subtotal,  int? tax,  int? total,  DateTime? date,  String? paymentMethod,  String? receiptNumber,  double confidence,  DateTime createdAt,  bool processed,  List<ReceiptItem>? items,  List<String>? extractedTokens,  String? originalCurrency,  int? originalTotal,  int? originalSubtotal,  int? originalTax,  double? exchangeRate,  String? archetype,  Map<String, double>? fieldConfidences)  $default,) {final _that = this;
switch (_that) {
case _Receipt():
return $default(_that.id,_that.userId,_that.imageUrl,_that.extractedText,_that.lines,_that.merchant,_that.address,_that.phone,_that.email,_that.subtotal,_that.tax,_that.total,_that.date,_that.paymentMethod,_that.receiptNumber,_that.confidence,_that.createdAt,_that.processed,_that.items,_that.extractedTokens,_that.originalCurrency,_that.originalTotal,_that.originalSubtotal,_that.originalTax,_that.exchangeRate,_that.archetype,_that.fieldConfidences);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String imageUrl,  String extractedText,  List<OCRLine> lines,  String? merchant,  String? address,  String? phone,  String? email,  int? subtotal,  int? tax,  int? total,  DateTime? date,  String? paymentMethod,  String? receiptNumber,  double confidence,  DateTime createdAt,  bool processed,  List<ReceiptItem>? items,  List<String>? extractedTokens,  String? originalCurrency,  int? originalTotal,  int? originalSubtotal,  int? originalTax,  double? exchangeRate,  String? archetype,  Map<String, double>? fieldConfidences)?  $default,) {final _that = this;
switch (_that) {
case _Receipt() when $default != null:
return $default(_that.id,_that.userId,_that.imageUrl,_that.extractedText,_that.lines,_that.merchant,_that.address,_that.phone,_that.email,_that.subtotal,_that.tax,_that.total,_that.date,_that.paymentMethod,_that.receiptNumber,_that.confidence,_that.createdAt,_that.processed,_that.items,_that.extractedTokens,_that.originalCurrency,_that.originalTotal,_that.originalSubtotal,_that.originalTax,_that.exchangeRate,_that.archetype,_that.fieldConfidences);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Receipt extends Receipt {
  const _Receipt({required this.id, required this.userId, required this.imageUrl, required this.extractedText, required final  List<OCRLine> lines, this.merchant, this.address, this.phone, this.email, this.subtotal, this.tax, this.total, this.date, this.paymentMethod, this.receiptNumber, required this.confidence, required this.createdAt, this.processed = false, final  List<ReceiptItem>? items, final  List<String>? extractedTokens, this.originalCurrency, this.originalTotal, this.originalSubtotal, this.originalTax, this.exchangeRate, this.archetype, final  Map<String, double>? fieldConfidences}): _lines = lines,_items = items,_extractedTokens = extractedTokens,_fieldConfidences = fieldConfidences,super._();
  factory _Receipt.fromJson(Map<String, dynamic> json) => _$ReceiptFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String imageUrl;
@override final  String extractedText;
 final  List<OCRLine> _lines;
@override List<OCRLine> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}

@override final  String? merchant;
@override final  String? address;
@override final  String? phone;
@override final  String? email;
@override final  int? subtotal;
// Cents
@override final  int? tax;
// Cents
@override final  int? total;
// Cents
@override final  DateTime? date;
@override final  String? paymentMethod;
@override final  String? receiptNumber;
@override final  double confidence;
@override final  DateTime createdAt;
@override@JsonKey() final  bool processed;
 final  List<ReceiptItem>? _items;
@override List<ReceiptItem>? get items {
  final value = _items;
  if (value == null) return null;
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<String>? _extractedTokens;
@override List<String>? get extractedTokens {
  final value = _extractedTokens;
  if (value == null) return null;
  if (_extractedTokens is EqualUnmodifiableListView) return _extractedTokens;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

// Normalized tokens for search
// Audit fields for currency conversion
@override final  String? originalCurrency;
@override final  int? originalTotal;
@override final  int? originalSubtotal;
@override final  int? originalTax;
@override final  double? exchangeRate;
@override final  String? archetype;
// 'thermal', 'invoice', 'restaurant', etc.
 final  Map<String, double>? _fieldConfidences;
// 'thermal', 'invoice', 'restaurant', etc.
@override Map<String, double>? get fieldConfidences {
  final value = _fieldConfidences;
  if (value == null) return null;
  if (_fieldConfidences is EqualUnmodifiableMapView) return _fieldConfidences;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Receipt&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.extractedText, extractedText) || other.extractedText == extractedText)&&const DeepCollectionEquality().equals(other._lines, _lines)&&(identical(other.merchant, merchant) || other.merchant == merchant)&&(identical(other.address, address) || other.address == address)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal)&&(identical(other.tax, tax) || other.tax == tax)&&(identical(other.total, total) || other.total == total)&&(identical(other.date, date) || other.date == date)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.receiptNumber, receiptNumber) || other.receiptNumber == receiptNumber)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.processed, processed) || other.processed == processed)&&const DeepCollectionEquality().equals(other._items, _items)&&const DeepCollectionEquality().equals(other._extractedTokens, _extractedTokens)&&(identical(other.originalCurrency, originalCurrency) || other.originalCurrency == originalCurrency)&&(identical(other.originalTotal, originalTotal) || other.originalTotal == originalTotal)&&(identical(other.originalSubtotal, originalSubtotal) || other.originalSubtotal == originalSubtotal)&&(identical(other.originalTax, originalTax) || other.originalTax == originalTax)&&(identical(other.exchangeRate, exchangeRate) || other.exchangeRate == exchangeRate)&&(identical(other.archetype, archetype) || other.archetype == archetype)&&const DeepCollectionEquality().equals(other._fieldConfidences, _fieldConfidences));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,userId,imageUrl,extractedText,const DeepCollectionEquality().hash(_lines),merchant,address,phone,email,subtotal,tax,total,date,paymentMethod,receiptNumber,confidence,createdAt,processed,const DeepCollectionEquality().hash(_items),const DeepCollectionEquality().hash(_extractedTokens),originalCurrency,originalTotal,originalSubtotal,originalTax,exchangeRate,archetype,const DeepCollectionEquality().hash(_fieldConfidences)]);

@override
String toString() {
  return 'Receipt(id: $id, userId: $userId, imageUrl: $imageUrl, extractedText: $extractedText, lines: $lines, merchant: $merchant, address: $address, phone: $phone, email: $email, subtotal: $subtotal, tax: $tax, total: $total, date: $date, paymentMethod: $paymentMethod, receiptNumber: $receiptNumber, confidence: $confidence, createdAt: $createdAt, processed: $processed, items: $items, extractedTokens: $extractedTokens, originalCurrency: $originalCurrency, originalTotal: $originalTotal, originalSubtotal: $originalSubtotal, originalTax: $originalTax, exchangeRate: $exchangeRate, archetype: $archetype, fieldConfidences: $fieldConfidences)';
}


}

/// @nodoc
abstract mixin class _$ReceiptCopyWith<$Res> implements $ReceiptCopyWith<$Res> {
  factory _$ReceiptCopyWith(_Receipt value, $Res Function(_Receipt) _then) = __$ReceiptCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String imageUrl, String extractedText, List<OCRLine> lines, String? merchant, String? address, String? phone, String? email, int? subtotal, int? tax, int? total, DateTime? date, String? paymentMethod, String? receiptNumber, double confidence, DateTime createdAt, bool processed, List<ReceiptItem>? items, List<String>? extractedTokens, String? originalCurrency, int? originalTotal, int? originalSubtotal, int? originalTax, double? exchangeRate, String? archetype, Map<String, double>? fieldConfidences
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? imageUrl = null,Object? extractedText = null,Object? lines = null,Object? merchant = freezed,Object? address = freezed,Object? phone = freezed,Object? email = freezed,Object? subtotal = freezed,Object? tax = freezed,Object? total = freezed,Object? date = freezed,Object? paymentMethod = freezed,Object? receiptNumber = freezed,Object? confidence = null,Object? createdAt = null,Object? processed = null,Object? items = freezed,Object? extractedTokens = freezed,Object? originalCurrency = freezed,Object? originalTotal = freezed,Object? originalSubtotal = freezed,Object? originalTax = freezed,Object? exchangeRate = freezed,Object? archetype = freezed,Object? fieldConfidences = freezed,}) {
  return _then(_Receipt(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,extractedText: null == extractedText ? _self.extractedText : extractedText // ignore: cast_nullable_to_non_nullable
as String,lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<OCRLine>,merchant: freezed == merchant ? _self.merchant : merchant // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,subtotal: freezed == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as int?,tax: freezed == tax ? _self.tax : tax // ignore: cast_nullable_to_non_nullable
as int?,total: freezed == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int?,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime?,paymentMethod: freezed == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String?,receiptNumber: freezed == receiptNumber ? _self.receiptNumber : receiptNumber // ignore: cast_nullable_to_non_nullable
as String?,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,processed: null == processed ? _self.processed : processed // ignore: cast_nullable_to_non_nullable
as bool,items: freezed == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<ReceiptItem>?,extractedTokens: freezed == extractedTokens ? _self._extractedTokens : extractedTokens // ignore: cast_nullable_to_non_nullable
as List<String>?,originalCurrency: freezed == originalCurrency ? _self.originalCurrency : originalCurrency // ignore: cast_nullable_to_non_nullable
as String?,originalTotal: freezed == originalTotal ? _self.originalTotal : originalTotal // ignore: cast_nullable_to_non_nullable
as int?,originalSubtotal: freezed == originalSubtotal ? _self.originalSubtotal : originalSubtotal // ignore: cast_nullable_to_non_nullable
as int?,originalTax: freezed == originalTax ? _self.originalTax : originalTax // ignore: cast_nullable_to_non_nullable
as int?,exchangeRate: freezed == exchangeRate ? _self.exchangeRate : exchangeRate // ignore: cast_nullable_to_non_nullable
as double?,archetype: freezed == archetype ? _self.archetype : archetype // ignore: cast_nullable_to_non_nullable
as String?,fieldConfidences: freezed == fieldConfidences ? _self._fieldConfidences : fieldConfidences // ignore: cast_nullable_to_non_nullable
as Map<String, double>?,
  ));
}


}

// dart format on
