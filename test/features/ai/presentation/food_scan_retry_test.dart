import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/features/ai/domain/food_analysis.dart';
import 'package:mindful/features/ai/domain/food_scan_exception.dart';
import 'package:mindful/features/ai/presentation/food_scan_retry.dart';

const _analysis = FoodAnalysis(
  foodName: 'Toast',
  calories: 100,
  protein: 3,
  carbs: 20,
  fat: 2,
  fiber: 1,
  confidence: 'high',
);

const _busy = FoodScanException(
  "Google's servers are busy.",
  FoodScanErrorType.busy,
);
const _notBusy = FoodScanException(
  'Invalid Gemini API key.',
  FoodScanErrorType.apiError,
);

void main() {
  group('runWithRetry', () {
    test('returns the result on the first try without retrying', () async {
      var retries = 0;

      final result = await runWithRetry(
        attempt: () async => _analysis,
        onRetry: (_) async => retries++,
      );

      expect(result, _analysis);
      expect(retries, 0);
    });

    test('retries a busy failure until it succeeds', () async {
      var calls = 0;
      final retriedAttempts = <int>[];

      final result = await runWithRetry(
        attempt: () async {
          calls++;
          if (calls < 3) {
            throw _busy;
          }
          return _analysis;
        },
        onRetry: (attempt) async => retriedAttempts.add(attempt),
        delay: Duration.zero,
        maxAttempts: 5,
      );

      expect(result, _analysis);
      expect(calls, 3);
      expect(retriedAttempts, [2, 3]);
    });

    test('does not retry a non-busy failure', () async {
      var retries = 0;

      await expectLater(
        runWithRetry(
          attempt: () async => throw _notBusy,
          onRetry: (_) async => retries++,
          delay: Duration.zero,
          maxAttempts: 5,
        ),
        throwsA(_notBusy),
      );
      expect(retries, 0);
    });

    test('gives up and rethrows once maxAttempts is reached', () async {
      var calls = 0;
      var retries = 0;

      await expectLater(
        runWithRetry(
          attempt: () async {
            calls++;
            throw _busy;
          },
          onRetry: (_) async => retries++,
          delay: Duration.zero,
          maxAttempts: 3,
        ),
        throwsA(_busy),
      );
      expect(calls, 3);
      expect(retries, 2);
    });
  });

  group('foodScanMessage', () {
    test('busy and apiError pass GeminiService\'s own message through', () {
      expect(foodScanMessage(_busy), _busy.message);
      expect(foodScanMessage(_notBusy), _notBusy.message);
    });

    test('the other types use a fixed, user-facing message', () {
      expect(
        foodScanMessage(
          const FoodScanException('raw', FoodScanErrorType.notFood),
        ),
        "Couldn't identify food. Try a clearer photo.",
      );
      expect(
        foodScanMessage(
          const FoodScanException('raw', FoodScanErrorType.networkError),
        ),
        'No connection. Check your internet.',
      );
      expect(
        foodScanMessage(
          const FoodScanException('raw', FoodScanErrorType.timeout),
        ),
        'Request timed out. Try again.',
      );
    });
  });
}
