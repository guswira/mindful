// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'money_advice.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MoneyAdvice {

 String get summary; List<String> get spendingInsights; List<String> get savingTips;
/// Create a copy of MoneyAdvice
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MoneyAdviceCopyWith<MoneyAdvice> get copyWith => _$MoneyAdviceCopyWithImpl<MoneyAdvice>(this as MoneyAdvice, _$identity);

  /// Serializes this MoneyAdvice to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MoneyAdvice&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other.spendingInsights, spendingInsights)&&const DeepCollectionEquality().equals(other.savingTips, savingTips));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,summary,const DeepCollectionEquality().hash(spendingInsights),const DeepCollectionEquality().hash(savingTips));

@override
String toString() {
  return 'MoneyAdvice(summary: $summary, spendingInsights: $spendingInsights, savingTips: $savingTips)';
}


}

/// @nodoc
abstract mixin class $MoneyAdviceCopyWith<$Res>  {
  factory $MoneyAdviceCopyWith(MoneyAdvice value, $Res Function(MoneyAdvice) _then) = _$MoneyAdviceCopyWithImpl;
@useResult
$Res call({
 String summary, List<String> spendingInsights, List<String> savingTips
});




}
/// @nodoc
class _$MoneyAdviceCopyWithImpl<$Res>
    implements $MoneyAdviceCopyWith<$Res> {
  _$MoneyAdviceCopyWithImpl(this._self, this._then);

  final MoneyAdvice _self;
  final $Res Function(MoneyAdvice) _then;

/// Create a copy of MoneyAdvice
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? summary = null,Object? spendingInsights = null,Object? savingTips = null,}) {
  return _then(_self.copyWith(
summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,spendingInsights: null == spendingInsights ? _self.spendingInsights : spendingInsights // ignore: cast_nullable_to_non_nullable
as List<String>,savingTips: null == savingTips ? _self.savingTips : savingTips // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [MoneyAdvice].
extension MoneyAdvicePatterns on MoneyAdvice {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MoneyAdvice value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MoneyAdvice() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MoneyAdvice value)  $default,){
final _that = this;
switch (_that) {
case _MoneyAdvice():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MoneyAdvice value)?  $default,){
final _that = this;
switch (_that) {
case _MoneyAdvice() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String summary,  List<String> spendingInsights,  List<String> savingTips)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MoneyAdvice() when $default != null:
return $default(_that.summary,_that.spendingInsights,_that.savingTips);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String summary,  List<String> spendingInsights,  List<String> savingTips)  $default,) {final _that = this;
switch (_that) {
case _MoneyAdvice():
return $default(_that.summary,_that.spendingInsights,_that.savingTips);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String summary,  List<String> spendingInsights,  List<String> savingTips)?  $default,) {final _that = this;
switch (_that) {
case _MoneyAdvice() when $default != null:
return $default(_that.summary,_that.spendingInsights,_that.savingTips);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MoneyAdvice implements MoneyAdvice {
  const _MoneyAdvice({required this.summary, final  List<String> spendingInsights = const [], final  List<String> savingTips = const []}): _spendingInsights = spendingInsights,_savingTips = savingTips;
  factory _MoneyAdvice.fromJson(Map<String, dynamic> json) => _$MoneyAdviceFromJson(json);

@override final  String summary;
 final  List<String> _spendingInsights;
@override@JsonKey() List<String> get spendingInsights {
  if (_spendingInsights is EqualUnmodifiableListView) return _spendingInsights;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_spendingInsights);
}

 final  List<String> _savingTips;
@override@JsonKey() List<String> get savingTips {
  if (_savingTips is EqualUnmodifiableListView) return _savingTips;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_savingTips);
}


/// Create a copy of MoneyAdvice
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MoneyAdviceCopyWith<_MoneyAdvice> get copyWith => __$MoneyAdviceCopyWithImpl<_MoneyAdvice>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MoneyAdviceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MoneyAdvice&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other._spendingInsights, _spendingInsights)&&const DeepCollectionEquality().equals(other._savingTips, _savingTips));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,summary,const DeepCollectionEquality().hash(_spendingInsights),const DeepCollectionEquality().hash(_savingTips));

@override
String toString() {
  return 'MoneyAdvice(summary: $summary, spendingInsights: $spendingInsights, savingTips: $savingTips)';
}


}

/// @nodoc
abstract mixin class _$MoneyAdviceCopyWith<$Res> implements $MoneyAdviceCopyWith<$Res> {
  factory _$MoneyAdviceCopyWith(_MoneyAdvice value, $Res Function(_MoneyAdvice) _then) = __$MoneyAdviceCopyWithImpl;
@override @useResult
$Res call({
 String summary, List<String> spendingInsights, List<String> savingTips
});




}
/// @nodoc
class __$MoneyAdviceCopyWithImpl<$Res>
    implements _$MoneyAdviceCopyWith<$Res> {
  __$MoneyAdviceCopyWithImpl(this._self, this._then);

  final _MoneyAdvice _self;
  final $Res Function(_MoneyAdvice) _then;

/// Create a copy of MoneyAdvice
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? summary = null,Object? spendingInsights = null,Object? savingTips = null,}) {
  return _then(_MoneyAdvice(
summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,spendingInsights: null == spendingInsights ? _self._spendingInsights : spendingInsights // ignore: cast_nullable_to_non_nullable
as List<String>,savingTips: null == savingTips ? _self._savingTips : savingTips // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
