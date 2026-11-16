import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// How much Gemini may "think" before it answers (Gemini 3's
/// `thinkingConfig.thinkingLevel`).
enum GeminiThinkingLevel { minimal, low, medium, high }

/// How many tokens each image in a request costs Gemini 3
/// (`generationConfig.mediaResolution`): about 280 / 560 / 1120. Fewer
/// tokens means less for the model to read before it starts answering.
enum GeminiMediaResolution {
  low('MEDIA_RESOLUTION_LOW'),
  medium('MEDIA_RESOLUTION_MEDIUM'),
  high('MEDIA_RESOLUTION_HIGH');

  const GeminiMediaResolution(this.apiValue);

  /// The value Gemini's REST API expects.
  final String apiValue;
}

/// Adds a `thinkingConfig` to every generateContent request the Gemini SDK
/// sends — google_generative_ai 0.4.x has no field for it, and a Gemini 3
/// flash model left at its default thinks for long enough that a food
/// photo regularly ran past the 30s timeout.
///
/// Also sets [mediaResolution] when given — an image left at Gemini 3's
/// default is read at the highest (slowest) resolution.
///
/// If Google rejects either field (a 400 naming it), the request is sent
/// again without the rejected one — or, when only the thinking level's
/// value is unsupported ("Thinking level MINIMAL is not supported for this
/// model"), with the next level up — and this client keeps that from then
/// on, so later requests don't pay for a failed round trip first. One
/// client per model, so what one model rejects never changes another's.
class GeminiThinkingClient extends http.BaseClient {
  GeminiThinkingClient(this.level, {this.mediaResolution, http.Client? inner})
    : _inner = inner ?? http.Client(),
      _level = level;

  /// The level asked for — the least thinking, bumped up (or dropped) only
  /// if this client's model refuses it; null sends none (the model's
  /// default).
  final GeminiThinkingLevel? level;

  /// Applied to every request this client sends, until Google rejects it;
  /// null keeps Gemini's default.
  final GeminiMediaResolution? mediaResolution;

  final http.Client _inner;

  /// What's actually sent; null once the field itself is rejected.
  GeminiThinkingLevel? _level;
  bool _mediaResolutionRejected = false;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (request is! http.Request) {
      return _inner.send(request);
    }
    // Each pass raises the level or drops a field, so this always ends.
    while (true) {
      final tuned = withThinkingLevel(
        request.bodyBytes,
        _level,
        mediaResolution: _mediaResolutionRejected ? null : mediaResolution,
      );
      if (tuned == null) {
        return _inner.send(request);
      }
      final response = await _inner.send(_copy(request, tuned));
      if (response.statusCode != 400) {
        return response;
      }
      final body = await response.stream.toBytes();
      final error = utf8.decode(body, allowMalformed: true);
      if (!_adjustToRejection(error.toLowerCase())) {
        return _replay(response, body);
      }
      debugPrint(
        'Gemini rejected a tuning field; now sending thinking level '
        '${_level?.name ?? 'none'}: $error',
      );
    }
  }

  /// Adjusts what's sent to the field [error] (lowercased) rejects; false
  /// when it names nothing still being sent — then the 400 is about
  /// something else.
  bool _adjustToRejection(String error) {
    var dropped = false;
    final level = _level;
    if (level != null && error.contains('thinking')) {
      _level = _unsupportedLevel(error) ? _nextLevel(level) : null;
      dropped = true;
    }
    if (!_mediaResolutionRejected &&
        mediaResolution != null &&
        _mediaResolutionNames.any(error.contains)) {
      _mediaResolutionRejected = true;
      dropped = true;
    }
    return dropped;
  }

  /// Whether [error] refuses the level's value rather than the field.
  static bool _unsupportedLevel(String error) =>
      error.contains('thinking level') && error.contains('not supported');

  /// The next level up, or null past the highest.
  static GeminiThinkingLevel? _nextLevel(GeminiThinkingLevel level) =>
      level.index + 1 < GeminiThinkingLevel.values.length
      ? GeminiThinkingLevel.values[level.index + 1]
      : null;

  @override
  void close() {
    _inner.close();
    super.close();
  }

  /// How a 400 names `mediaResolution` (camelCase or snake_case,
  /// lowercased).
  static const List<String> _mediaResolutionNames = [
    'mediaresolution',
    'media_resolution',
  ];

  static http.Request _copy(http.Request original, List<int> body) =>
      http.Request(original.method, original.url)
        ..headers.addAll(original.headers)
        ..bodyBytes = body;

  static http.StreamedResponse _replay(
    http.StreamedResponse response,
    List<int> body,
  ) => http.StreamedResponse(
    Stream.value(body),
    response.statusCode,
    contentLength: body.length,
    request: response.request,
    headers: response.headers,
    reasonPhrase: response.reasonPhrase,
  );
}

/// [body] (a generateContent JSON request) with
/// `generationConfig.thinkingConfig.thinkingLevel` set to [level] and
/// `generationConfig.mediaResolution` to [mediaResolution] (each only when
/// given), or null when there's nothing to add or it isn't a JSON object
/// to add them to.
@visibleForTesting
List<int>? withThinkingLevel(
  List<int> body,
  GeminiThinkingLevel? level, {
  GeminiMediaResolution? mediaResolution,
}) {
  if (level == null && mediaResolution == null) {
    return null;
  }
  final Object? json;
  try {
    json = jsonDecode(utf8.decode(body));
  } on FormatException {
    return null;
  }
  if (json is! Map<String, dynamic>) {
    return null;
  }
  final config = switch (json['generationConfig']) {
    final Map<String, dynamic> existing => existing,
    _ => <String, dynamic>{},
  };
  json['generationConfig'] = {
    ...config,
    'thinkingConfig': ?switch (level) {
      final level? => {'thinkingLevel': level.name},
      null => null,
    },
    'mediaResolution': ?mediaResolution?.apiValue,
  };
  return utf8.encode(jsonEncode(json));
}
