// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'breathing_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BreathingSession {

 String get id;@JsonKey(name: 'user_id') String get userId; BreathingExercise get exercise;/// UTC — convert with `toLocal()` before grouping by day.
@JsonKey(name: 'started_at') DateTime get startedAt;@JsonKey(name: 'duration_seconds') int get durationSeconds; int get cycles;@JsonKey(name: 'created_at') DateTime get createdAt;/// Longest hold, for the Breath Holding Test only.
@JsonKey(name: 'best_hold_seconds') int? get bestHoldSeconds;@JsonKey(name: 'sync_status') SyncStatus get syncStatus;
/// Create a copy of BreathingSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BreathingSessionCopyWith<BreathingSession> get copyWith => _$BreathingSessionCopyWithImpl<BreathingSession>(this as BreathingSession, _$identity);

  /// Serializes this BreathingSession to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BreathingSession&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.exercise, exercise) || other.exercise == exercise)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.cycles, cycles) || other.cycles == cycles)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.bestHoldSeconds, bestHoldSeconds) || other.bestHoldSeconds == bestHoldSeconds)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,exercise,startedAt,durationSeconds,cycles,createdAt,bestHoldSeconds,syncStatus);

@override
String toString() {
  return 'BreathingSession(id: $id, userId: $userId, exercise: $exercise, startedAt: $startedAt, durationSeconds: $durationSeconds, cycles: $cycles, createdAt: $createdAt, bestHoldSeconds: $bestHoldSeconds, syncStatus: $syncStatus)';
}


}

/// @nodoc
abstract mixin class $BreathingSessionCopyWith<$Res>  {
  factory $BreathingSessionCopyWith(BreathingSession value, $Res Function(BreathingSession) _then) = _$BreathingSessionCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId, BreathingExercise exercise,@JsonKey(name: 'started_at') DateTime startedAt,@JsonKey(name: 'duration_seconds') int durationSeconds, int cycles,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'best_hold_seconds') int? bestHoldSeconds,@JsonKey(name: 'sync_status') SyncStatus syncStatus
});




}
/// @nodoc
class _$BreathingSessionCopyWithImpl<$Res>
    implements $BreathingSessionCopyWith<$Res> {
  _$BreathingSessionCopyWithImpl(this._self, this._then);

  final BreathingSession _self;
  final $Res Function(BreathingSession) _then;

/// Create a copy of BreathingSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? exercise = null,Object? startedAt = null,Object? durationSeconds = null,Object? cycles = null,Object? createdAt = null,Object? bestHoldSeconds = freezed,Object? syncStatus = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,exercise: null == exercise ? _self.exercise : exercise // ignore: cast_nullable_to_non_nullable
as BreathingExercise,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,durationSeconds: null == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int,cycles: null == cycles ? _self.cycles : cycles // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,bestHoldSeconds: freezed == bestHoldSeconds ? _self.bestHoldSeconds : bestHoldSeconds // ignore: cast_nullable_to_non_nullable
as int?,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as SyncStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [BreathingSession].
extension BreathingSessionPatterns on BreathingSession {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BreathingSession value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BreathingSession() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BreathingSession value)  $default,){
final _that = this;
switch (_that) {
case _BreathingSession():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BreathingSession value)?  $default,){
final _that = this;
switch (_that) {
case _BreathingSession() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId,  BreathingExercise exercise, @JsonKey(name: 'started_at')  DateTime startedAt, @JsonKey(name: 'duration_seconds')  int durationSeconds,  int cycles, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'best_hold_seconds')  int? bestHoldSeconds, @JsonKey(name: 'sync_status')  SyncStatus syncStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BreathingSession() when $default != null:
return $default(_that.id,_that.userId,_that.exercise,_that.startedAt,_that.durationSeconds,_that.cycles,_that.createdAt,_that.bestHoldSeconds,_that.syncStatus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId,  BreathingExercise exercise, @JsonKey(name: 'started_at')  DateTime startedAt, @JsonKey(name: 'duration_seconds')  int durationSeconds,  int cycles, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'best_hold_seconds')  int? bestHoldSeconds, @JsonKey(name: 'sync_status')  SyncStatus syncStatus)  $default,) {final _that = this;
switch (_that) {
case _BreathingSession():
return $default(_that.id,_that.userId,_that.exercise,_that.startedAt,_that.durationSeconds,_that.cycles,_that.createdAt,_that.bestHoldSeconds,_that.syncStatus);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'user_id')  String userId,  BreathingExercise exercise, @JsonKey(name: 'started_at')  DateTime startedAt, @JsonKey(name: 'duration_seconds')  int durationSeconds,  int cycles, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'best_hold_seconds')  int? bestHoldSeconds, @JsonKey(name: 'sync_status')  SyncStatus syncStatus)?  $default,) {final _that = this;
switch (_that) {
case _BreathingSession() when $default != null:
return $default(_that.id,_that.userId,_that.exercise,_that.startedAt,_that.durationSeconds,_that.cycles,_that.createdAt,_that.bestHoldSeconds,_that.syncStatus);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BreathingSession implements BreathingSession {
  const _BreathingSession({required this.id, @JsonKey(name: 'user_id') required this.userId, required this.exercise, @JsonKey(name: 'started_at') required this.startedAt, @JsonKey(name: 'duration_seconds') required this.durationSeconds, required this.cycles, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'best_hold_seconds') this.bestHoldSeconds, @JsonKey(name: 'sync_status') this.syncStatus = SyncStatus.synced});
  factory _BreathingSession.fromJson(Map<String, dynamic> json) => _$BreathingSessionFromJson(json);

@override final  String id;
@override@JsonKey(name: 'user_id') final  String userId;
@override final  BreathingExercise exercise;
/// UTC — convert with `toLocal()` before grouping by day.
@override@JsonKey(name: 'started_at') final  DateTime startedAt;
@override@JsonKey(name: 'duration_seconds') final  int durationSeconds;
@override final  int cycles;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
/// Longest hold, for the Breath Holding Test only.
@override@JsonKey(name: 'best_hold_seconds') final  int? bestHoldSeconds;
@override@JsonKey(name: 'sync_status') final  SyncStatus syncStatus;

/// Create a copy of BreathingSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BreathingSessionCopyWith<_BreathingSession> get copyWith => __$BreathingSessionCopyWithImpl<_BreathingSession>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BreathingSessionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BreathingSession&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.exercise, exercise) || other.exercise == exercise)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.cycles, cycles) || other.cycles == cycles)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.bestHoldSeconds, bestHoldSeconds) || other.bestHoldSeconds == bestHoldSeconds)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,exercise,startedAt,durationSeconds,cycles,createdAt,bestHoldSeconds,syncStatus);

@override
String toString() {
  return 'BreathingSession(id: $id, userId: $userId, exercise: $exercise, startedAt: $startedAt, durationSeconds: $durationSeconds, cycles: $cycles, createdAt: $createdAt, bestHoldSeconds: $bestHoldSeconds, syncStatus: $syncStatus)';
}


}

/// @nodoc
abstract mixin class _$BreathingSessionCopyWith<$Res> implements $BreathingSessionCopyWith<$Res> {
  factory _$BreathingSessionCopyWith(_BreathingSession value, $Res Function(_BreathingSession) _then) = __$BreathingSessionCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId, BreathingExercise exercise,@JsonKey(name: 'started_at') DateTime startedAt,@JsonKey(name: 'duration_seconds') int durationSeconds, int cycles,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'best_hold_seconds') int? bestHoldSeconds,@JsonKey(name: 'sync_status') SyncStatus syncStatus
});




}
/// @nodoc
class __$BreathingSessionCopyWithImpl<$Res>
    implements _$BreathingSessionCopyWith<$Res> {
  __$BreathingSessionCopyWithImpl(this._self, this._then);

  final _BreathingSession _self;
  final $Res Function(_BreathingSession) _then;

/// Create a copy of BreathingSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? exercise = null,Object? startedAt = null,Object? durationSeconds = null,Object? cycles = null,Object? createdAt = null,Object? bestHoldSeconds = freezed,Object? syncStatus = null,}) {
  return _then(_BreathingSession(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,exercise: null == exercise ? _self.exercise : exercise // ignore: cast_nullable_to_non_nullable
as BreathingExercise,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,durationSeconds: null == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int,cycles: null == cycles ? _self.cycles : cycles // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,bestHoldSeconds: freezed == bestHoldSeconds ? _self.bestHoldSeconds : bestHoldSeconds // ignore: cast_nullable_to_non_nullable
as int?,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as SyncStatus,
  ));
}


}

// dart format on
