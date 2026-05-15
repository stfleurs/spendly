// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppTransaction {

 String get id; String get userId; String get type;// income | expense | transfer
 int get amount; String get currency;@TimestampConverter() DateTime get date; String get accountId; String get categoryId; String? get note; String? get receiptUrl; String? get receiptId; String? get billId; String? get templateId;// Normalized accounting fields (The Immutable Truth)
 int get amountInBaseCurrency; String get baseCurrency; double get exchangeRate;// User still sees this as decimal
 int get rateScale;// 1,000,000 for integer math
 int get scaledRate;// (exchangeRate * rateScale).round()
 String get rateSource;// FX Metadata
 String get rateBaseCurrency; String get rateQuoteCurrency;// Original payment data
 int? get originalAmount; String? get originalCurrency; String? get sourceHash; List<String>? get searchTokens;// --- Server Reconciliation & Mutation Tracking ---
 String? get idempotencyKey; String get mutationState;// pending | confirmed | reconciled | failed | corrected
 int get mutationVersion; String get mutationSource; String? get failureReason; String? get parentMutationId;@TimestampNullableConverter() DateTime? get confirmedAt;@TimestampNullableConverter() DateTime? get reconciledAt;// Multi-device synchronization
 String? get deviceId; int? get mutationSequence;
/// Create a copy of AppTransaction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppTransactionCopyWith<AppTransaction> get copyWith => _$AppTransactionCopyWithImpl<AppTransaction>(this as AppTransaction, _$identity);

  /// Serializes this AppTransaction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppTransaction&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.type, type) || other.type == type)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.date, date) || other.date == date)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.note, note) || other.note == note)&&(identical(other.receiptUrl, receiptUrl) || other.receiptUrl == receiptUrl)&&(identical(other.receiptId, receiptId) || other.receiptId == receiptId)&&(identical(other.billId, billId) || other.billId == billId)&&(identical(other.templateId, templateId) || other.templateId == templateId)&&(identical(other.amountInBaseCurrency, amountInBaseCurrency) || other.amountInBaseCurrency == amountInBaseCurrency)&&(identical(other.baseCurrency, baseCurrency) || other.baseCurrency == baseCurrency)&&(identical(other.exchangeRate, exchangeRate) || other.exchangeRate == exchangeRate)&&(identical(other.rateScale, rateScale) || other.rateScale == rateScale)&&(identical(other.scaledRate, scaledRate) || other.scaledRate == scaledRate)&&(identical(other.rateSource, rateSource) || other.rateSource == rateSource)&&(identical(other.rateBaseCurrency, rateBaseCurrency) || other.rateBaseCurrency == rateBaseCurrency)&&(identical(other.rateQuoteCurrency, rateQuoteCurrency) || other.rateQuoteCurrency == rateQuoteCurrency)&&(identical(other.originalAmount, originalAmount) || other.originalAmount == originalAmount)&&(identical(other.originalCurrency, originalCurrency) || other.originalCurrency == originalCurrency)&&(identical(other.sourceHash, sourceHash) || other.sourceHash == sourceHash)&&const DeepCollectionEquality().equals(other.searchTokens, searchTokens)&&(identical(other.idempotencyKey, idempotencyKey) || other.idempotencyKey == idempotencyKey)&&(identical(other.mutationState, mutationState) || other.mutationState == mutationState)&&(identical(other.mutationVersion, mutationVersion) || other.mutationVersion == mutationVersion)&&(identical(other.mutationSource, mutationSource) || other.mutationSource == mutationSource)&&(identical(other.failureReason, failureReason) || other.failureReason == failureReason)&&(identical(other.parentMutationId, parentMutationId) || other.parentMutationId == parentMutationId)&&(identical(other.confirmedAt, confirmedAt) || other.confirmedAt == confirmedAt)&&(identical(other.reconciledAt, reconciledAt) || other.reconciledAt == reconciledAt)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.mutationSequence, mutationSequence) || other.mutationSequence == mutationSequence));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,userId,type,amount,currency,date,accountId,categoryId,note,receiptUrl,receiptId,billId,templateId,amountInBaseCurrency,baseCurrency,exchangeRate,rateScale,scaledRate,rateSource,rateBaseCurrency,rateQuoteCurrency,originalAmount,originalCurrency,sourceHash,const DeepCollectionEquality().hash(searchTokens),idempotencyKey,mutationState,mutationVersion,mutationSource,failureReason,parentMutationId,confirmedAt,reconciledAt,deviceId,mutationSequence]);

@override
String toString() {
  return 'AppTransaction(id: $id, userId: $userId, type: $type, amount: $amount, currency: $currency, date: $date, accountId: $accountId, categoryId: $categoryId, note: $note, receiptUrl: $receiptUrl, receiptId: $receiptId, billId: $billId, templateId: $templateId, amountInBaseCurrency: $amountInBaseCurrency, baseCurrency: $baseCurrency, exchangeRate: $exchangeRate, rateScale: $rateScale, scaledRate: $scaledRate, rateSource: $rateSource, rateBaseCurrency: $rateBaseCurrency, rateQuoteCurrency: $rateQuoteCurrency, originalAmount: $originalAmount, originalCurrency: $originalCurrency, sourceHash: $sourceHash, searchTokens: $searchTokens, idempotencyKey: $idempotencyKey, mutationState: $mutationState, mutationVersion: $mutationVersion, mutationSource: $mutationSource, failureReason: $failureReason, parentMutationId: $parentMutationId, confirmedAt: $confirmedAt, reconciledAt: $reconciledAt, deviceId: $deviceId, mutationSequence: $mutationSequence)';
}


}

/// @nodoc
abstract mixin class $AppTransactionCopyWith<$Res>  {
  factory $AppTransactionCopyWith(AppTransaction value, $Res Function(AppTransaction) _then) = _$AppTransactionCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String type, int amount, String currency,@TimestampConverter() DateTime date, String accountId, String categoryId, String? note, String? receiptUrl, String? receiptId, String? billId, String? templateId, int amountInBaseCurrency, String baseCurrency, double exchangeRate, int rateScale, int scaledRate, String rateSource, String rateBaseCurrency, String rateQuoteCurrency, int? originalAmount, String? originalCurrency, String? sourceHash, List<String>? searchTokens, String? idempotencyKey, String mutationState, int mutationVersion, String mutationSource, String? failureReason, String? parentMutationId,@TimestampNullableConverter() DateTime? confirmedAt,@TimestampNullableConverter() DateTime? reconciledAt, String? deviceId, int? mutationSequence
});




}
/// @nodoc
class _$AppTransactionCopyWithImpl<$Res>
    implements $AppTransactionCopyWith<$Res> {
  _$AppTransactionCopyWithImpl(this._self, this._then);

  final AppTransaction _self;
  final $Res Function(AppTransaction) _then;

/// Create a copy of AppTransaction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? type = null,Object? amount = null,Object? currency = null,Object? date = null,Object? accountId = null,Object? categoryId = null,Object? note = freezed,Object? receiptUrl = freezed,Object? receiptId = freezed,Object? billId = freezed,Object? templateId = freezed,Object? amountInBaseCurrency = null,Object? baseCurrency = null,Object? exchangeRate = null,Object? rateScale = null,Object? scaledRate = null,Object? rateSource = null,Object? rateBaseCurrency = null,Object? rateQuoteCurrency = null,Object? originalAmount = freezed,Object? originalCurrency = freezed,Object? sourceHash = freezed,Object? searchTokens = freezed,Object? idempotencyKey = freezed,Object? mutationState = null,Object? mutationVersion = null,Object? mutationSource = null,Object? failureReason = freezed,Object? parentMutationId = freezed,Object? confirmedAt = freezed,Object? reconciledAt = freezed,Object? deviceId = freezed,Object? mutationSequence = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,receiptUrl: freezed == receiptUrl ? _self.receiptUrl : receiptUrl // ignore: cast_nullable_to_non_nullable
as String?,receiptId: freezed == receiptId ? _self.receiptId : receiptId // ignore: cast_nullable_to_non_nullable
as String?,billId: freezed == billId ? _self.billId : billId // ignore: cast_nullable_to_non_nullable
as String?,templateId: freezed == templateId ? _self.templateId : templateId // ignore: cast_nullable_to_non_nullable
as String?,amountInBaseCurrency: null == amountInBaseCurrency ? _self.amountInBaseCurrency : amountInBaseCurrency // ignore: cast_nullable_to_non_nullable
as int,baseCurrency: null == baseCurrency ? _self.baseCurrency : baseCurrency // ignore: cast_nullable_to_non_nullable
as String,exchangeRate: null == exchangeRate ? _self.exchangeRate : exchangeRate // ignore: cast_nullable_to_non_nullable
as double,rateScale: null == rateScale ? _self.rateScale : rateScale // ignore: cast_nullable_to_non_nullable
as int,scaledRate: null == scaledRate ? _self.scaledRate : scaledRate // ignore: cast_nullable_to_non_nullable
as int,rateSource: null == rateSource ? _self.rateSource : rateSource // ignore: cast_nullable_to_non_nullable
as String,rateBaseCurrency: null == rateBaseCurrency ? _self.rateBaseCurrency : rateBaseCurrency // ignore: cast_nullable_to_non_nullable
as String,rateQuoteCurrency: null == rateQuoteCurrency ? _self.rateQuoteCurrency : rateQuoteCurrency // ignore: cast_nullable_to_non_nullable
as String,originalAmount: freezed == originalAmount ? _self.originalAmount : originalAmount // ignore: cast_nullable_to_non_nullable
as int?,originalCurrency: freezed == originalCurrency ? _self.originalCurrency : originalCurrency // ignore: cast_nullable_to_non_nullable
as String?,sourceHash: freezed == sourceHash ? _self.sourceHash : sourceHash // ignore: cast_nullable_to_non_nullable
as String?,searchTokens: freezed == searchTokens ? _self.searchTokens : searchTokens // ignore: cast_nullable_to_non_nullable
as List<String>?,idempotencyKey: freezed == idempotencyKey ? _self.idempotencyKey : idempotencyKey // ignore: cast_nullable_to_non_nullable
as String?,mutationState: null == mutationState ? _self.mutationState : mutationState // ignore: cast_nullable_to_non_nullable
as String,mutationVersion: null == mutationVersion ? _self.mutationVersion : mutationVersion // ignore: cast_nullable_to_non_nullable
as int,mutationSource: null == mutationSource ? _self.mutationSource : mutationSource // ignore: cast_nullable_to_non_nullable
as String,failureReason: freezed == failureReason ? _self.failureReason : failureReason // ignore: cast_nullable_to_non_nullable
as String?,parentMutationId: freezed == parentMutationId ? _self.parentMutationId : parentMutationId // ignore: cast_nullable_to_non_nullable
as String?,confirmedAt: freezed == confirmedAt ? _self.confirmedAt : confirmedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,reconciledAt: freezed == reconciledAt ? _self.reconciledAt : reconciledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deviceId: freezed == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String?,mutationSequence: freezed == mutationSequence ? _self.mutationSequence : mutationSequence // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [AppTransaction].
extension AppTransactionPatterns on AppTransaction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppTransaction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppTransaction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppTransaction value)  $default,){
final _that = this;
switch (_that) {
case _AppTransaction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppTransaction value)?  $default,){
final _that = this;
switch (_that) {
case _AppTransaction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String type,  int amount,  String currency, @TimestampConverter()  DateTime date,  String accountId,  String categoryId,  String? note,  String? receiptUrl,  String? receiptId,  String? billId,  String? templateId,  int amountInBaseCurrency,  String baseCurrency,  double exchangeRate,  int rateScale,  int scaledRate,  String rateSource,  String rateBaseCurrency,  String rateQuoteCurrency,  int? originalAmount,  String? originalCurrency,  String? sourceHash,  List<String>? searchTokens,  String? idempotencyKey,  String mutationState,  int mutationVersion,  String mutationSource,  String? failureReason,  String? parentMutationId, @TimestampNullableConverter()  DateTime? confirmedAt, @TimestampNullableConverter()  DateTime? reconciledAt,  String? deviceId,  int? mutationSequence)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppTransaction() when $default != null:
return $default(_that.id,_that.userId,_that.type,_that.amount,_that.currency,_that.date,_that.accountId,_that.categoryId,_that.note,_that.receiptUrl,_that.receiptId,_that.billId,_that.templateId,_that.amountInBaseCurrency,_that.baseCurrency,_that.exchangeRate,_that.rateScale,_that.scaledRate,_that.rateSource,_that.rateBaseCurrency,_that.rateQuoteCurrency,_that.originalAmount,_that.originalCurrency,_that.sourceHash,_that.searchTokens,_that.idempotencyKey,_that.mutationState,_that.mutationVersion,_that.mutationSource,_that.failureReason,_that.parentMutationId,_that.confirmedAt,_that.reconciledAt,_that.deviceId,_that.mutationSequence);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String type,  int amount,  String currency, @TimestampConverter()  DateTime date,  String accountId,  String categoryId,  String? note,  String? receiptUrl,  String? receiptId,  String? billId,  String? templateId,  int amountInBaseCurrency,  String baseCurrency,  double exchangeRate,  int rateScale,  int scaledRate,  String rateSource,  String rateBaseCurrency,  String rateQuoteCurrency,  int? originalAmount,  String? originalCurrency,  String? sourceHash,  List<String>? searchTokens,  String? idempotencyKey,  String mutationState,  int mutationVersion,  String mutationSource,  String? failureReason,  String? parentMutationId, @TimestampNullableConverter()  DateTime? confirmedAt, @TimestampNullableConverter()  DateTime? reconciledAt,  String? deviceId,  int? mutationSequence)  $default,) {final _that = this;
switch (_that) {
case _AppTransaction():
return $default(_that.id,_that.userId,_that.type,_that.amount,_that.currency,_that.date,_that.accountId,_that.categoryId,_that.note,_that.receiptUrl,_that.receiptId,_that.billId,_that.templateId,_that.amountInBaseCurrency,_that.baseCurrency,_that.exchangeRate,_that.rateScale,_that.scaledRate,_that.rateSource,_that.rateBaseCurrency,_that.rateQuoteCurrency,_that.originalAmount,_that.originalCurrency,_that.sourceHash,_that.searchTokens,_that.idempotencyKey,_that.mutationState,_that.mutationVersion,_that.mutationSource,_that.failureReason,_that.parentMutationId,_that.confirmedAt,_that.reconciledAt,_that.deviceId,_that.mutationSequence);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String type,  int amount,  String currency, @TimestampConverter()  DateTime date,  String accountId,  String categoryId,  String? note,  String? receiptUrl,  String? receiptId,  String? billId,  String? templateId,  int amountInBaseCurrency,  String baseCurrency,  double exchangeRate,  int rateScale,  int scaledRate,  String rateSource,  String rateBaseCurrency,  String rateQuoteCurrency,  int? originalAmount,  String? originalCurrency,  String? sourceHash,  List<String>? searchTokens,  String? idempotencyKey,  String mutationState,  int mutationVersion,  String mutationSource,  String? failureReason,  String? parentMutationId, @TimestampNullableConverter()  DateTime? confirmedAt, @TimestampNullableConverter()  DateTime? reconciledAt,  String? deviceId,  int? mutationSequence)?  $default,) {final _that = this;
switch (_that) {
case _AppTransaction() when $default != null:
return $default(_that.id,_that.userId,_that.type,_that.amount,_that.currency,_that.date,_that.accountId,_that.categoryId,_that.note,_that.receiptUrl,_that.receiptId,_that.billId,_that.templateId,_that.amountInBaseCurrency,_that.baseCurrency,_that.exchangeRate,_that.rateScale,_that.scaledRate,_that.rateSource,_that.rateBaseCurrency,_that.rateQuoteCurrency,_that.originalAmount,_that.originalCurrency,_that.sourceHash,_that.searchTokens,_that.idempotencyKey,_that.mutationState,_that.mutationVersion,_that.mutationSource,_that.failureReason,_that.parentMutationId,_that.confirmedAt,_that.reconciledAt,_that.deviceId,_that.mutationSequence);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppTransaction extends AppTransaction {
  const _AppTransaction({required this.id, required this.userId, required this.type, required this.amount, required this.currency, @TimestampConverter() required this.date, required this.accountId, required this.categoryId, this.note, this.receiptUrl, this.receiptId, this.billId, this.templateId, this.amountInBaseCurrency = 0, this.baseCurrency = 'USD', this.exchangeRate = 1.0, this.rateScale = 1000000, this.scaledRate = 1000000, this.rateSource = 'manual', this.rateBaseCurrency = 'USD', this.rateQuoteCurrency = 'USD', this.originalAmount, this.originalCurrency, this.sourceHash, final  List<String>? searchTokens, this.idempotencyKey, this.mutationState = 'pending', this.mutationVersion = 1, this.mutationSource = 'client', this.failureReason, this.parentMutationId, @TimestampNullableConverter() this.confirmedAt, @TimestampNullableConverter() this.reconciledAt, this.deviceId, this.mutationSequence}): _searchTokens = searchTokens,super._();
  factory _AppTransaction.fromJson(Map<String, dynamic> json) => _$AppTransactionFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String type;
// income | expense | transfer
@override final  int amount;
@override final  String currency;
@override@TimestampConverter() final  DateTime date;
@override final  String accountId;
@override final  String categoryId;
@override final  String? note;
@override final  String? receiptUrl;
@override final  String? receiptId;
@override final  String? billId;
@override final  String? templateId;
// Normalized accounting fields (The Immutable Truth)
@override@JsonKey() final  int amountInBaseCurrency;
@override@JsonKey() final  String baseCurrency;
@override@JsonKey() final  double exchangeRate;
// User still sees this as decimal
@override@JsonKey() final  int rateScale;
// 1,000,000 for integer math
@override@JsonKey() final  int scaledRate;
// (exchangeRate * rateScale).round()
@override@JsonKey() final  String rateSource;
// FX Metadata
@override@JsonKey() final  String rateBaseCurrency;
@override@JsonKey() final  String rateQuoteCurrency;
// Original payment data
@override final  int? originalAmount;
@override final  String? originalCurrency;
@override final  String? sourceHash;
 final  List<String>? _searchTokens;
@override List<String>? get searchTokens {
  final value = _searchTokens;
  if (value == null) return null;
  if (_searchTokens is EqualUnmodifiableListView) return _searchTokens;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

// --- Server Reconciliation & Mutation Tracking ---
@override final  String? idempotencyKey;
@override@JsonKey() final  String mutationState;
// pending | confirmed | reconciled | failed | corrected
@override@JsonKey() final  int mutationVersion;
@override@JsonKey() final  String mutationSource;
@override final  String? failureReason;
@override final  String? parentMutationId;
@override@TimestampNullableConverter() final  DateTime? confirmedAt;
@override@TimestampNullableConverter() final  DateTime? reconciledAt;
// Multi-device synchronization
@override final  String? deviceId;
@override final  int? mutationSequence;

/// Create a copy of AppTransaction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppTransactionCopyWith<_AppTransaction> get copyWith => __$AppTransactionCopyWithImpl<_AppTransaction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppTransactionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppTransaction&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.type, type) || other.type == type)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.date, date) || other.date == date)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.note, note) || other.note == note)&&(identical(other.receiptUrl, receiptUrl) || other.receiptUrl == receiptUrl)&&(identical(other.receiptId, receiptId) || other.receiptId == receiptId)&&(identical(other.billId, billId) || other.billId == billId)&&(identical(other.templateId, templateId) || other.templateId == templateId)&&(identical(other.amountInBaseCurrency, amountInBaseCurrency) || other.amountInBaseCurrency == amountInBaseCurrency)&&(identical(other.baseCurrency, baseCurrency) || other.baseCurrency == baseCurrency)&&(identical(other.exchangeRate, exchangeRate) || other.exchangeRate == exchangeRate)&&(identical(other.rateScale, rateScale) || other.rateScale == rateScale)&&(identical(other.scaledRate, scaledRate) || other.scaledRate == scaledRate)&&(identical(other.rateSource, rateSource) || other.rateSource == rateSource)&&(identical(other.rateBaseCurrency, rateBaseCurrency) || other.rateBaseCurrency == rateBaseCurrency)&&(identical(other.rateQuoteCurrency, rateQuoteCurrency) || other.rateQuoteCurrency == rateQuoteCurrency)&&(identical(other.originalAmount, originalAmount) || other.originalAmount == originalAmount)&&(identical(other.originalCurrency, originalCurrency) || other.originalCurrency == originalCurrency)&&(identical(other.sourceHash, sourceHash) || other.sourceHash == sourceHash)&&const DeepCollectionEquality().equals(other._searchTokens, _searchTokens)&&(identical(other.idempotencyKey, idempotencyKey) || other.idempotencyKey == idempotencyKey)&&(identical(other.mutationState, mutationState) || other.mutationState == mutationState)&&(identical(other.mutationVersion, mutationVersion) || other.mutationVersion == mutationVersion)&&(identical(other.mutationSource, mutationSource) || other.mutationSource == mutationSource)&&(identical(other.failureReason, failureReason) || other.failureReason == failureReason)&&(identical(other.parentMutationId, parentMutationId) || other.parentMutationId == parentMutationId)&&(identical(other.confirmedAt, confirmedAt) || other.confirmedAt == confirmedAt)&&(identical(other.reconciledAt, reconciledAt) || other.reconciledAt == reconciledAt)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.mutationSequence, mutationSequence) || other.mutationSequence == mutationSequence));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,userId,type,amount,currency,date,accountId,categoryId,note,receiptUrl,receiptId,billId,templateId,amountInBaseCurrency,baseCurrency,exchangeRate,rateScale,scaledRate,rateSource,rateBaseCurrency,rateQuoteCurrency,originalAmount,originalCurrency,sourceHash,const DeepCollectionEquality().hash(_searchTokens),idempotencyKey,mutationState,mutationVersion,mutationSource,failureReason,parentMutationId,confirmedAt,reconciledAt,deviceId,mutationSequence]);

@override
String toString() {
  return 'AppTransaction(id: $id, userId: $userId, type: $type, amount: $amount, currency: $currency, date: $date, accountId: $accountId, categoryId: $categoryId, note: $note, receiptUrl: $receiptUrl, receiptId: $receiptId, billId: $billId, templateId: $templateId, amountInBaseCurrency: $amountInBaseCurrency, baseCurrency: $baseCurrency, exchangeRate: $exchangeRate, rateScale: $rateScale, scaledRate: $scaledRate, rateSource: $rateSource, rateBaseCurrency: $rateBaseCurrency, rateQuoteCurrency: $rateQuoteCurrency, originalAmount: $originalAmount, originalCurrency: $originalCurrency, sourceHash: $sourceHash, searchTokens: $searchTokens, idempotencyKey: $idempotencyKey, mutationState: $mutationState, mutationVersion: $mutationVersion, mutationSource: $mutationSource, failureReason: $failureReason, parentMutationId: $parentMutationId, confirmedAt: $confirmedAt, reconciledAt: $reconciledAt, deviceId: $deviceId, mutationSequence: $mutationSequence)';
}


}

/// @nodoc
abstract mixin class _$AppTransactionCopyWith<$Res> implements $AppTransactionCopyWith<$Res> {
  factory _$AppTransactionCopyWith(_AppTransaction value, $Res Function(_AppTransaction) _then) = __$AppTransactionCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String type, int amount, String currency,@TimestampConverter() DateTime date, String accountId, String categoryId, String? note, String? receiptUrl, String? receiptId, String? billId, String? templateId, int amountInBaseCurrency, String baseCurrency, double exchangeRate, int rateScale, int scaledRate, String rateSource, String rateBaseCurrency, String rateQuoteCurrency, int? originalAmount, String? originalCurrency, String? sourceHash, List<String>? searchTokens, String? idempotencyKey, String mutationState, int mutationVersion, String mutationSource, String? failureReason, String? parentMutationId,@TimestampNullableConverter() DateTime? confirmedAt,@TimestampNullableConverter() DateTime? reconciledAt, String? deviceId, int? mutationSequence
});




}
/// @nodoc
class __$AppTransactionCopyWithImpl<$Res>
    implements _$AppTransactionCopyWith<$Res> {
  __$AppTransactionCopyWithImpl(this._self, this._then);

  final _AppTransaction _self;
  final $Res Function(_AppTransaction) _then;

/// Create a copy of AppTransaction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? type = null,Object? amount = null,Object? currency = null,Object? date = null,Object? accountId = null,Object? categoryId = null,Object? note = freezed,Object? receiptUrl = freezed,Object? receiptId = freezed,Object? billId = freezed,Object? templateId = freezed,Object? amountInBaseCurrency = null,Object? baseCurrency = null,Object? exchangeRate = null,Object? rateScale = null,Object? scaledRate = null,Object? rateSource = null,Object? rateBaseCurrency = null,Object? rateQuoteCurrency = null,Object? originalAmount = freezed,Object? originalCurrency = freezed,Object? sourceHash = freezed,Object? searchTokens = freezed,Object? idempotencyKey = freezed,Object? mutationState = null,Object? mutationVersion = null,Object? mutationSource = null,Object? failureReason = freezed,Object? parentMutationId = freezed,Object? confirmedAt = freezed,Object? reconciledAt = freezed,Object? deviceId = freezed,Object? mutationSequence = freezed,}) {
  return _then(_AppTransaction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,receiptUrl: freezed == receiptUrl ? _self.receiptUrl : receiptUrl // ignore: cast_nullable_to_non_nullable
as String?,receiptId: freezed == receiptId ? _self.receiptId : receiptId // ignore: cast_nullable_to_non_nullable
as String?,billId: freezed == billId ? _self.billId : billId // ignore: cast_nullable_to_non_nullable
as String?,templateId: freezed == templateId ? _self.templateId : templateId // ignore: cast_nullable_to_non_nullable
as String?,amountInBaseCurrency: null == amountInBaseCurrency ? _self.amountInBaseCurrency : amountInBaseCurrency // ignore: cast_nullable_to_non_nullable
as int,baseCurrency: null == baseCurrency ? _self.baseCurrency : baseCurrency // ignore: cast_nullable_to_non_nullable
as String,exchangeRate: null == exchangeRate ? _self.exchangeRate : exchangeRate // ignore: cast_nullable_to_non_nullable
as double,rateScale: null == rateScale ? _self.rateScale : rateScale // ignore: cast_nullable_to_non_nullable
as int,scaledRate: null == scaledRate ? _self.scaledRate : scaledRate // ignore: cast_nullable_to_non_nullable
as int,rateSource: null == rateSource ? _self.rateSource : rateSource // ignore: cast_nullable_to_non_nullable
as String,rateBaseCurrency: null == rateBaseCurrency ? _self.rateBaseCurrency : rateBaseCurrency // ignore: cast_nullable_to_non_nullable
as String,rateQuoteCurrency: null == rateQuoteCurrency ? _self.rateQuoteCurrency : rateQuoteCurrency // ignore: cast_nullable_to_non_nullable
as String,originalAmount: freezed == originalAmount ? _self.originalAmount : originalAmount // ignore: cast_nullable_to_non_nullable
as int?,originalCurrency: freezed == originalCurrency ? _self.originalCurrency : originalCurrency // ignore: cast_nullable_to_non_nullable
as String?,sourceHash: freezed == sourceHash ? _self.sourceHash : sourceHash // ignore: cast_nullable_to_non_nullable
as String?,searchTokens: freezed == searchTokens ? _self._searchTokens : searchTokens // ignore: cast_nullable_to_non_nullable
as List<String>?,idempotencyKey: freezed == idempotencyKey ? _self.idempotencyKey : idempotencyKey // ignore: cast_nullable_to_non_nullable
as String?,mutationState: null == mutationState ? _self.mutationState : mutationState // ignore: cast_nullable_to_non_nullable
as String,mutationVersion: null == mutationVersion ? _self.mutationVersion : mutationVersion // ignore: cast_nullable_to_non_nullable
as int,mutationSource: null == mutationSource ? _self.mutationSource : mutationSource // ignore: cast_nullable_to_non_nullable
as String,failureReason: freezed == failureReason ? _self.failureReason : failureReason // ignore: cast_nullable_to_non_nullable
as String?,parentMutationId: freezed == parentMutationId ? _self.parentMutationId : parentMutationId // ignore: cast_nullable_to_non_nullable
as String?,confirmedAt: freezed == confirmedAt ? _self.confirmedAt : confirmedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,reconciledAt: freezed == reconciledAt ? _self.reconciledAt : reconciledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deviceId: freezed == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String?,mutationSequence: freezed == mutationSequence ? _self.mutationSequence : mutationSequence // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
