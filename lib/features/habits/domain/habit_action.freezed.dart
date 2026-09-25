// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'habit_action.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HabitAction {

 String get id; String get label; bool get isDefault;
/// Create a copy of HabitAction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HabitActionCopyWith<HabitAction> get copyWith => _$HabitActionCopyWithImpl<HabitAction>(this as HabitAction, _$identity);

  /// Serializes this HabitAction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HabitAction&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,isDefault);

@override
String toString() {
  return 'HabitAction(id: $id, label: $label, isDefault: $isDefault)';
}


}

/// @nodoc
abstract mixin class $HabitActionCopyWith<$Res>  {
  factory $HabitActionCopyWith(HabitAction value, $Res Function(HabitAction) _then) = _$HabitActionCopyWithImpl;
@useResult
$Res call({
 String id, String label, bool isDefault
});




}
/// @nodoc
class _$HabitActionCopyWithImpl<$Res>
    implements $HabitActionCopyWith<$Res> {
  _$HabitActionCopyWithImpl(this._self, this._then);

  final HabitAction _self;
  final $Res Function(HabitAction) _then;

/// Create a copy of HabitAction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = null,Object? isDefault = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [HabitAction].
extension HabitActionPatterns on HabitAction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HabitAction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HabitAction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HabitAction value)  $default,){
final _that = this;
switch (_that) {
case _HabitAction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HabitAction value)?  $default,){
final _that = this;
switch (_that) {
case _HabitAction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String label,  bool isDefault)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HabitAction() when $default != null:
return $default(_that.id,_that.label,_that.isDefault);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String label,  bool isDefault)  $default,) {final _that = this;
switch (_that) {
case _HabitAction():
return $default(_that.id,_that.label,_that.isDefault);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String label,  bool isDefault)?  $default,) {final _that = this;
switch (_that) {
case _HabitAction() when $default != null:
return $default(_that.id,_that.label,_that.isDefault);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HabitAction implements HabitAction {
  const _HabitAction({required this.id, required this.label, this.isDefault = false});
  factory _HabitAction.fromJson(Map<String, dynamic> json) => _$HabitActionFromJson(json);

@override final  String id;
@override final  String label;
@override@JsonKey() final  bool isDefault;

/// Create a copy of HabitAction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HabitActionCopyWith<_HabitAction> get copyWith => __$HabitActionCopyWithImpl<_HabitAction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HabitActionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HabitAction&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,isDefault);

@override
String toString() {
  return 'HabitAction(id: $id, label: $label, isDefault: $isDefault)';
}


}

/// @nodoc
abstract mixin class _$HabitActionCopyWith<$Res> implements $HabitActionCopyWith<$Res> {
  factory _$HabitActionCopyWith(_HabitAction value, $Res Function(_HabitAction) _then) = __$HabitActionCopyWithImpl;
@override @useResult
$Res call({
 String id, String label, bool isDefault
});




}
/// @nodoc
class __$HabitActionCopyWithImpl<$Res>
    implements _$HabitActionCopyWith<$Res> {
  __$HabitActionCopyWithImpl(this._self, this._then);

  final _HabitAction _self;
  final $Res Function(_HabitAction) _then;

/// Create a copy of HabitAction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = null,Object? isDefault = null,}) {
  return _then(_HabitAction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
