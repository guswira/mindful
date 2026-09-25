// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'money_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MoneyEntry {

 String get id;@JsonKey(name: 'user_id') String get userId; EntryType get type; double get amount; String get category; DateTime get date;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime get updatedAt; String? get note;@JsonKey(name: 'sync_status') SyncStatus get syncStatus;
/// Create a copy of MoneyEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MoneyEntryCopyWith<MoneyEntry> get copyWith => _$MoneyEntryCopyWithImpl<MoneyEntry>(this as MoneyEntry, _$identity);

  /// Serializes this MoneyEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MoneyEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.type, type) || other.type == type)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.category, category) || other.category == category)&&(identical(other.date, date) || other.date == date)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.note, note) || other.note == note)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,type,amount,category,date,createdAt,updatedAt,note,syncStatus);

@override
String toString() {
  return 'MoneyEntry(id: $id, userId: $userId, type: $type, amount: $amount, category: $category, date: $date, createdAt: $createdAt, updatedAt: $updatedAt, note: $note, syncStatus: $syncStatus)';
}


}

/// @nodoc
abstract mixin class $MoneyEntryCopyWith<$Res>  {
  factory $MoneyEntryCopyWith(MoneyEntry value, $Res Function(MoneyEntry) _then) = _$MoneyEntryCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId, EntryType type, double amount, String category, DateTime date,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt, String? note,@JsonKey(name: 'sync_status') SyncStatus syncStatus
});




}
/// @nodoc
class _$MoneyEntryCopyWithImpl<$Res>
    implements $MoneyEntryCopyWith<$Res> {
  _$MoneyEntryCopyWithImpl(this._self, this._then);

  final MoneyEntry _self;
  final $Res Function(MoneyEntry) _then;

/// Create a copy of MoneyEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? type = null,Object? amount = null,Object? category = null,Object? date = null,Object? createdAt = null,Object? updatedAt = null,Object? note = freezed,Object? syncStatus = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as EntryType,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as SyncStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [MoneyEntry].
extension MoneyEntryPatterns on MoneyEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MoneyEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MoneyEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MoneyEntry value)  $default,){
final _that = this;
switch (_that) {
case _MoneyEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MoneyEntry value)?  $default,){
final _that = this;
switch (_that) {
case _MoneyEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId,  EntryType type,  double amount,  String category,  DateTime date, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt,  String? note, @JsonKey(name: 'sync_status')  SyncStatus syncStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MoneyEntry() when $default != null:
return $default(_that.id,_that.userId,_that.type,_that.amount,_that.category,_that.date,_that.createdAt,_that.updatedAt,_that.note,_that.syncStatus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId,  EntryType type,  double amount,  String category,  DateTime date, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt,  String? note, @JsonKey(name: 'sync_status')  SyncStatus syncStatus)  $default,) {final _that = this;
switch (_that) {
case _MoneyEntry():
return $default(_that.id,_that.userId,_that.type,_that.amount,_that.category,_that.date,_that.createdAt,_that.updatedAt,_that.note,_that.syncStatus);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'user_id')  String userId,  EntryType type,  double amount,  String category,  DateTime date, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt,  String? note, @JsonKey(name: 'sync_status')  SyncStatus syncStatus)?  $default,) {final _that = this;
switch (_that) {
case _MoneyEntry() when $default != null:
return $default(_that.id,_that.userId,_that.type,_that.amount,_that.category,_that.date,_that.createdAt,_that.updatedAt,_that.note,_that.syncStatus);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MoneyEntry implements MoneyEntry {
  const _MoneyEntry({required this.id, @JsonKey(name: 'user_id') required this.userId, required this.type, required this.amount, required this.category, required this.date, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt, this.note, @JsonKey(name: 'sync_status') this.syncStatus = SyncStatus.synced});
  factory _MoneyEntry.fromJson(Map<String, dynamic> json) => _$MoneyEntryFromJson(json);

@override final  String id;
@override@JsonKey(name: 'user_id') final  String userId;
@override final  EntryType type;
@override final  double amount;
@override final  String category;
@override final  DateTime date;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;
@override final  String? note;
@override@JsonKey(name: 'sync_status') final  SyncStatus syncStatus;

/// Create a copy of MoneyEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MoneyEntryCopyWith<_MoneyEntry> get copyWith => __$MoneyEntryCopyWithImpl<_MoneyEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MoneyEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MoneyEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.type, type) || other.type == type)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.category, category) || other.category == category)&&(identical(other.date, date) || other.date == date)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.note, note) || other.note == note)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,type,amount,category,date,createdAt,updatedAt,note,syncStatus);

@override
String toString() {
  return 'MoneyEntry(id: $id, userId: $userId, type: $type, amount: $amount, category: $category, date: $date, createdAt: $createdAt, updatedAt: $updatedAt, note: $note, syncStatus: $syncStatus)';
}


}

/// @nodoc
abstract mixin class _$MoneyEntryCopyWith<$Res> implements $MoneyEntryCopyWith<$Res> {
  factory _$MoneyEntryCopyWith(_MoneyEntry value, $Res Function(_MoneyEntry) _then) = __$MoneyEntryCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId, EntryType type, double amount, String category, DateTime date,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt, String? note,@JsonKey(name: 'sync_status') SyncStatus syncStatus
});




}
/// @nodoc
class __$MoneyEntryCopyWithImpl<$Res>
    implements _$MoneyEntryCopyWith<$Res> {
  __$MoneyEntryCopyWithImpl(this._self, this._then);

  final _MoneyEntry _self;
  final $Res Function(_MoneyEntry) _then;

/// Create a copy of MoneyEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? type = null,Object? amount = null,Object? category = null,Object? date = null,Object? createdAt = null,Object? updatedAt = null,Object? note = freezed,Object? syncStatus = null,}) {
  return _then(_MoneyEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as EntryType,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as SyncStatus,
  ));
}


}

// dart format on
