// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_scan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FoodScan _$FoodScanFromJson(Map<String, dynamic> json) => _FoodScan(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  scannedAt: DateTime.parse(json['scanned_at'] as String),
  foodName: json['food_name'] as String?,
  calories: (json['calories'] as num?)?.toInt(),
  protein: (json['protein'] as num?)?.toDouble(),
  carbs: (json['carbs'] as num?)?.toDouble(),
  fat: (json['fat'] as num?)?.toDouble(),
  fiber: (json['fiber'] as num?)?.toDouble(),
  confidence: json['confidence'] as String?,
  note: json['note'] as String?,
);

Map<String, dynamic> _$FoodScanToJson(_FoodScan instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'scanned_at': instance.scannedAt.toIso8601String(),
  'food_name': instance.foodName,
  'calories': instance.calories,
  'protein': instance.protein,
  'carbs': instance.carbs,
  'fat': instance.fat,
  'fiber': instance.fiber,
  'confidence': instance.confidence,
  'note': instance.note,
};
