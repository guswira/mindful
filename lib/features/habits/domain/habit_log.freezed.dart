// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'habit_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HabitLog {

 String get id;@JsonKey(name: 'user_id') String get userId;@JsonKey(name: 'habit_id') String get habitId; DateTime get date;@JsonKey(name: 'completed_action_id') String? get completedActionId; String? get note;@JsonKey(name: 'sync_status') SyncStatus get syncStatus;
/// Create a copy of HabitLog
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HabitLogCopyWith<HabitLog> get copyWith => _$HabitLogCopyWithImpl<HabitLog>(this as HabitLog, _$identity);

  /// Serializes this HabitLog to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HabitLog&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.habitId, habitId) || other.habitId == habitId)&&(identical(other.date, date) || other.date == date)&&(identical(other.completedActionId, completedActionId) || other.completedActionId == completedActionId)&&(identical(other.note, note) || other.note == note)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,habitId,date,completedActionId,note,syncStatus);

@override
String toString() {
  return 'HabitLog(id: $id, userId: $userId, habitId: $habitId, date: $date, completedActionId: $completedActionId, note: $note, syncStatus: $syncStatus)';
}


}

/// @nodoc
abstract mixin class $HabitLogCopyWith<$Res>  {
  factory $HabitLogCopyWith(HabitLog value, $Res Function(HabitLog) _then) = _$HabitLogCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'habit_id') String habitId, DateTime date,@JsonKey(name: 'completed_action_id') String? completedActionId, String? note,@JsonKey(name: 'sync_status') SyncStatus syncStatus
});




}
/// @nodoc
class _$HabitLogCopyWithImpl<$Res>
    implements $HabitLogCopyWith<$Res> {
  _$HabitLogCopyWithImpl(this._self, this._then);

  final HabitLog _self;
  final $Res Function(HabitLog) _then;

/// Create a copy of HabitLog
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? habitId = null,Object? date = null,Object? completedActionId = freezed,Object? note = freezed,Object? syncStatus = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,habitId: null == habitId ? _self.habitId : habitId // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,completedActionId: freezed == completedActionId ? _self.completedActionId : completedActionId // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as SyncStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [HabitLog].
extension HabitLogPatterns on HabitLog {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HabitLog value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HabitLog() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HabitLog value)  $default,){
final _that = this;
switch (_that) {
case _HabitLog():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HabitLog value)?  $default,){
final _that = this;
switch (_that) {
case _HabitLog() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'habit_id')  String habitId,  DateTime date, @JsonKey(name: 'completed_action_id')  String? completedActionId,  String? note, @JsonKey(name: 'sync_status')  SyncStatus syncStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HabitLog() when $default != null:
return $default(_that.id,_that.userId,_that.habitId,_that.date,_that.completedActionId,_that.note,_that.syncStatus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'habit_id')  String habitId,  DateTime date, @JsonKey(name: 'completed_action_id')  String? completedActionId,  String? note, @JsonKey(name: 'sync_status')  SyncStatus syncStatus)  $default,) {final _that = this;
switch (_that) {
case _HabitLog():
return $default(_that.id,_that.userId,_that.habitId,_that.date,_that.completedActionId,_that.note,_that.syncStatus);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'habit_id')  String habitId,  DateTime date, @JsonKey(name: 'completed_action_id')  String? completedActionId,  String? note, @JsonKey(name: 'sync_status')  SyncStatus syncStatus)?  $default,) {final _that = this;
switch (_that) {
case _HabitLog() when $default != null:
return $default(_that.id,_that.userId,_that.habitId,_that.date,_that.completedActionId,_that.note,_that.syncStatus);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HabitLog implements HabitLog {
  const _HabitLog({required this.id, @JsonKey(name: 'user_id') required this.userId, @JsonKey(name: 'habit_id') required this.habitId, required this.date, @JsonKey(name: 'completed_action_id') this.completedActionId, this.note, @JsonKey(name: 'sync_status') this.syncStatus = SyncStatus.synced});
  factory _HabitLog.fromJson(Map<String, dynamic> json) => _$HabitLogFromJson(json);

@override final  String id;
@override@JsonKey(name: 'user_id') final  String userId;
@override@JsonKey(name: 'habit_id') final  String habitId;
@override final  DateTime date;
@override@JsonKey(name: 'completed_action_id') final  String? completedActionId;
@override final  String? note;
@override@JsonKey(name: 'sync_status') final  SyncStatus syncStatus;

/// Create a copy of HabitLog
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HabitLogCopyWith<_HabitLog> get copyWith => __$HabitLogCopyWithImpl<_HabitLog>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HabitLogToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HabitLog&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.habitId, habitId) || other.habitId == habitId)&&(identical(other.date, date) || other.date == date)&&(identical(other.completedActionId, completedActionId) || other.completedActionId == completedActionId)&&(identical(other.note, note) || other.note == note)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,habitId,date,completedActionId,note,syncStatus);

@override
String toString() {
  return 'HabitLog(id: $id, userId: $userId, habitId: $habitId, date: $date, completedActionId: $completedActionId, note: $note, syncStatus: $syncStatus)';
}


}

/// @nodoc
abstract mixin class _$HabitLogCopyWith<$Res> implements $HabitLogCopyWith<$Res> {
  factory _$HabitLogCopyWith(_HabitLog value, $Res Function(_HabitLog) _then) = __$HabitLogCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'habit_id') String habitId, DateTime date,@JsonKey(name: 'completed_action_id') String? completedActionId, String? note,@JsonKey(name: 'sync_status') SyncStatus syncStatus
});




}
/// @nodoc
class __$HabitLogCopyWithImpl<$Res>
    implements _$HabitLogCopyWith<$Res> {
  __$HabitLogCopyWithImpl(this._self, this._then);

  final _HabitLog _self;
  final $Res Function(_HabitLog) _then;

/// Create a copy of HabitLog
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? habitId = null,Object? date = null,Object? completedActionId = freezed,Object? note = freezed,Object? syncStatus = null,}) {
  return _then(_HabitLog(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,habitId: null == habitId ? _self.habitId : habitId // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,completedActionId: freezed == completedActionId ? _self.completedActionId : completedActionId // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as SyncStatus,
  ));
}


}

// dart format on
