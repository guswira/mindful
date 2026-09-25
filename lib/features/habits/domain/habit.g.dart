// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Habit _$HabitFromJson(Map<String, dynamic> json) => _Habit(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  name: json['name'] as String,
  icon: json['icon'] as String,
  color: json['color'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  reminderDays:
      (json['reminder_days'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const <int>[],
  reminderTime: const TimeOfDayConverter().fromJson(
    json['reminder_time'] as String?,
  ),
  actions:
      (json['actions'] as List<dynamic>?)
          ?.map((e) => HabitAction.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <HabitAction>[],
  archived: json['archived'] as bool? ?? false,
);

Map<String, dynamic> _$HabitToJson(_Habit instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'name': instance.name,
  'icon': instance.icon,
  'color': instance.color,
  'created_at': instance.createdAt.toIso8601String(),
  'reminder_days': instance.reminderDays,
  'reminder_time': const TimeOfDayConverter().toJson(instance.reminderTime),
  'actions': instance.actions.map((e) => e.toJson()).toList(),
  'archived': instance.archived,
};
