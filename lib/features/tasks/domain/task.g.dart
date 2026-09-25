// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Task _$TaskFromJson(Map<String, dynamic> json) => _Task(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  name: json['name'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  isCompleted: json['is_completed'] as bool? ?? false,
  dueDate: json['due_date'] == null
      ? null
      : DateTime.parse(json['due_date'] as String),
  reminderAt: json['reminder_at'] == null
      ? null
      : DateTime.parse(json['reminder_at'] as String),
  checkboxes:
      (json['checkboxes'] as List<dynamic>?)
          ?.map((e) => TaskCheckbox.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <TaskCheckbox>[],
  syncStatus:
      $enumDecodeNullable(_$SyncStatusEnumMap, json['sync_status']) ??
      SyncStatus.synced,
);

Map<String, dynamic> _$TaskToJson(_Task instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'name': instance.name,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'is_completed': instance.isCompleted,
  'due_date': instance.dueDate?.toIso8601String(),
  'reminder_at': instance.reminderAt?.toIso8601String(),
  'checkboxes': instance.checkboxes.map((e) => e.toJson()).toList(),
  'sync_status': _$SyncStatusEnumMap[instance.syncStatus]!,
};

const _$SyncStatusEnumMap = {
  SyncStatus.synced: 'synced',
  SyncStatus.pending: 'pending',
};
