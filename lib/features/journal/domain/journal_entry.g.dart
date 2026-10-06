// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journal_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_JournalEntry _$JournalEntryFromJson(Map<String, dynamic> json) =>
    _JournalEntry(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      date: DateTime.parse(json['date'] as String),
      body: json['body'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      title: json['title'] as String?,
      mood: $enumDecodeNullable(_$MoodEnumMap, json['mood']),
      type:
          $enumDecodeNullable(
            _$JournalTypeEnumMap,
            json['type'],
            unknownValue: JournalType.review,
          ) ??
          JournalType.review,
      photoUrls:
          (json['photo_urls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      syncStatus:
          $enumDecodeNullable(_$SyncStatusEnumMap, json['sync_status']) ??
          SyncStatus.synced,
    );

Map<String, dynamic> _$JournalEntryToJson(_JournalEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'date': instance.date.toIso8601String(),
      'body': instance.body,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'title': instance.title,
      'mood': _$MoodEnumMap[instance.mood],
      'type': _$JournalTypeEnumMap[instance.type]!,
      'photo_urls': instance.photoUrls,
      'sync_status': _$SyncStatusEnumMap[instance.syncStatus]!,
    };

const _$MoodEnumMap = {
  Mood.happy: 'happy',
  Mood.neutral: 'neutral',
  Mood.sad: 'sad',
  Mood.anxious: 'anxious',
  Mood.excited: 'excited',
};

const _$JournalTypeEnumMap = {
  JournalType.review: 'review',
  JournalType.plan: 'plan',
  JournalType.gratitude: 'gratitude',
};

const _$SyncStatusEnumMap = {
  SyncStatus.synced: 'synced',
  SyncStatus.pending: 'pending',
};
