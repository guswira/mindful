// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'money_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MoneyEntry _$MoneyEntryFromJson(Map<String, dynamic> json) => _MoneyEntry(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  type: $enumDecode(_$EntryTypeEnumMap, json['type']),
  amount: (json['amount'] as num).toDouble(),
  category: json['category'] as String,
  date: DateTime.parse(json['date'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  note: json['note'] as String?,
  syncStatus:
      $enumDecodeNullable(_$SyncStatusEnumMap, json['sync_status']) ??
      SyncStatus.synced,
);

Map<String, dynamic> _$MoneyEntryToJson(_MoneyEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'type': _$EntryTypeEnumMap[instance.type]!,
      'amount': instance.amount,
      'category': instance.category,
      'date': instance.date.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'note': instance.note,
      'sync_status': _$SyncStatusEnumMap[instance.syncStatus]!,
    };

const _$EntryTypeEnumMap = {
  EntryType.spending: 'spending',
  EntryType.income: 'income',
};

const _$SyncStatusEnumMap = {
  SyncStatus.synced: 'synced',
  SyncStatus.pending: 'pending',
};
