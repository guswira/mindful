// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'habit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Habit {

 String get id;@JsonKey(name: 'user_id') String get userId; String get name; String get icon; String get color;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'reminder_days') List<int> get reminderDays;@JsonKey(name: 'reminder_time')@TimeOfDayConverter() TimeOfDay? get reminderTime; List<HabitAction> get actions; bool get archived;
/// Create a copy of Habit
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HabitCopyWith<Habit> get copyWith => _$HabitCopyWithImpl<Habit>(this as Habit, _$identity);

  /// Serializes this Habit to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Habit&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other.reminderDays, reminderDays)&&(identical(other.reminderTime, reminderTime) || other.reminderTime == reminderTime)&&const DeepCollectionEquality().equals(other.actions, actions)&&(identical(other.archived, archived) || other.archived == archived));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,name,icon,color,createdAt,const DeepCollectionEquality().hash(reminderDays),reminderTime,const DeepCollectionEquality().hash(actions),archived);

@override
String toString() {
  return 'Habit(id: $id, userId: $userId, name: $name, icon: $icon, color: $color, createdAt: $createdAt, reminderDays: $reminderDays, reminderTime: $reminderTime, actions: $actions, archived: $archived)';
}


}

/// @nodoc
abstract mixin class $HabitCopyWith<$Res>  {
  factory $HabitCopyWith(Habit value, $Res Function(Habit) _then) = _$HabitCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId, String name, String icon, String color,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'reminder_days') List<int> reminderDays,@JsonKey(name: 'reminder_time')@TimeOfDayConverter() TimeOfDay? reminderTime, List<HabitAction> actions, bool archived
});




}
/// @nodoc
class _$HabitCopyWithImpl<$Res>
    implements $HabitCopyWith<$Res> {
  _$HabitCopyWithImpl(this._self, this._then);

  final Habit _self;
  final $Res Function(Habit) _then;

/// Create a copy of Habit
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? name = null,Object? icon = null,Object? color = null,Object? createdAt = null,Object? reminderDays = null,Object? reminderTime = freezed,Object? actions = null,Object? archived = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,reminderDays: null == reminderDays ? _self.reminderDays : reminderDays // ignore: cast_nullable_to_non_nullable
as List<int>,reminderTime: freezed == reminderTime ? _self.reminderTime : reminderTime // ignore: cast_nullable_to_non_nullable
as TimeOfDay?,actions: null == actions ? _self.actions : actions // ignore: cast_nullable_to_non_nullable
as List<HabitAction>,archived: null == archived ? _self.archived : archived // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Habit].
extension HabitPatterns on Habit {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Habit value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Habit() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Habit value)  $default,){
final _that = this;
switch (_that) {
case _Habit():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Habit value)?  $default,){
final _that = this;
switch (_that) {
case _Habit() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId,  String name,  String icon,  String color, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'reminder_days')  List<int> reminderDays, @JsonKey(name: 'reminder_time')@TimeOfDayConverter()  TimeOfDay? reminderTime,  List<HabitAction> actions,  bool archived)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Habit() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.icon,_that.color,_that.createdAt,_that.reminderDays,_that.reminderTime,_that.actions,_that.archived);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId,  String name,  String icon,  String color, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'reminder_days')  List<int> reminderDays, @JsonKey(name: 'reminder_time')@TimeOfDayConverter()  TimeOfDay? reminderTime,  List<HabitAction> actions,  bool archived)  $default,) {final _that = this;
switch (_that) {
case _Habit():
return $default(_that.id,_that.userId,_that.name,_that.icon,_that.color,_that.createdAt,_that.reminderDays,_that.reminderTime,_that.actions,_that.archived);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'user_id')  String userId,  String name,  String icon,  String color, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'reminder_days')  List<int> reminderDays, @JsonKey(name: 'reminder_time')@TimeOfDayConverter()  TimeOfDay? reminderTime,  List<HabitAction> actions,  bool archived)?  $default,) {final _that = this;
switch (_that) {
case _Habit() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.icon,_that.color,_that.createdAt,_that.reminderDays,_that.reminderTime,_that.actions,_that.archived);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Habit implements Habit {
  const _Habit({required this.id, @JsonKey(name: 'user_id') required this.userId, required this.name, required this.icon, required this.color, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'reminder_days') final  List<int> reminderDays = const <int>[], @JsonKey(name: 'reminder_time')@TimeOfDayConverter() this.reminderTime, final  List<HabitAction> actions = const <HabitAction>[], this.archived = false}): _reminderDays = reminderDays,_actions = actions;
  factory _Habit.fromJson(Map<String, dynamic> json) => _$HabitFromJson(json);

@override final  String id;
@override@JsonKey(name: 'user_id') final  String userId;
@override final  String name;
@override final  String icon;
@override final  String color;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
 final  List<int> _reminderDays;
@override@JsonKey(name: 'reminder_days') List<int> get reminderDays {
  if (_reminderDays is EqualUnmodifiableListView) return _reminderDays;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_reminderDays);
}

@override@JsonKey(name: 'reminder_time')@TimeOfDayConverter() final  TimeOfDay? reminderTime;
 final  List<HabitAction> _actions;
@override@JsonKey() List<HabitAction> get actions {
  if (_actions is EqualUnmodifiableListView) return _actions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_actions);
}

@override@JsonKey() final  bool archived;

/// Create a copy of Habit
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HabitCopyWith<_Habit> get copyWith => __$HabitCopyWithImpl<_Habit>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HabitToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Habit&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other._reminderDays, _reminderDays)&&(identical(other.reminderTime, reminderTime) || other.reminderTime == reminderTime)&&const DeepCollectionEquality().equals(other._actions, _actions)&&(identical(other.archived, archived) || other.archived == archived));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,name,icon,color,createdAt,const DeepCollectionEquality().hash(_reminderDays),reminderTime,const DeepCollectionEquality().hash(_actions),archived);

@override
String toString() {
  return 'Habit(id: $id, userId: $userId, name: $name, icon: $icon, color: $color, createdAt: $createdAt, reminderDays: $reminderDays, reminderTime: $reminderTime, actions: $actions, archived: $archived)';
}


}

/// @nodoc
abstract mixin class _$HabitCopyWith<$Res> implements $HabitCopyWith<$Res> {
  factory _$HabitCopyWith(_Habit value, $Res Function(_Habit) _then) = __$HabitCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId, String name, String icon, String color,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'reminder_days') List<int> reminderDays,@JsonKey(name: 'reminder_time')@TimeOfDayConverter() TimeOfDay? reminderTime, List<HabitAction> actions, bool archived
});




}
/// @nodoc
class __$HabitCopyWithImpl<$Res>
    implements _$HabitCopyWith<$Res> {
  __$HabitCopyWithImpl(this._self, this._then);

  final _Habit _self;
  final $Res Function(_Habit) _then;

/// Create a copy of Habit
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? name = null,Object? icon = null,Object? color = null,Object? createdAt = null,Object? reminderDays = null,Object? reminderTime = freezed,Object? actions = null,Object? archived = null,}) {
  return _then(_Habit(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,reminderDays: null == reminderDays ? _self._reminderDays : reminderDays // ignore: cast_nullable_to_non_nullable
as List<int>,reminderTime: freezed == reminderTime ? _self.reminderTime : reminderTime // ignore: cast_nullable_to_non_nullable
as TimeOfDay?,actions: null == actions ? _self._actions : actions // ignore: cast_nullable_to_non_nullable
as List<HabitAction>,archived: null == archived ? _self.archived : archived // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
