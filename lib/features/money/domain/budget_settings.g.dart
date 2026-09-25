// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BudgetSettings _$BudgetSettingsFromJson(Map<String, dynamic> json) =>
    _BudgetSettings(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      updatedAt: DateTime.parse(json['updated_at'] as String),
      budgetType:
          $enumDecodeNullable(_$BudgetTypeEnumMap, json['budget_type']) ??
          BudgetType.monthly,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'IDR',
    );

Map<String, dynamic> _$BudgetSettingsToJson(_BudgetSettings instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'updated_at': instance.updatedAt.toIso8601String(),
      'budget_type': _$BudgetTypeEnumMap[instance.budgetType]!,
      'amount': instance.amount,
      'currency': instance.currency,
    };

const _$BudgetTypeEnumMap = {
  BudgetType.monthly: 'monthly',
  BudgetType.daily: 'daily',
};
