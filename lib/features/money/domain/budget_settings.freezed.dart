// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'budget_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BudgetSettings {

 String get id;@JsonKey(name: 'user_id') String get userId;@JsonKey(name: 'updated_at') DateTime get updatedAt;@JsonKey(name: 'budget_type') BudgetType get budgetType; double get amount; String get currency;
/// Create a copy of BudgetSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BudgetSettingsCopyWith<BudgetSettings> get copyWith => _$BudgetSettingsCopyWithImpl<BudgetSettings>(this as BudgetSettings, _$identity);

  /// Serializes this BudgetSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BudgetSettings&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.budgetType, budgetType) || other.budgetType == budgetType)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,updatedAt,budgetType,amount,currency);

@override
String toString() {
  return 'BudgetSettings(id: $id, userId: $userId, updatedAt: $updatedAt, budgetType: $budgetType, amount: $amount, currency: $currency)';
}


}

/// @nodoc
abstract mixin class $BudgetSettingsCopyWith<$Res>  {
  factory $BudgetSettingsCopyWith(BudgetSettings value, $Res Function(BudgetSettings) _then) = _$BudgetSettingsCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'updated_at') DateTime updatedAt,@JsonKey(name: 'budget_type') BudgetType budgetType, double amount, String currency
});




}
/// @nodoc
class _$BudgetSettingsCopyWithImpl<$Res>
    implements $BudgetSettingsCopyWith<$Res> {
  _$BudgetSettingsCopyWithImpl(this._self, this._then);

  final BudgetSettings _self;
  final $Res Function(BudgetSettings) _then;

/// Create a copy of BudgetSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? updatedAt = null,Object? budgetType = null,Object? amount = null,Object? currency = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,budgetType: null == budgetType ? _self.budgetType : budgetType // ignore: cast_nullable_to_non_nullable
as BudgetType,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [BudgetSettings].
extension BudgetSettingsPatterns on BudgetSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BudgetSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BudgetSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BudgetSettings value)  $default,){
final _that = this;
switch (_that) {
case _BudgetSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BudgetSettings value)?  $default,){
final _that = this;
switch (_that) {
case _BudgetSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'budget_type')  BudgetType budgetType,  double amount,  String currency)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BudgetSettings() when $default != null:
return $default(_that.id,_that.userId,_that.updatedAt,_that.budgetType,_that.amount,_that.currency);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'budget_type')  BudgetType budgetType,  double amount,  String currency)  $default,) {final _that = this;
switch (_that) {
case _BudgetSettings():
return $default(_that.id,_that.userId,_that.updatedAt,_that.budgetType,_that.amount,_that.currency);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'budget_type')  BudgetType budgetType,  double amount,  String currency)?  $default,) {final _that = this;
switch (_that) {
case _BudgetSettings() when $default != null:
return $default(_that.id,_that.userId,_that.updatedAt,_that.budgetType,_that.amount,_that.currency);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BudgetSettings implements BudgetSettings {
  const _BudgetSettings({required this.id, @JsonKey(name: 'user_id') required this.userId, @JsonKey(name: 'updated_at') required this.updatedAt, @JsonKey(name: 'budget_type') this.budgetType = BudgetType.monthly, this.amount = 0, this.currency = 'IDR'});
  factory _BudgetSettings.fromJson(Map<String, dynamic> json) => _$BudgetSettingsFromJson(json);

@override final  String id;
@override@JsonKey(name: 'user_id') final  String userId;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;
@override@JsonKey(name: 'budget_type') final  BudgetType budgetType;
@override@JsonKey() final  double amount;
@override@JsonKey() final  String currency;

/// Create a copy of BudgetSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BudgetSettingsCopyWith<_BudgetSettings> get copyWith => __$BudgetSettingsCopyWithImpl<_BudgetSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BudgetSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BudgetSettings&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.budgetType, budgetType) || other.budgetType == budgetType)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,updatedAt,budgetType,amount,currency);

@override
String toString() {
  return 'BudgetSettings(id: $id, userId: $userId, updatedAt: $updatedAt, budgetType: $budgetType, amount: $amount, currency: $currency)';
}


}

/// @nodoc
abstract mixin class _$BudgetSettingsCopyWith<$Res> implements $BudgetSettingsCopyWith<$Res> {
  factory _$BudgetSettingsCopyWith(_BudgetSettings value, $Res Function(_BudgetSettings) _then) = __$BudgetSettingsCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'updated_at') DateTime updatedAt,@JsonKey(name: 'budget_type') BudgetType budgetType, double amount, String currency
});




}
/// @nodoc
class __$BudgetSettingsCopyWithImpl<$Res>
    implements _$BudgetSettingsCopyWith<$Res> {
  __$BudgetSettingsCopyWithImpl(this._self, this._then);

  final _BudgetSettings _self;
  final $Res Function(_BudgetSettings) _then;

/// Create a copy of BudgetSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? updatedAt = null,Object? budgetType = null,Object? amount = null,Object? currency = null,}) {
  return _then(_BudgetSettings(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,budgetType: null == budgetType ? _self.budgetType : budgetType // ignore: cast_nullable_to_non_nullable
as BudgetType,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
