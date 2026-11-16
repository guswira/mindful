import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:mindful/features/ai/domain/food_scan_exception.dart';
import 'package:mindful/shared/services/gemini_service.dart';

const _advice = '{"summary":"Mostly food."}';

http.Response _reply(String text) => http.Response(
  jsonEncode({
    'candidates': [
      {
        'content': {
          'role': 'model',
          'parts': [
            {'text': text},
          ],
        },
      },
    ],
  }),
  200,
);

http.Response _error(int code, String message) => http.Response(
  jsonEncode({
    'error': {'code': code, 'message': message},
  }),
  code,
);

final _overloaded = _error(
  503,
  'This model is currently experiencing high demand. Please try again later.',
);

/// A model whose every request is answered by [respond], counting calls.
GenerativeModel _model(String name, http.Response Function() respond) =>
    GenerativeModel(
      model: name,
      apiKey: 'test',
      httpClient: MockClient((_) async => respond()),
    );

void main() {
  late int primaryCalls;
  late int fallbackCalls;
  late int lastCalls;

  setUp(() {
    primaryCalls = 0;
    fallbackCalls = 0;
    lastCalls = 0;
  });

  GeminiService service({
    required http.Response Function() primary,
    required http.Response Function() fallback,
    http.Response Function()? last,
  }) {
    GenerativeModel counted(
      String name,
      http.Response Function() respond,
      void Function() count,
    ) => _model(name, () {
      count();
      return respond();
    });
    final models = [
      counted('main', primary, () => primaryCalls++),
      counted('backup', fallback, () => fallbackCalls++),
      if (last != null) counted('last', last, () => lastCalls++),
    ];
    return GeminiService.withModels(food: models, advice: models);
  }

  test('an answer from the main model never touches the fallback', () async {
    final gemini = service(
      primary: () => _reply(_advice),
      fallback: () => _reply('{"summary":"backup"}'),
    );

    final advice = await gemini.adviseOnMoney('data');

    expect(advice.summary, 'Mostly food.');
    expect(fallbackCalls, 0);
  });

  test('an overloaded main model is answered by the fallback', () async {
    final gemini = service(
      primary: () => _overloaded,
      fallback: () => _reply(_advice),
    );

    final advice = await gemini.adviseOnMoney('data');

    expect(advice.summary, 'Mostly food.');
    expect((primaryCalls, fallbackCalls), (1, 1));
  });

  test('both overloaded → still busy, so the caller retries', () async {
    final gemini = service(
      primary: () => _overloaded,
      fallback: () => _overloaded,
    );

    await expectLater(
      gemini.adviseOnMoney('data'),
      throwsA(
        isA<FoodScanException>().having(
          (e) => e.type,
          'type',
          FoodScanErrorType.busy,
        ),
      ),
    );
  });

  test('a failing fallback keeps the main model\'s busy error', () async {
    final gemini = service(
      primary: () => _overloaded,
      fallback: () => _error(404, 'models/backup is not found'),
    );

    await expectLater(
      gemini.adviseOnMoney('data'),
      throwsA(
        isA<FoodScanException>().having(
          (e) => e.type,
          'type',
          FoodScanErrorType.busy,
        ),
      ),
    );
  });

  test('a quota error moves on to the next model too', () async {
    final gemini = service(
      primary: () => _error(429, 'RESOURCE_EXHAUSTED: quota exceeded'),
      fallback: () => _reply(_advice),
    );

    final advice = await gemini.adviseOnMoney('data');

    expect(advice.summary, 'Mostly food.');
    expect(fallbackCalls, 1);
  });

  test('walks the whole list until a model answers', () async {
    final gemini = service(
      primary: () => _overloaded,
      fallback: () => _error(404, 'NOT_FOUND: models/backup'),
      last: () => _reply(_advice),
    );

    final advice = await gemini.adviseOnMoney('data');

    expect(advice.summary, 'Mostly food.');
    expect((primaryCalls, fallbackCalls, lastCalls), (1, 1, 1));
  });

  test('any other error stops without trying the next model', () async {
    final gemini = service(
      primary: () => _error(400, 'INVALID_ARGUMENT: bad request'),
      fallback: () => _reply(_advice),
    );

    await expectLater(
      gemini.adviseOnMoney('data'),
      throwsA(
        isA<FoodScanException>().having(
          (e) => e.type,
          'type',
          FoodScanErrorType.apiError,
        ),
      ),
    );
    expect(fallbackCalls, 0);
  });
}
