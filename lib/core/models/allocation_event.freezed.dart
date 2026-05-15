// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'allocation_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AllocationEvent {

 String get id; String get userId; int get amount;// Positive means added to category, negative means removed
 String get fromEntityId;// 'ReadyToAssign' or Category ID
 String get toEntityId;// Category ID or 'ReadyToAssign'
 String get monthId;// Format: yyyy_mm, tracks which period this belongs to
@TimestampConverter() DateTime get timestamp;
/// Create a copy of AllocationEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AllocationEventCopyWith<AllocationEvent> get copyWith => _$AllocationEventCopyWithImpl<AllocationEvent>(this as AllocationEvent, _$identity);

  /// Serializes this AllocationEvent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AllocationEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.fromEntityId, fromEntityId) || other.fromEntityId == fromEntityId)&&(identical(other.toEntityId, toEntityId) || other.toEntityId == toEntityId)&&(identical(other.monthId, monthId) || other.monthId == monthId)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,amount,fromEntityId,toEntityId,monthId,timestamp);

@override
String toString() {
  return 'AllocationEvent(id: $id, userId: $userId, amount: $amount, fromEntityId: $fromEntityId, toEntityId: $toEntityId, monthId: $monthId, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class $AllocationEventCopyWith<$Res>  {
  factory $AllocationEventCopyWith(AllocationEvent value, $Res Function(AllocationEvent) _then) = _$AllocationEventCopyWithImpl;
@useResult
$Res call({
 String id, String userId, int amount, String fromEntityId, String toEntityId, String monthId,@TimestampConverter() DateTime timestamp
});




}
/// @nodoc
class _$AllocationEventCopyWithImpl<$Res>
    implements $AllocationEventCopyWith<$Res> {
  _$AllocationEventCopyWithImpl(this._self, this._then);

  final AllocationEvent _self;
  final $Res Function(AllocationEvent) _then;

/// Create a copy of AllocationEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? amount = null,Object? fromEntityId = null,Object? toEntityId = null,Object? monthId = null,Object? timestamp = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,fromEntityId: null == fromEntityId ? _self.fromEntityId : fromEntityId // ignore: cast_nullable_to_non_nullable
as String,toEntityId: null == toEntityId ? _self.toEntityId : toEntityId // ignore: cast_nullable_to_non_nullable
as String,monthId: null == monthId ? _self.monthId : monthId // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [AllocationEvent].
extension AllocationEventPatterns on AllocationEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AllocationEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AllocationEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AllocationEvent value)  $default,){
final _that = this;
switch (_that) {
case _AllocationEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AllocationEvent value)?  $default,){
final _that = this;
switch (_that) {
case _AllocationEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  int amount,  String fromEntityId,  String toEntityId,  String monthId, @TimestampConverter()  DateTime timestamp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AllocationEvent() when $default != null:
return $default(_that.id,_that.userId,_that.amount,_that.fromEntityId,_that.toEntityId,_that.monthId,_that.timestamp);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  int amount,  String fromEntityId,  String toEntityId,  String monthId, @TimestampConverter()  DateTime timestamp)  $default,) {final _that = this;
switch (_that) {
case _AllocationEvent():
return $default(_that.id,_that.userId,_that.amount,_that.fromEntityId,_that.toEntityId,_that.monthId,_that.timestamp);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  int amount,  String fromEntityId,  String toEntityId,  String monthId, @TimestampConverter()  DateTime timestamp)?  $default,) {final _that = this;
switch (_that) {
case _AllocationEvent() when $default != null:
return $default(_that.id,_that.userId,_that.amount,_that.fromEntityId,_that.toEntityId,_that.monthId,_that.timestamp);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AllocationEvent extends AllocationEvent {
  const _AllocationEvent({required this.id, required this.userId, required this.amount, required this.fromEntityId, required this.toEntityId, required this.monthId, @TimestampConverter() required this.timestamp}): super._();
  factory _AllocationEvent.fromJson(Map<String, dynamic> json) => _$AllocationEventFromJson(json);

@override final  String id;
@override final  String userId;
@override final  int amount;
// Positive means added to category, negative means removed
@override final  String fromEntityId;
// 'ReadyToAssign' or Category ID
@override final  String toEntityId;
// Category ID or 'ReadyToAssign'
@override final  String monthId;
// Format: yyyy_mm, tracks which period this belongs to
@override@TimestampConverter() final  DateTime timestamp;

/// Create a copy of AllocationEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AllocationEventCopyWith<_AllocationEvent> get copyWith => __$AllocationEventCopyWithImpl<_AllocationEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AllocationEventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AllocationEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.fromEntityId, fromEntityId) || other.fromEntityId == fromEntityId)&&(identical(other.toEntityId, toEntityId) || other.toEntityId == toEntityId)&&(identical(other.monthId, monthId) || other.monthId == monthId)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,amount,fromEntityId,toEntityId,monthId,timestamp);

@override
String toString() {
  return 'AllocationEvent(id: $id, userId: $userId, amount: $amount, fromEntityId: $fromEntityId, toEntityId: $toEntityId, monthId: $monthId, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class _$AllocationEventCopyWith<$Res> implements $AllocationEventCopyWith<$Res> {
  factory _$AllocationEventCopyWith(_AllocationEvent value, $Res Function(_AllocationEvent) _then) = __$AllocationEventCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, int amount, String fromEntityId, String toEntityId, String monthId,@TimestampConverter() DateTime timestamp
});




}
/// @nodoc
class __$AllocationEventCopyWithImpl<$Res>
    implements _$AllocationEventCopyWith<$Res> {
  __$AllocationEventCopyWithImpl(this._self, this._then);

  final _AllocationEvent _self;
  final $Res Function(_AllocationEvent) _then;

/// Create a copy of AllocationEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? amount = null,Object? fromEntityId = null,Object? toEntityId = null,Object? monthId = null,Object? timestamp = null,}) {
  return _then(_AllocationEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,fromEntityId: null == fromEntityId ? _self.fromEntityId : fromEntityId // ignore: cast_nullable_to_non_nullable
as String,toEntityId: null == toEntityId ? _self.toEntityId : toEntityId // ignore: cast_nullable_to_non_nullable
as String,monthId: null == monthId ? _self.monthId : monthId // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
