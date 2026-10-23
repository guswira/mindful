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
/// If Google ever rejects either field (400 naming it), the request is sent
/// once more without them, so a model that doesn't know them still
/// answers — just slower.
class GeminiThinkingClient extends http.BaseClient {
  GeminiThinkingClient(this.level, {this.mediaResolution, http.Client? inner})
    : _inner = inner ?? http.Client();

  /// Applied to every request this client sends.
  final GeminiThinkingLevel level;

  /// Applied to every request this client sends; null keeps Gemini's
  /// default.
  final GeminiMediaResolution? mediaResolution;

  final http.Client _inner;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (request is! http.Request) {
      return _inner.send(request);
    }
    final tuned = withThinkingLevel(
      request.bodyBytes,
      level,
      mediaResolution: mediaResolution,
    );
    if (tuned == null) {
      return _inner.send(request);
    }
    final response = await _inner.send(_copy(request, tuned));
    if (response.statusCode != 400) {
      return response;
    }
    final body = await response.stream.toBytes();
    final error = utf8.decode(body, allowMalformed: true).toLowerCase();
    if (!_tunedFields.any(error.contains)) {
      return _replay(response, body);
    }
    debugPrint('Gemini rejected a tuning field; retrying without them');
    return _inner.send(_copy(request, request.bodyBytes));
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }

  /// How a 400 names the fields this client adds (camelCase or
  /// snake_case, lowercased).
  static const List<String> _tunedFields = [
    'thinking',
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
/// `generationConfig.thinkingConfig.thinkingLevel` set to [level] (and
/// `generationConfig.mediaResolution` when [mediaResolution] is given), or
/// null when it isn't a JSON object to add them to.
@visibleForTesting
List<int>? withThinkingLevel(
  List<int> body,
  GeminiThinkingLevel level, {
  GeminiMediaResolution? mediaResolution,
}) {
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
    'thinkingConfig': {'thinkingLevel': level.name},
    'mediaResolution': ?mediaResolution?.apiValue,
  };
  return utf8.encode(jsonEncode(json));
}
