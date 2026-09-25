import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/l10n/l10n.dart';
import '../../features/ai/domain/food_analysis.dart';
import '../../features/ai/domain/food_scan_exception.dart';
import '../../features/money/domain/money_advice.dart';

part 'gemini_service.g.dart';

const String _foodAnalysisPrompt = '''
You are a nutrition expert. Analyze this food image carefully.
Respond with a single JSON object only — no markdown, no explanation, no code blocks.
Use this exact structure:
{
  "foodName": "name of the food or dish",
  "calories": estimated_integer,
  "protein": grams_as_decimal,
  "carbs": grams_as_decimal,
  "fat": grams_as_decimal,
  "fiber": grams_as_decimal,
  "confidence": "high" or "medium" or "low",
  "servingNote": "description of assumed serving size",
  "healthNote": "one sentence health insight about this food",
  "ingredients": ["main ingredient 1", "main ingredient 2", "main ingredient 3"]
}
If the image is not food or you cannot identify it, respond with exactly: null''';

/// Sends prompts to Gemini and parses its JSON replies — food photo
/// nutrition estimates (SPEC.md AI Lab Feature GeminiService) and money
/// spending advice (SPEC.md Money Flow Feature AI Advice).
class GeminiService {
  GeminiService()
    : _model = GenerativeModel(
        // gemini-1.5-flash (SPEC.md's original pick) was fully retired —
        // every request to it now 404s. gemini-3.8-flash is the current
        // stable, vision-capable flash model.
        model: 'gemini-3.8-flash',
        apiKey: dotenv.env['GEMINI_API_KEY'] ?? '',
      );

  final GenerativeModel _model;

  static const Duration _timeout = Duration(seconds: 30);

  /// Returns null when Gemini reports the photo isn't food. Throws
  /// [FoodScanException] for every other failure — timeout, no
  /// connection, an API-side error, or a response that isn't valid JSON.
  Future<FoodAnalysis?> analyzeFood(File compressedImage) async {
    final Uint8List bytes;
    try {
      bytes = await compressedImage.readAsBytes();
    } catch (error) {
      debugPrint('Unreadable food photo: $error');
      throw FoodScanException(
        currentL10n.geminiErrorUnknown,
        FoodScanErrorType.unknown,
      );
    }
    final text = await _generate([
      Content.multi([
        TextPart(_foodAnalysisPrompt),
        DataPart('image/jpeg', bytes),
      ]),
    ]);
    if (text == null || text == 'null') {
      return null;
    }
    return _decodeJson(text, FoodAnalysis.fromJson);
  }

  /// Asks Gemini where [moneySummary]'s spending mostly goes and how to
  /// save. The prompt is [currentL10n]'s, so both it and the advice come
  /// back in the app language. Throws [FoodScanException] on any failure,
  /// same as [analyzeFood] — it shares the same error classification.
  Future<MoneyAdvice> adviseOnMoney(String moneySummary) async {
    final text = await _generate([
      Content.text(currentL10n.moneyAdvicePrompt(moneySummary)),
    ]);
    if (text == null || text.isEmpty) {
      throw FoodScanException(
        currentL10n.moneyAdviceUnreadable,
        FoodScanErrorType.unknown,
      );
    }
    return _decodeJson(text, MoneyAdvice.fromJson);
  }

  /// Sends [content] and returns Gemini's trimmed reply text, mapping
  /// every failure onto a [FoodScanException] with a user-facing message.
  Future<String?> _generate(List<Content> content) async {
    try {
      final response = await _model.generateContent(content).timeout(_timeout);
      return response.text?.trim();
    } on TimeoutException {
      throw FoodScanException(
        currentL10n.aiErrorTimeout,
        FoodScanErrorType.timeout,
      );
    } on SocketException {
      throw FoodScanException(
        currentL10n.aiErrorNoConnection,
        FoodScanErrorType.networkError,
      );
    } on GenerativeAIException catch (error) {
      debugPrint('Gemini API error: ${error.message}');
      final (type, message) = _classifyApiError(error);
      throw FoodScanException(message, type);
    } catch (error) {
      debugPrint('Unexpected Gemini error: $error');
      throw FoodScanException(
        currentL10n.geminiErrorUnknown,
        FoodScanErrorType.unknown,
      );
    }
  }

  /// Parses [text] with [fromJson], after stripping any accidental
  /// markdown fences — the prompts ask Gemini not to use them, but it
  /// isn't guaranteed to comply.
  static T _decodeJson<T>(
    String text,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final cleaned = text.replaceAll('```json', '').replaceAll('```', '').trim();
    try {
      return fromJson(jsonDecode(cleaned) as Map<String, dynamic>);
    } catch (error) {
      debugPrint('Unreadable Gemini response: $error');
      throw FoodScanException(
        currentL10n.geminiErrorUnknown,
        FoodScanErrorType.unknown,
      );
    }
  }
}

/// Classifies a [GenerativeAIException] into a [FoodScanErrorType] and a
/// message worth showing the user — the SDK only ever exposes a raw
/// `.message` string (an [InvalidApiKey] distinguishes a bad key, but every
/// other server-side failure, from a busy model to a retired one, comes
/// back as the same [ServerException] type), so both have to be read out of
/// that string.
///
/// Only [FoodScanErrorType.busy] is worth [AITab] auto-retrying — an
/// overloaded or rate-limited model often clears within its 5 retries (a
/// minute apart), but a bad key or a retired model never will.
(FoodScanErrorType, String) _classifyApiError(GenerativeAIException error) {
  if (error is InvalidApiKey) {
    return (FoodScanErrorType.apiError, currentL10n.geminiErrorInvalidKey);
  }
  final message = error.message;
  if (message.contains('UNAVAILABLE') || message.contains('high demand')) {
    return (FoodScanErrorType.busy, currentL10n.geminiErrorBusy);
  }
  if (message.contains('RESOURCE_EXHAUSTED') || message.contains('quota')) {
    return (FoodScanErrorType.busy, currentL10n.geminiErrorQuota);
  }
  if (message.contains('NOT_FOUND')) {
    return (
      FoodScanErrorType.apiError,
      currentL10n.geminiErrorModelUnavailable,
    );
  }
  if (message.contains('PERMISSION_DENIED')) {
    return (
      FoodScanErrorType.apiError,
      currentL10n.geminiErrorPermissionDenied,
    );
  }
  return (FoodScanErrorType.apiError, currentL10n.geminiErrorGeneric);
}

/// The app-wide [GeminiService].
@riverpod
GeminiService geminiService(Ref ref) => GeminiService();
