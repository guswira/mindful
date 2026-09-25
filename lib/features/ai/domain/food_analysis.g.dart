// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_analysis.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FoodAnalysis _$FoodAnalysisFromJson(Map<String, dynamic> json) =>
    _FoodAnalysis(
      foodName: json['foodName'] as String,
      calories: (json['calories'] as num).toInt(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      fiber: (json['fiber'] as num).toDouble(),
      confidence: json['confidence'] as String,
      servingNote: json['servingNote'] as String?,
      healthNote: json['healthNote'] as String?,
      ingredients:
          (json['ingredients'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$FoodAnalysisToJson(_FoodAnalysis instance) =>
    <String, dynamic>{
      'foodName': instance.foodName,
      'calories': instance.calories,
      'protein': instance.protein,
      'carbs': instance.carbs,
      'fat': instance.fat,
      'fiber': instance.fiber,
      'confidence': instance.confidence,
      'servingNote': instance.servingNote,
      'healthNote': instance.healthNote,
      'ingredients': instance.ingredients,
    };
