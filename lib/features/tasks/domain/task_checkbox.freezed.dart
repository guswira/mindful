// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_checkbox.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TaskCheckbox {

 String get id; String get label; bool get isChecked;
/// Create a copy of TaskCheckbox
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskCheckboxCopyWith<TaskCheckbox> get copyWith => _$TaskCheckboxCopyWithImpl<TaskCheckbox>(this as TaskCheckbox, _$identity);

  /// Serializes this TaskCheckbox to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskCheckbox&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.isChecked, isChecked) || other.isChecked == isChecked));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,isChecked);

@override
String toString() {
  return 'TaskCheckbox(id: $id, label: $label, isChecked: $isChecked)';
}


}

/// @nodoc
abstract mixin class $TaskCheckboxCopyWith<$Res>  {
  factory $TaskCheckboxCopyWith(TaskCheckbox value, $Res Function(TaskCheckbox) _then) = _$TaskCheckboxCopyWithImpl;
@useResult
$Res call({
 String id, String label, bool isChecked
});




}
/// @nodoc
class _$TaskCheckboxCopyWithImpl<$Res>
    implements $TaskCheckboxCopyWith<$Res> {
  _$TaskCheckboxCopyWithImpl(this._self, this._then);

  final TaskCheckbox _self;
  final $Res Function(TaskCheckbox) _then;

/// Create a copy of TaskCheckbox
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = null,Object? isChecked = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,isChecked: null == isChecked ? _self.isChecked : isChecked // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [TaskCheckbox].
extension TaskCheckboxPatterns on TaskCheckbox {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaskCheckbox value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaskCheckbox() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaskCheckbox value)  $default,){
final _that = this;
switch (_that) {
case _TaskCheckbox():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaskCheckbox value)?  $default,){
final _that = this;
switch (_that) {
case _TaskCheckbox() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String label,  bool isChecked)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaskCheckbox() when $default != null:
return $default(_that.id,_that.label,_that.isChecked);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String label,  bool isChecked)  $default,) {final _that = this;
switch (_that) {
case _TaskCheckbox():
return $default(_that.id,_that.label,_that.isChecked);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String label,  bool isChecked)?  $default,) {final _that = this;
switch (_that) {
case _TaskCheckbox() when $default != null:
return $default(_that.id,_that.label,_that.isChecked);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TaskCheckbox implements TaskCheckbox {
  const _TaskCheckbox({required this.id, required this.label, this.isChecked = false});
  factory _TaskCheckbox.fromJson(Map<String, dynamic> json) => _$TaskCheckboxFromJson(json);

@override final  String id;
@override final  String label;
@override@JsonKey() final  bool isChecked;

/// Create a copy of TaskCheckbox
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskCheckboxCopyWith<_TaskCheckbox> get copyWith => __$TaskCheckboxCopyWithImpl<_TaskCheckbox>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TaskCheckboxToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaskCheckbox&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.isChecked, isChecked) || other.isChecked == isChecked));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,isChecked);

@override
String toString() {
  return 'TaskCheckbox(id: $id, label: $label, isChecked: $isChecked)';
}


}

/// @nodoc
abstract mixin class _$TaskCheckboxCopyWith<$Res> implements $TaskCheckboxCopyWith<$Res> {
  factory _$TaskCheckboxCopyWith(_TaskCheckbox value, $Res Function(_TaskCheckbox) _then) = __$TaskCheckboxCopyWithImpl;
@override @useResult
$Res call({
 String id, String label, bool isChecked
});




}
/// @nodoc
class __$TaskCheckboxCopyWithImpl<$Res>
    implements _$TaskCheckboxCopyWith<$Res> {
  __$TaskCheckboxCopyWithImpl(this._self, this._then);

  final _TaskCheckbox _self;
  final $Res Function(_TaskCheckbox) _then;

/// Create a copy of TaskCheckbox
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = null,Object? isChecked = null,}) {
  return _then(_TaskCheckbox(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,isChecked: null == isChecked ? _self.isChecked : isChecked // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
