import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:mindful/shared/services/gemini_thinking_client.dart';

Map<String, dynamic> _decode(List<int> body) =>
    jsonDecode(utf8.decode(body)) as Map<String, dynamic>;

List<int> _encode(Map<String, dynamic> json) => utf8.encode(jsonEncode(json));

void main() {
  group('withThinkingLevel', () {
    test('adds thinkingConfig, keeping the rest of generationConfig', () {
      final tuned = withThinkingLevel(
        _encode({
          'contents': <Object>[],
          'generationConfig': {'responseMimeType': 'application/json'},
        }),
        GeminiThinkingLevel.minimal,
      );

      expect(_decode(tuned!)['generationConfig'], {
        'responseMimeType': 'application/json',
        'thinkingConfig': {'thinkingLevel': 'minimal'},
      });
    });

    test('creates generationConfig when the request has none', () {
      final tuned = withThinkingLevel(
        _encode({'contents': <Object>[]}),
        GeminiThinkingLevel.low,
      );

      expect(_decode(tuned!)['generationConfig'], {
        'thinkingConfig': {'thinkingLevel': 'low'},
      });
    });

    test('adds mediaResolution when given', () {
      final tuned = withThinkingLevel(
        _encode({'contents': <Object>[]}),
        GeminiThinkingLevel.minimal,
        mediaResolution: GeminiMediaResolution.medium,
      );

      expect(_decode(tuned!)['generationConfig'], {
        'thinkingConfig': {'thinkingLevel': 'minimal'},
        'mediaResolution': 'MEDIA_RESOLUTION_MEDIUM',
      });
    });

    test('leaves a body that is not a JSON object alone', () {
      expect(
        withThinkingLevel(utf8.encode('nope'), GeminiThinkingLevel.low),
        isNull,
      );
    });
  });

  group('GeminiThinkingClient', () {
    test('sends the thinking level with the request', () async {
      late Map<String, dynamic> sent;
      final client = GeminiThinkingClient(
        GeminiThinkingLevel.minimal,
        inner: MockClient((request) async {
          sent = _decode(request.bodyBytes);
          return http.Response('{}', 200);
        }),
      );

      await client.post(
        Uri.parse('https://example.com/v1beta/models/m:generateContent'),
        body: jsonEncode({'contents': <Object>[]}),
      );

      expect(sent['generationConfig'], {
        'thinkingConfig': {'thinkingLevel': 'minimal'},
      });
    });

    test('resends without it when Google rejects the field', () async {
      final bodies = <Map<String, dynamic>>[];
      final client = GeminiThinkingClient(
        GeminiThinkingLevel.low,
        inner: MockClient((request) async {
          bodies.add(_decode(request.bodyBytes));
          return bodies.length == 1
              ? http.Response(
                  '{"error":{"message":"Unknown thinking_level"}}',
                  400,
                )
              : http.Response('{}', 200);
        }),
      );

      final response = await client.post(
        Uri.parse('https://example.com/v1beta/models/m:generateContent'),
        body: jsonEncode({'contents': <Object>[]}),
      );

      expect(response.statusCode, 200);
      expect(bodies, hasLength(2));
      expect(bodies.last.containsKey('generationConfig'), isFalse);
    });

    test('resends without it when Google rejects mediaResolution', () async {
      final bodies = <Map<String, dynamic>>[];
      final client = GeminiThinkingClient(
        GeminiThinkingLevel.minimal,
        mediaResolution: GeminiMediaResolution.medium,
        inner: MockClient((request) async {
          bodies.add(_decode(request.bodyBytes));
          return bodies.length == 1
              ? http.Response(
                  '{"error":{"message":"Unknown name \\"mediaResolution\\""}}',
                  400,
                )
              : http.Response('{}', 200);
        }),
      );

      final response = await client.post(
        Uri.parse('https://example.com/v1beta/models/m:generateContent'),
        body: jsonEncode({'contents': <Object>[]}),
      );

      expect(response.statusCode, 200);
      expect(
        (bodies.last['generationConfig'] as Map).containsKey('mediaResolution'),
        isFalse,
      );
    });

    test('stops sending a rejected field on later requests', () async {
      final bodies = <Map<String, dynamic>>[];
      final client = GeminiThinkingClient(
        GeminiThinkingLevel.minimal,
        inner: MockClient((request) async {
          bodies.add(_decode(request.bodyBytes));
          return bodies.length == 1
              ? http.Response(
                  '{"error":{"message":"Unknown thinking_level"}}',
                  400,
                )
              : http.Response('{}', 200);
        }),
      );
      final url = Uri.parse(
        'https://example.com/v1beta/models/m:generateContent',
      );

      await client.post(url, body: jsonEncode({'contents': <Object>[]}));
      await client.post(url, body: jsonEncode({'contents': <Object>[]}));

      // 400 + resend, then straight through: no failed call the 2nd time.
      expect(bodies, hasLength(3));
      expect(bodies.last.containsKey('generationConfig'), isFalse);
    });

    test('an unsupported level steps up to the next one', () async {
      final bodies = <Map<String, dynamic>>[];
      final client = GeminiThinkingClient(
        GeminiThinkingLevel.minimal,
        inner: MockClient((request) async {
          bodies.add(_decode(request.bodyBytes));
          return bodies.length == 1
              ? http.Response(
                  '{"error":{"code":400,"message":"Thinking level MINIMAL is '
                  'not supported for this model. Please retry with other '
                  'thinking level.","status":"INVALID_ARGUMENT"}}',
                  400,
                )
              : http.Response('{}', 200);
        }),
      );
      final url = Uri.parse(
        'https://example.com/v1beta/models/m:generateContent',
      );

      await client.post(url, body: jsonEncode({'contents': <Object>[]}));
      await client.post(url, body: jsonEncode({'contents': <Object>[]}));

      expect(bodies, hasLength(3));
      for (final body in bodies.skip(1)) {
        expect(body['generationConfig'], {
          'thinkingConfig': {'thinkingLevel': 'low'},
        });
      }
    });

    test('drops only the field Google names', () async {
      final bodies = <Map<String, dynamic>>[];
      final client = GeminiThinkingClient(
        GeminiThinkingLevel.minimal,
        mediaResolution: GeminiMediaResolution.medium,
        inner: MockClient((request) async {
          bodies.add(_decode(request.bodyBytes));
          return bodies.length == 1
              ? http.Response(
                  '{"error":{"message":"Invalid media_resolution"}}',
                  400,
                )
              : http.Response('{}', 200);
        }),
      );

      await client.post(
        Uri.parse('https://example.com/v1beta/models/m:generateContent'),
        body: jsonEncode({'contents': <Object>[]}),
      );

      expect(bodies.last['generationConfig'], {
        'thinkingConfig': {'thinkingLevel': 'minimal'},
      });
    });

    test('passes any other 400 through untouched', () async {
      var calls = 0;
      final client = GeminiThinkingClient(
        GeminiThinkingLevel.low,
        inner: MockClient((request) async {
          calls++;
          return http.Response('{"error":{"message":"INVALID_ARGUMENT"}}', 400);
        }),
      );

      final response = await client.post(
        Uri.parse('https://example.com/v1beta/models/m:generateContent'),
        body: jsonEncode({'contents': <Object>[]}),
      );

      expect(response.statusCode, 400);
      expect(response.body, contains('INVALID_ARGUMENT'));
      expect(calls, 1);
    });
  });
}
