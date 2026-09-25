// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'money_advice.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MoneyAdvice _$MoneyAdviceFromJson(Map<String, dynamic> json) => _MoneyAdvice(
  summary: json['summary'] as String,
  spendingInsights:
      (json['spendingInsights'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  savingTips:
      (json['savingTips'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$MoneyAdviceToJson(_MoneyAdvice instance) =>
    <String, dynamic>{
      'summary': instance.summary,
      'spendingInsights': instance.spendingInsights,
      'savingTips': instance.savingTips,
    };
