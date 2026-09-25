// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'food_scan.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FoodScan {

 String get id;@JsonKey(name: 'user_id') String get userId;@JsonKey(name: 'scanned_at') DateTime get scannedAt;@JsonKey(name: 'food_name') String? get foodName; int? get calories; double? get protein; double? get carbs; double? get fat; double? get fiber; String? get confidence; String? get note;
/// Create a copy of FoodScan
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FoodScanCopyWith<FoodScan> get copyWith => _$FoodScanCopyWithImpl<FoodScan>(this as FoodScan, _$identity);

  /// Serializes this FoodScan to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FoodScan&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.scannedAt, scannedAt) || other.scannedAt == scannedAt)&&(identical(other.foodName, foodName) || other.foodName == foodName)&&(identical(other.calories, calories) || other.calories == calories)&&(identical(other.protein, protein) || other.protein == protein)&&(identical(other.carbs, carbs) || other.carbs == carbs)&&(identical(other.fat, fat) || other.fat == fat)&&(identical(other.fiber, fiber) || other.fiber == fiber)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,scannedAt,foodName,calories,protein,carbs,fat,fiber,confidence,note);

@override
String toString() {
  return 'FoodScan(id: $id, userId: $userId, scannedAt: $scannedAt, foodName: $foodName, calories: $calories, protein: $protein, carbs: $carbs, fat: $fat, fiber: $fiber, confidence: $confidence, note: $note)';
}


}

/// @nodoc
abstract mixin class $FoodScanCopyWith<$Res>  {
  factory $FoodScanCopyWith(FoodScan value, $Res Function(FoodScan) _then) = _$FoodScanCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'scanned_at') DateTime scannedAt,@JsonKey(name: 'food_name') String? foodName, int? calories, double? protein, double? carbs, double? fat, double? fiber, String? confidence, String? note
});




}
/// @nodoc
class _$FoodScanCopyWithImpl<$Res>
    implements $FoodScanCopyWith<$Res> {
  _$FoodScanCopyWithImpl(this._self, this._then);

  final FoodScan _self;
  final $Res Function(FoodScan) _then;

/// Create a copy of FoodScan
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? scannedAt = null,Object? foodName = freezed,Object? calories = freezed,Object? protein = freezed,Object? carbs = freezed,Object? fat = freezed,Object? fiber = freezed,Object? confidence = freezed,Object? note = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,scannedAt: null == scannedAt ? _self.scannedAt : scannedAt // ignore: cast_nullable_to_non_nullable
as DateTime,foodName: freezed == foodName ? _self.foodName : foodName // ignore: cast_nullable_to_non_nullable
as String?,calories: freezed == calories ? _self.calories : calories // ignore: cast_nullable_to_non_nullable
as int?,protein: freezed == protein ? _self.protein : protein // ignore: cast_nullable_to_non_nullable
as double?,carbs: freezed == carbs ? _self.carbs : carbs // ignore: cast_nullable_to_non_nullable
as double?,fat: freezed == fat ? _self.fat : fat // ignore: cast_nullable_to_non_nullable
as double?,fiber: freezed == fiber ? _self.fiber : fiber // ignore: cast_nullable_to_non_nullable
as double?,confidence: freezed == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [FoodScan].
extension FoodScanPatterns on FoodScan {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FoodScan value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FoodScan() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FoodScan value)  $default,){
final _that = this;
switch (_that) {
case _FoodScan():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FoodScan value)?  $default,){
final _that = this;
switch (_that) {
case _FoodScan() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'scanned_at')  DateTime scannedAt, @JsonKey(name: 'food_name')  String? foodName,  int? calories,  double? protein,  double? carbs,  double? fat,  double? fiber,  String? confidence,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FoodScan() when $default != null:
return $default(_that.id,_that.userId,_that.scannedAt,_that.foodName,_that.calories,_that.protein,_that.carbs,_that.fat,_that.fiber,_that.confidence,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'scanned_at')  DateTime scannedAt, @JsonKey(name: 'food_name')  String? foodName,  int? calories,  double? protein,  double? carbs,  double? fat,  double? fiber,  String? confidence,  String? note)  $default,) {final _that = this;
switch (_that) {
case _FoodScan():
return $default(_that.id,_that.userId,_that.scannedAt,_that.foodName,_that.calories,_that.protein,_that.carbs,_that.fat,_that.fiber,_that.confidence,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'scanned_at')  DateTime scannedAt, @JsonKey(name: 'food_name')  String? foodName,  int? calories,  double? protein,  double? carbs,  double? fat,  double? fiber,  String? confidence,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _FoodScan() when $default != null:
return $default(_that.id,_that.userId,_that.scannedAt,_that.foodName,_that.calories,_that.protein,_that.carbs,_that.fat,_that.fiber,_that.confidence,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FoodScan implements FoodScan {
  const _FoodScan({required this.id, @JsonKey(name: 'user_id') required this.userId, @JsonKey(name: 'scanned_at') required this.scannedAt, @JsonKey(name: 'food_name') this.foodName, this.calories, this.protein, this.carbs, this.fat, this.fiber, this.confidence, this.note});
  factory _FoodScan.fromJson(Map<String, dynamic> json) => _$FoodScanFromJson(json);

@override final  String id;
@override@JsonKey(name: 'user_id') final  String userId;
@override@JsonKey(name: 'scanned_at') final  DateTime scannedAt;
@override@JsonKey(name: 'food_name') final  String? foodName;
@override final  int? calories;
@override final  double? protein;
@override final  double? carbs;
@override final  double? fat;
@override final  double? fiber;
@override final  String? confidence;
@override final  String? note;

/// Create a copy of FoodScan
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FoodScanCopyWith<_FoodScan> get copyWith => __$FoodScanCopyWithImpl<_FoodScan>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FoodScanToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FoodScan&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.scannedAt, scannedAt) || other.scannedAt == scannedAt)&&(identical(other.foodName, foodName) || other.foodName == foodName)&&(identical(other.calories, calories) || other.calories == calories)&&(identical(other.protein, protein) || other.protein == protein)&&(identical(other.carbs, carbs) || other.carbs == carbs)&&(identical(other.fat, fat) || other.fat == fat)&&(identical(other.fiber, fiber) || other.fiber == fiber)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,scannedAt,foodName,calories,protein,carbs,fat,fiber,confidence,note);

@override
String toString() {
  return 'FoodScan(id: $id, userId: $userId, scannedAt: $scannedAt, foodName: $foodName, calories: $calories, protein: $protein, carbs: $carbs, fat: $fat, fiber: $fiber, confidence: $confidence, note: $note)';
}


}

/// @nodoc
abstract mixin class _$FoodScanCopyWith<$Res> implements $FoodScanCopyWith<$Res> {
  factory _$FoodScanCopyWith(_FoodScan value, $Res Function(_FoodScan) _then) = __$FoodScanCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'scanned_at') DateTime scannedAt,@JsonKey(name: 'food_name') String? foodName, int? calories, double? protein, double? carbs, double? fat, double? fiber, String? confidence, String? note
});




}
/// @nodoc
class __$FoodScanCopyWithImpl<$Res>
    implements _$FoodScanCopyWith<$Res> {
  __$FoodScanCopyWithImpl(this._self, this._then);

  final _FoodScan _self;
  final $Res Function(_FoodScan) _then;

/// Create a copy of FoodScan
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? scannedAt = null,Object? foodName = freezed,Object? calories = freezed,Object? protein = freezed,Object? carbs = freezed,Object? fat = freezed,Object? fiber = freezed,Object? confidence = freezed,Object? note = freezed,}) {
  return _then(_FoodScan(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,scannedAt: null == scannedAt ? _self.scannedAt : scannedAt // ignore: cast_nullable_to_non_nullable
as DateTime,foodName: freezed == foodName ? _self.foodName : foodName // ignore: cast_nullable_to_non_nullable
as String?,calories: freezed == calories ? _self.calories : calories // ignore: cast_nullable_to_non_nullable
as int?,protein: freezed == protein ? _self.protein : protein // ignore: cast_nullable_to_non_nullable
as double?,carbs: freezed == carbs ? _self.carbs : carbs // ignore: cast_nullable_to_non_nullable
as double?,fat: freezed == fat ? _self.fat : fat // ignore: cast_nullable_to_non_nullable
as double?,fiber: freezed == fiber ? _self.fiber : fiber // ignore: cast_nullable_to_non_nullable
as double?,confidence: freezed == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
