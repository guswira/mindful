// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'food_analysis.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FoodAnalysis {

 String get foodName; int get calories; double get protein; double get carbs; double get fat; double get fiber; String get confidence; String? get servingNote; String? get healthNote; List<String> get ingredients;
/// Create a copy of FoodAnalysis
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FoodAnalysisCopyWith<FoodAnalysis> get copyWith => _$FoodAnalysisCopyWithImpl<FoodAnalysis>(this as FoodAnalysis, _$identity);

  /// Serializes this FoodAnalysis to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FoodAnalysis&&(identical(other.foodName, foodName) || other.foodName == foodName)&&(identical(other.calories, calories) || other.calories == calories)&&(identical(other.protein, protein) || other.protein == protein)&&(identical(other.carbs, carbs) || other.carbs == carbs)&&(identical(other.fat, fat) || other.fat == fat)&&(identical(other.fiber, fiber) || other.fiber == fiber)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.servingNote, servingNote) || other.servingNote == servingNote)&&(identical(other.healthNote, healthNote) || other.healthNote == healthNote)&&const DeepCollectionEquality().equals(other.ingredients, ingredients));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,foodName,calories,protein,carbs,fat,fiber,confidence,servingNote,healthNote,const DeepCollectionEquality().hash(ingredients));

@override
String toString() {
  return 'FoodAnalysis(foodName: $foodName, calories: $calories, protein: $protein, carbs: $carbs, fat: $fat, fiber: $fiber, confidence: $confidence, servingNote: $servingNote, healthNote: $healthNote, ingredients: $ingredients)';
}


}

/// @nodoc
abstract mixin class $FoodAnalysisCopyWith<$Res>  {
  factory $FoodAnalysisCopyWith(FoodAnalysis value, $Res Function(FoodAnalysis) _then) = _$FoodAnalysisCopyWithImpl;
@useResult
$Res call({
 String foodName, int calories, double protein, double carbs, double fat, double fiber, String confidence, String? servingNote, String? healthNote, List<String> ingredients
});




}
/// @nodoc
class _$FoodAnalysisCopyWithImpl<$Res>
    implements $FoodAnalysisCopyWith<$Res> {
  _$FoodAnalysisCopyWithImpl(this._self, this._then);

  final FoodAnalysis _self;
  final $Res Function(FoodAnalysis) _then;

/// Create a copy of FoodAnalysis
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? foodName = null,Object? calories = null,Object? protein = null,Object? carbs = null,Object? fat = null,Object? fiber = null,Object? confidence = null,Object? servingNote = freezed,Object? healthNote = freezed,Object? ingredients = null,}) {
  return _then(_self.copyWith(
foodName: null == foodName ? _self.foodName : foodName // ignore: cast_nullable_to_non_nullable
as String,calories: null == calories ? _self.calories : calories // ignore: cast_nullable_to_non_nullable
as int,protein: null == protein ? _self.protein : protein // ignore: cast_nullable_to_non_nullable
as double,carbs: null == carbs ? _self.carbs : carbs // ignore: cast_nullable_to_non_nullable
as double,fat: null == fat ? _self.fat : fat // ignore: cast_nullable_to_non_nullable
as double,fiber: null == fiber ? _self.fiber : fiber // ignore: cast_nullable_to_non_nullable
as double,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as String,servingNote: freezed == servingNote ? _self.servingNote : servingNote // ignore: cast_nullable_to_non_nullable
as String?,healthNote: freezed == healthNote ? _self.healthNote : healthNote // ignore: cast_nullable_to_non_nullable
as String?,ingredients: null == ingredients ? _self.ingredients : ingredients // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [FoodAnalysis].
extension FoodAnalysisPatterns on FoodAnalysis {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FoodAnalysis value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FoodAnalysis() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FoodAnalysis value)  $default,){
final _that = this;
switch (_that) {
case _FoodAnalysis():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FoodAnalysis value)?  $default,){
final _that = this;
switch (_that) {
case _FoodAnalysis() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String foodName,  int calories,  double protein,  double carbs,  double fat,  double fiber,  String confidence,  String? servingNote,  String? healthNote,  List<String> ingredients)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FoodAnalysis() when $default != null:
return $default(_that.foodName,_that.calories,_that.protein,_that.carbs,_that.fat,_that.fiber,_that.confidence,_that.servingNote,_that.healthNote,_that.ingredients);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String foodName,  int calories,  double protein,  double carbs,  double fat,  double fiber,  String confidence,  String? servingNote,  String? healthNote,  List<String> ingredients)  $default,) {final _that = this;
switch (_that) {
case _FoodAnalysis():
return $default(_that.foodName,_that.calories,_that.protein,_that.carbs,_that.fat,_that.fiber,_that.confidence,_that.servingNote,_that.healthNote,_that.ingredients);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String foodName,  int calories,  double protein,  double carbs,  double fat,  double fiber,  String confidence,  String? servingNote,  String? healthNote,  List<String> ingredients)?  $default,) {final _that = this;
switch (_that) {
case _FoodAnalysis() when $default != null:
return $default(_that.foodName,_that.calories,_that.protein,_that.carbs,_that.fat,_that.fiber,_that.confidence,_that.servingNote,_that.healthNote,_that.ingredients);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FoodAnalysis implements FoodAnalysis {
  const _FoodAnalysis({required this.foodName, required this.calories, required this.protein, required this.carbs, required this.fat, required this.fiber, required this.confidence, this.servingNote, this.healthNote, final  List<String> ingredients = const []}): _ingredients = ingredients;
  factory _FoodAnalysis.fromJson(Map<String, dynamic> json) => _$FoodAnalysisFromJson(json);

@override final  String foodName;
@override final  int calories;
@override final  double protein;
@override final  double carbs;
@override final  double fat;
@override final  double fiber;
@override final  String confidence;
@override final  String? servingNote;
@override final  String? healthNote;
 final  List<String> _ingredients;
@override@JsonKey() List<String> get ingredients {
  if (_ingredients is EqualUnmodifiableListView) return _ingredients;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ingredients);
}


/// Create a copy of FoodAnalysis
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FoodAnalysisCopyWith<_FoodAnalysis> get copyWith => __$FoodAnalysisCopyWithImpl<_FoodAnalysis>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FoodAnalysisToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FoodAnalysis&&(identical(other.foodName, foodName) || other.foodName == foodName)&&(identical(other.calories, calories) || other.calories == calories)&&(identical(other.protein, protein) || other.protein == protein)&&(identical(other.carbs, carbs) || other.carbs == carbs)&&(identical(other.fat, fat) || other.fat == fat)&&(identical(other.fiber, fiber) || other.fiber == fiber)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.servingNote, servingNote) || other.servingNote == servingNote)&&(identical(other.healthNote, healthNote) || other.healthNote == healthNote)&&const DeepCollectionEquality().equals(other._ingredients, _ingredients));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,foodName,calories,protein,carbs,fat,fiber,confidence,servingNote,healthNote,const DeepCollectionEquality().hash(_ingredients));

@override
String toString() {
  return 'FoodAnalysis(foodName: $foodName, calories: $calories, protein: $protein, carbs: $carbs, fat: $fat, fiber: $fiber, confidence: $confidence, servingNote: $servingNote, healthNote: $healthNote, ingredients: $ingredients)';
}


}

/// @nodoc
abstract mixin class _$FoodAnalysisCopyWith<$Res> implements $FoodAnalysisCopyWith<$Res> {
  factory _$FoodAnalysisCopyWith(_FoodAnalysis value, $Res Function(_FoodAnalysis) _then) = __$FoodAnalysisCopyWithImpl;
@override @useResult
$Res call({
 String foodName, int calories, double protein, double carbs, double fat, double fiber, String confidence, String? servingNote, String? healthNote, List<String> ingredients
});




}
/// @nodoc
class __$FoodAnalysisCopyWithImpl<$Res>
    implements _$FoodAnalysisCopyWith<$Res> {
  __$FoodAnalysisCopyWithImpl(this._self, this._then);

  final _FoodAnalysis _self;
  final $Res Function(_FoodAnalysis) _then;

/// Create a copy of FoodAnalysis
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? foodName = null,Object? calories = null,Object? protein = null,Object? carbs = null,Object? fat = null,Object? fiber = null,Object? confidence = null,Object? servingNote = freezed,Object? healthNote = freezed,Object? ingredients = null,}) {
  return _then(_FoodAnalysis(
foodName: null == foodName ? _self.foodName : foodName // ignore: cast_nullable_to_non_nullable
as String,calories: null == calories ? _self.calories : calories // ignore: cast_nullable_to_non_nullable
as int,protein: null == protein ? _self.protein : protein // ignore: cast_nullable_to_non_nullable
as double,carbs: null == carbs ? _self.carbs : carbs // ignore: cast_nullable_to_non_nullable
as double,fat: null == fat ? _self.fat : fat // ignore: cast_nullable_to_non_nullable
as double,fiber: null == fiber ? _self.fiber : fiber // ignore: cast_nullable_to_non_nullable
as double,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as String,servingNote: freezed == servingNote ? _self.servingNote : servingNote // ignore: cast_nullable_to_non_nullable
as String?,healthNote: freezed == healthNote ? _self.healthNote : healthNote // ignore: cast_nullable_to_non_nullable
as String?,ingredients: null == ingredients ? _self._ingredients : ingredients // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
