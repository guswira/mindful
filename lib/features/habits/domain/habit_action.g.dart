// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_action.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HabitAction _$HabitActionFromJson(Map<String, dynamic> json) => _HabitAction(
  id: json['id'] as String,
  label: json['label'] as String,
  isDefault: json['isDefault'] as bool? ?? false,
);

Map<String, dynamic> _$HabitActionToJson(_HabitAction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'isDefault': instance.isDefault,
    };
