// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'breathing_preferences.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BreathingPreferences {

 bool get voiceEnabled; double get voiceVolume; AmbienceTrack get ambience; double get ambienceVolume; CustomBreathing get custom;
/// Create a copy of BreathingPreferences
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BreathingPreferencesCopyWith<BreathingPreferences> get copyWith => _$BreathingPreferencesCopyWithImpl<BreathingPreferences>(this as BreathingPreferences, _$identity);

  /// Serializes this BreathingPreferences to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BreathingPreferences&&(identical(other.voiceEnabled, voiceEnabled) || other.voiceEnabled == voiceEnabled)&&(identical(other.voiceVolume, voiceVolume) || other.voiceVolume == voiceVolume)&&(identical(other.ambience, ambience) || other.ambience == ambience)&&(identical(other.ambienceVolume, ambienceVolume) || other.ambienceVolume == ambienceVolume)&&(identical(other.custom, custom) || other.custom == custom));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,voiceEnabled,voiceVolume,ambience,ambienceVolume,custom);

@override
String toString() {
  return 'BreathingPreferences(voiceEnabled: $voiceEnabled, voiceVolume: $voiceVolume, ambience: $ambience, ambienceVolume: $ambienceVolume, custom: $custom)';
}


}

/// @nodoc
abstract mixin class $BreathingPreferencesCopyWith<$Res>  {
  factory $BreathingPreferencesCopyWith(BreathingPreferences value, $Res Function(BreathingPreferences) _then) = _$BreathingPreferencesCopyWithImpl;
@useResult
$Res call({
 bool voiceEnabled, double voiceVolume, AmbienceTrack ambience, double ambienceVolume, CustomBreathing custom
});


$CustomBreathingCopyWith<$Res> get custom;

}
/// @nodoc
class _$BreathingPreferencesCopyWithImpl<$Res>
    implements $BreathingPreferencesCopyWith<$Res> {
  _$BreathingPreferencesCopyWithImpl(this._self, this._then);

  final BreathingPreferences _self;
  final $Res Function(BreathingPreferences) _then;

/// Create a copy of BreathingPreferences
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? voiceEnabled = null,Object? voiceVolume = null,Object? ambience = null,Object? ambienceVolume = null,Object? custom = null,}) {
  return _then(_self.copyWith(
voiceEnabled: null == voiceEnabled ? _self.voiceEnabled : voiceEnabled // ignore: cast_nullable_to_non_nullable
as bool,voiceVolume: null == voiceVolume ? _self.voiceVolume : voiceVolume // ignore: cast_nullable_to_non_nullable
as double,ambience: null == ambience ? _self.ambience : ambience // ignore: cast_nullable_to_non_nullable
as AmbienceTrack,ambienceVolume: null == ambienceVolume ? _self.ambienceVolume : ambienceVolume // ignore: cast_nullable_to_non_nullable
as double,custom: null == custom ? _self.custom : custom // ignore: cast_nullable_to_non_nullable
as CustomBreathing,
  ));
}
/// Create a copy of BreathingPreferences
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CustomBreathingCopyWith<$Res> get custom {
  
  return $CustomBreathingCopyWith<$Res>(_self.custom, (value) {
    return _then(_self.copyWith(custom: value));
  });
}
}


/// Adds pattern-matching-related methods to [BreathingPreferences].
extension BreathingPreferencesPatterns on BreathingPreferences {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BreathingPreferences value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BreathingPreferences() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BreathingPreferences value)  $default,){
final _that = this;
switch (_that) {
case _BreathingPreferences():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BreathingPreferences value)?  $default,){
final _that = this;
switch (_that) {
case _BreathingPreferences() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool voiceEnabled,  double voiceVolume,  AmbienceTrack ambience,  double ambienceVolume,  CustomBreathing custom)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BreathingPreferences() when $default != null:
return $default(_that.voiceEnabled,_that.voiceVolume,_that.ambience,_that.ambienceVolume,_that.custom);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool voiceEnabled,  double voiceVolume,  AmbienceTrack ambience,  double ambienceVolume,  CustomBreathing custom)  $default,) {final _that = this;
switch (_that) {
case _BreathingPreferences():
return $default(_that.voiceEnabled,_that.voiceVolume,_that.ambience,_that.ambienceVolume,_that.custom);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool voiceEnabled,  double voiceVolume,  AmbienceTrack ambience,  double ambienceVolume,  CustomBreathing custom)?  $default,) {final _that = this;
switch (_that) {
case _BreathingPreferences() when $default != null:
return $default(_that.voiceEnabled,_that.voiceVolume,_that.ambience,_that.ambienceVolume,_that.custom);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BreathingPreferences implements BreathingPreferences {
  const _BreathingPreferences({this.voiceEnabled = true, this.voiceVolume = 0.8, this.ambience = AmbienceTrack.rain, this.ambienceVolume = 0.5, this.custom = const CustomBreathing()});
  factory _BreathingPreferences.fromJson(Map<String, dynamic> json) => _$BreathingPreferencesFromJson(json);

@override@JsonKey() final  bool voiceEnabled;
@override@JsonKey() final  double voiceVolume;
@override@JsonKey() final  AmbienceTrack ambience;
@override@JsonKey() final  double ambienceVolume;
@override@JsonKey() final  CustomBreathing custom;

/// Create a copy of BreathingPreferences
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BreathingPreferencesCopyWith<_BreathingPreferences> get copyWith => __$BreathingPreferencesCopyWithImpl<_BreathingPreferences>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BreathingPreferencesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BreathingPreferences&&(identical(other.voiceEnabled, voiceEnabled) || other.voiceEnabled == voiceEnabled)&&(identical(other.voiceVolume, voiceVolume) || other.voiceVolume == voiceVolume)&&(identical(other.ambience, ambience) || other.ambience == ambience)&&(identical(other.ambienceVolume, ambienceVolume) || other.ambienceVolume == ambienceVolume)&&(identical(other.custom, custom) || other.custom == custom));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,voiceEnabled,voiceVolume,ambience,ambienceVolume,custom);

@override
String toString() {
  return 'BreathingPreferences(voiceEnabled: $voiceEnabled, voiceVolume: $voiceVolume, ambience: $ambience, ambienceVolume: $ambienceVolume, custom: $custom)';
}


}

/// @nodoc
abstract mixin class _$BreathingPreferencesCopyWith<$Res> implements $BreathingPreferencesCopyWith<$Res> {
  factory _$BreathingPreferencesCopyWith(_BreathingPreferences value, $Res Function(_BreathingPreferences) _then) = __$BreathingPreferencesCopyWithImpl;
@override @useResult
$Res call({
 bool voiceEnabled, double voiceVolume, AmbienceTrack ambience, double ambienceVolume, CustomBreathing custom
});


@override $CustomBreathingCopyWith<$Res> get custom;

}
/// @nodoc
class __$BreathingPreferencesCopyWithImpl<$Res>
    implements _$BreathingPreferencesCopyWith<$Res> {
  __$BreathingPreferencesCopyWithImpl(this._self, this._then);

  final _BreathingPreferences _self;
  final $Res Function(_BreathingPreferences) _then;

/// Create a copy of BreathingPreferences
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? voiceEnabled = null,Object? voiceVolume = null,Object? ambience = null,Object? ambienceVolume = null,Object? custom = null,}) {
  return _then(_BreathingPreferences(
voiceEnabled: null == voiceEnabled ? _self.voiceEnabled : voiceEnabled // ignore: cast_nullable_to_non_nullable
as bool,voiceVolume: null == voiceVolume ? _self.voiceVolume : voiceVolume // ignore: cast_nullable_to_non_nullable
as double,ambience: null == ambience ? _self.ambience : ambience // ignore: cast_nullable_to_non_nullable
as AmbienceTrack,ambienceVolume: null == ambienceVolume ? _self.ambienceVolume : ambienceVolume // ignore: cast_nullable_to_non_nullable
as double,custom: null == custom ? _self.custom : custom // ignore: cast_nullable_to_non_nullable
as CustomBreathing,
  ));
}

/// Create a copy of BreathingPreferences
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CustomBreathingCopyWith<$Res> get custom {
  
  return $CustomBreathingCopyWith<$Res>(_self.custom, (value) {
    return _then(_self.copyWith(custom: value));
  });
}
}


/// @nodoc
mixin _$CustomBreathing {

 int get inhale; int get hold; int get exhale; int get holdAfter;
/// Create a copy of CustomBreathing
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CustomBreathingCopyWith<CustomBreathing> get copyWith => _$CustomBreathingCopyWithImpl<CustomBreathing>(this as CustomBreathing, _$identity);

  /// Serializes this CustomBreathing to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CustomBreathing&&(identical(other.inhale, inhale) || other.inhale == inhale)&&(identical(other.hold, hold) || other.hold == hold)&&(identical(other.exhale, exhale) || other.exhale == exhale)&&(identical(other.holdAfter, holdAfter) || other.holdAfter == holdAfter));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,inhale,hold,exhale,holdAfter);

@override
String toString() {
  return 'CustomBreathing(inhale: $inhale, hold: $hold, exhale: $exhale, holdAfter: $holdAfter)';
}


}

/// @nodoc
abstract mixin class $CustomBreathingCopyWith<$Res>  {
  factory $CustomBreathingCopyWith(CustomBreathing value, $Res Function(CustomBreathing) _then) = _$CustomBreathingCopyWithImpl;
@useResult
$Res call({
 int inhale, int hold, int exhale, int holdAfter
});




}
/// @nodoc
class _$CustomBreathingCopyWithImpl<$Res>
    implements $CustomBreathingCopyWith<$Res> {
  _$CustomBreathingCopyWithImpl(this._self, this._then);

  final CustomBreathing _self;
  final $Res Function(CustomBreathing) _then;

/// Create a copy of CustomBreathing
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? inhale = null,Object? hold = null,Object? exhale = null,Object? holdAfter = null,}) {
  return _then(_self.copyWith(
inhale: null == inhale ? _self.inhale : inhale // ignore: cast_nullable_to_non_nullable
as int,hold: null == hold ? _self.hold : hold // ignore: cast_nullable_to_non_nullable
as int,exhale: null == exhale ? _self.exhale : exhale // ignore: cast_nullable_to_non_nullable
as int,holdAfter: null == holdAfter ? _self.holdAfter : holdAfter // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CustomBreathing].
extension CustomBreathingPatterns on CustomBreathing {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CustomBreathing value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CustomBreathing() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CustomBreathing value)  $default,){
final _that = this;
switch (_that) {
case _CustomBreathing():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CustomBreathing value)?  $default,){
final _that = this;
switch (_that) {
case _CustomBreathing() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int inhale,  int hold,  int exhale,  int holdAfter)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CustomBreathing() when $default != null:
return $default(_that.inhale,_that.hold,_that.exhale,_that.holdAfter);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int inhale,  int hold,  int exhale,  int holdAfter)  $default,) {final _that = this;
switch (_that) {
case _CustomBreathing():
return $default(_that.inhale,_that.hold,_that.exhale,_that.holdAfter);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int inhale,  int hold,  int exhale,  int holdAfter)?  $default,) {final _that = this;
switch (_that) {
case _CustomBreathing() when $default != null:
return $default(_that.inhale,_that.hold,_that.exhale,_that.holdAfter);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CustomBreathing implements CustomBreathing {
  const _CustomBreathing({this.inhale = 4, this.hold = 2, this.exhale = 6, this.holdAfter = 0});
  factory _CustomBreathing.fromJson(Map<String, dynamic> json) => _$CustomBreathingFromJson(json);

@override@JsonKey() final  int inhale;
@override@JsonKey() final  int hold;
@override@JsonKey() final  int exhale;
@override@JsonKey() final  int holdAfter;

/// Create a copy of CustomBreathing
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CustomBreathingCopyWith<_CustomBreathing> get copyWith => __$CustomBreathingCopyWithImpl<_CustomBreathing>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CustomBreathingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CustomBreathing&&(identical(other.inhale, inhale) || other.inhale == inhale)&&(identical(other.hold, hold) || other.hold == hold)&&(identical(other.exhale, exhale) || other.exhale == exhale)&&(identical(other.holdAfter, holdAfter) || other.holdAfter == holdAfter));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,inhale,hold,exhale,holdAfter);

@override
String toString() {
  return 'CustomBreathing(inhale: $inhale, hold: $hold, exhale: $exhale, holdAfter: $holdAfter)';
}


}

/// @nodoc
abstract mixin class _$CustomBreathingCopyWith<$Res> implements $CustomBreathingCopyWith<$Res> {
  factory _$CustomBreathingCopyWith(_CustomBreathing value, $Res Function(_CustomBreathing) _then) = __$CustomBreathingCopyWithImpl;
@override @useResult
$Res call({
 int inhale, int hold, int exhale, int holdAfter
});




}
/// @nodoc
class __$CustomBreathingCopyWithImpl<$Res>
    implements _$CustomBreathingCopyWith<$Res> {
  __$CustomBreathingCopyWithImpl(this._self, this._then);

  final _CustomBreathing _self;
  final $Res Function(_CustomBreathing) _then;

/// Create a copy of CustomBreathing
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? inhale = null,Object? hold = null,Object? exhale = null,Object? holdAfter = null,}) {
  return _then(_CustomBreathing(
inhale: null == inhale ? _self.inhale : inhale // ignore: cast_nullable_to_non_nullable
as int,hold: null == hold ? _self.hold : hold // ignore: cast_nullable_to_non_nullable
as int,exhale: null == exhale ? _self.exhale : exhale // ignore: cast_nullable_to_non_nullable
as int,holdAfter: null == holdAfter ? _self.holdAfter : holdAfter // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
