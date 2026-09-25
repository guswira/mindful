import 'package:freezed_annotation/freezed_annotation.dart';

part 'food_analysis.freezed.dart';
part 'food_analysis.g.dart';

/// A single Gemini Vision nutrition estimate for one photo — transient,
/// never persisted directly (see [FoodScan] for the stored form). Field
/// names match Gemini's JSON response verbatim. See SPEC.md AI Lab Feature
/// Data models and [GeminiService.analyzeFood].
@freezed
abstract class FoodAnalysis with _$FoodAnalysis {
  const factory FoodAnalysis({
    required String foodName,
    required int calories,
    required double protein,
    required double carbs,
    required double fat,
    required double fiber,
    required String confidence,
    String? servingNote,
    String? healthNote,
    @Default([]) List<String> ingredients,
  }) = _FoodAnalysis;

  factory FoodAnalysis.fromJson(Map<String, dynamic> json) =>
      _$FoodAnalysisFromJson(json);
}
