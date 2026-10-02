// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'breathing_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BreathingSession _$BreathingSessionFromJson(Map<String, dynamic> json) =>
    _BreathingSession(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      exercise: $enumDecode(_$BreathingExerciseEnumMap, json['exercise']),
      startedAt: DateTime.parse(json['started_at'] as String),
      durationSeconds: (json['duration_seconds'] as num).toInt(),
      cycles: (json['cycles'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      bestHoldSeconds: (json['best_hold_seconds'] as num?)?.toInt(),
      syncStatus:
          $enumDecodeNullable(_$SyncStatusEnumMap, json['sync_status']) ??
          SyncStatus.synced,
    );

Map<String, dynamic> _$BreathingSessionToJson(_BreathingSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'exercise': _$BreathingExerciseEnumMap[instance.exercise]!,
      'started_at': instance.startedAt.toIso8601String(),
      'duration_seconds': instance.durationSeconds,
      'cycles': instance.cycles,
      'created_at': instance.createdAt.toIso8601String(),
      'best_hold_seconds': instance.bestHoldSeconds,
      'sync_status': _$SyncStatusEnumMap[instance.syncStatus]!,
    };

const _$BreathingExerciseEnumMap = {
  BreathingExercise.equal: 'equal',
  BreathingExercise.box: 'box',
  BreathingExercise.fourSevenEight: '4_7_8',
  BreathingExercise.holdTest: 'hold_test',
  BreathingExercise.custom: 'custom',
};

const _$SyncStatusEnumMap = {
  SyncStatus.synced: 'synced',
  SyncStatus.pending: 'pending',
};
