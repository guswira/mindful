// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HabitLog _$HabitLogFromJson(Map<String, dynamic> json) => _HabitLog(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  habitId: json['habit_id'] as String,
  date: DateTime.parse(json['date'] as String),
  completedActionId: json['completed_action_id'] as String?,
  note: json['note'] as String?,
  syncStatus:
      $enumDecodeNullable(_$SyncStatusEnumMap, json['sync_status']) ??
      SyncStatus.synced,
);

Map<String, dynamic> _$HabitLogToJson(_HabitLog instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'habit_id': instance.habitId,
  'date': instance.date.toIso8601String(),
  'completed_action_id': instance.completedActionId,
  'note': instance.note,
  'sync_status': _$SyncStatusEnumMap[instance.syncStatus]!,
};

const _$SyncStatusEnumMap = {
  SyncStatus.synced: 'synced',
  SyncStatus.pending: 'pending',
};
