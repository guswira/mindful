import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/l10n/l10n.dart';
import '../../features/ai/domain/food_analysis.dart';
import '../../features/ai/domain/food_scan_exception.dart';
import '../../features/money/domain/money_advice.dart';
import 'gemini_proxy_client.dart';
import 'gemini_thinking_client.dart';

part 'gemini_service.g.dart';

/// One Gemini model the app may ask, with the least thinking it accepts.
typedef GeminiModelChoice = ({String name, GeminiThinkingLevel? thinking});

/// The models a request tries, in order — the next one only when the one
/// before is overloaded (503), out of quota (429, which is per model) or
/// gone (404). Each runs on its own capacity and free-tier quota, so a
/// busy newest model rarely fails a request on its own.
const List<GeminiModelChoice> geminiModels = [
  // Newest and best — and the busiest. Refuses MINIMAL thinking ("not
  // supported for this model"), so LOW is its least.
  (name: 'gemini-3.8-flash', thinking: GeminiThinkingLevel.low),
  // Older, stable, usually has room. Gemini 2.5 has no thinking levels
  // (it takes a token budget instead), so it thinks at its default.
  (name: 'gemini-2.5-flash', thinking: null),
  // Google's alias for the newest Flash-Lite: fastest, least busy,
  // slightly rougher estimates; the alias never gets retired under us.
  (name: 'gemini-flash-lite-latest', thinking: GeminiThinkingLevel.minimal),
];

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
    : this.withModels(
        food: [for (final model in geminiModels) _foodModelFor(model)],
        advice: [for (final model in geminiModels) _adviceModelFor(model)],
      );

  /// Uses the given models, tried in order — [GeminiService.new] builds
  /// the real ones from [geminiModels].
  @visibleForTesting
  GeminiService.withModels({
    required List<GenerativeModel> food,
    required List<GenerativeModel> advice,
  }) : assert(food.isNotEmpty && advice.isNotEmpty),
       _foodModels = food,
       _adviceModels = advice;

  // Neither a one-photo nutrition estimate nor spending advice gains much
  // from reasoning, so both get the least thinking their model takes
  // (fastest). The photo is read at medium resolution — half the image
  // tokens of the default, still plenty to tell dishes apart (low starts
  // to blur them).
  static GenerativeModel _foodModelFor(GeminiModelChoice model) =>
      _createModel(model, mediaResolution: GeminiMediaResolution.medium);

  static GenerativeModel _adviceModelFor(GeminiModelChoice model) =>
      _createModel(
        model,
        // The reply is a short summary + a few bullets; the cap stops a
        // rambling answer from adding seconds.
        maxOutputTokens: 1024,
      );

  /// Talks to Gemini directly only when a native build still has
  /// `GEMINI_API_KEY` in its `.env`; otherwise (always on web) through the
  /// `gemini-proxy` Edge Function, which keeps the key server-side.
  static GenerativeModel _createModel(
    GeminiModelChoice model, {
    GeminiMediaResolution? mediaResolution,
    int? maxOutputTokens,
  }) {
    final apiKey = dotenv.maybeGet('GEMINI_API_KEY') ?? '';
    final direct = !kIsWeb && apiKey.isNotEmpty;
    return GenerativeModel(
      model: model.name,
      // The proxy swaps this placeholder for the user's Supabase JWT.
      apiKey: direct ? apiKey : 'proxy',
      httpClient: GeminiThinkingClient(
        model.thinking,
        mediaResolution: mediaResolution,
        inner: direct ? null : GeminiProxyClient(),
      ),
      // Both prompts want bare JSON; JSON mode stops Gemini wrapping it in
      // prose or fences, so it writes (and we wait for) fewer tokens.
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        maxOutputTokens: maxOutputTokens,
      ),
    );
  }

  final List<GenerativeModel> _foodModels;
  final List<GenerativeModel> _adviceModels;

  static const Duration _foodTimeout = Duration(seconds: 30);

  /// Longer than the food scan's: the prompt can carry many money
  /// entries and the reply is several paragraphs.
  static const Duration _adviceTimeout = Duration(seconds: 60);

  /// Returns null when Gemini reports the photo isn't food. Throws
  /// [FoodScanException] for every other failure — timeout, no
  /// connection, an API-side error, or a response that isn't valid JSON.
  Future<FoodAnalysis?> analyzeFood(Uint8List compressedImage) async {
    final text = await _generate(_foodModels, _foodTimeout, [
      Content.multi([
        TextPart(_foodAnalysisPrompt),
        DataPart('image/jpeg', compressedImage),
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
    final text = await _generate(_adviceModels, _adviceTimeout, [
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
  ///
  /// Tries [models] in order, moving on right away when one is
  /// overloaded, out of quota or gone ([_triesNextModel]). When every one
  /// fails that way, the first busy error stands, so the caller's retry
  /// ([runWithRetry]) still kicks in. A timeout or any other error stops
  /// at once — a timeout has already used up the wait.
  Future<String?> _generate(
    List<GenerativeModel> models,
    Duration timeout,
    List<Content> content,
  ) async {
    try {
      GenerativeAIException? busy;
      GenerativeAIException? last;
      for (final (index, model) in models.indexed) {
        try {
          return await _ask(model, timeout, content);
        } on GenerativeAIException catch (error) {
          if (!_triesNextModel(error)) {
            rethrow;
          }
          debugPrint(
            'Gemini model ${index + 1}/${models.length} unavailable: '
            '${error.message}',
          );
          last = error;
          if (busy == null && _isBusy(error)) {
            busy = error;
          }
        }
      }
      // Every model failed in a way worth trying the next one for.
      throw busy ?? last ?? StateError('No Gemini models to ask');
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
    } on http.ClientException {
      // What a dropped connection looks like on web, where there's no
      // SocketException.
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

  /// Whether [error] is the asked model's own problem — another model may
  /// well answer.
  static bool _triesNextModel(GenerativeAIException error) =>
      _isBusy(error) || isGeminiModelMissing(error);

  static bool _isBusy(GenerativeAIException error) =>
      isGeminiOverloaded(error) || isGeminiOutOfQuota(error);

  static Future<String?> _ask(
    GenerativeModel model,
    Duration timeout,
    List<Content> content,
  ) async {
    final stopwatch = Stopwatch()..start();
    final response = await model.generateContent(content).timeout(timeout);
    final usage = response.usageMetadata;
    debugPrint(
      'Gemini replied in ${stopwatch.elapsedMilliseconds}ms '
      '(prompt ${usage?.promptTokenCount} tokens, '
      'reply ${usage?.candidatesTokenCount} tokens)',
    );
    return response.text?.trim();
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
  if (isGeminiOverloaded(error)) {
    return (FoodScanErrorType.busy, currentL10n.geminiErrorBusy);
  }
  if (isGeminiOutOfQuota(error)) {
    return (FoodScanErrorType.busy, currentL10n.geminiErrorQuota);
  }
  if (isGeminiModelMissing(error)) {
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

/// Whether [error] is Google's 503 "model overloaded" (the SDK keeps only
/// the message, not the status, so it's matched by wording) — a capacity
/// problem of that one model.
@visibleForTesting
bool isGeminiOverloaded(GenerativeAIException error) =>
    error.message.contains('UNAVAILABLE') ||
    error.message.contains('high demand') ||
    error.message.contains('overloaded');

/// Whether [error] is a 404 for the model itself — retired, renamed or
/// never existed ("models/x is not found for API version v1beta").
@visibleForTesting
bool isGeminiModelMissing(GenerativeAIException error) =>
    error.message.contains('NOT_FOUND') ||
    error.message.contains('is not found');

/// Whether [error] is a 429 — that model's quota is used up for now.
/// Quotas are per model, so another model may still have room.
@visibleForTesting
bool isGeminiOutOfQuota(GenerativeAIException error) =>
    error.message.contains('RESOURCE_EXHAUSTED') ||
    error.message.contains('quota');

/// The app-wide [GeminiService].
@riverpod
GeminiService geminiService(Ref ref) => GeminiService();
