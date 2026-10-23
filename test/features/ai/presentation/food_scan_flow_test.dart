import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mindful/core/theme/app_theme.dart';
import 'package:mindful/features/ai/domain/food_analysis.dart';
import 'package:mindful/features/ai/domain/food_scan_exception.dart';
import 'package:mindful/features/ai/presentation/food_result_sheet.dart';
import 'package:mindful/features/ai/presentation/food_scan_flow.dart';
import 'package:mindful/features/ai/presentation/food_scan_retry.dart';
import 'package:mindful/shared/services/ai_activity.dart';
import 'package:mindful/shared/services/gemini_service.dart';
import 'package:mindful/shared/services/image_compression_service.dart';
import 'package:mindful/shared/services/notification_service.dart';

class _MockGemini extends Mock implements GeminiService {}

class _MockCompression extends Mock implements ImageCompressionService {}

class _MockNotifications extends Mock implements NotificationService {}

const _toast = FoodAnalysis(
  foodName: 'Toast',
  calories: 100,
  protein: 3,
  carbs: 20,
  fat: 2,
  fiber: 1,
  confidence: 'high',
);

final _photo = Uint8List.fromList([1, 2, 3]);

void main() {
  late _MockGemini gemini;
  late _MockCompression compression;
  late _MockNotifications notifications;

  setUpAll(() => registerFallbackValue(Uint8List(0)));

  setUp(() {
    gemini = _MockGemini();
    compression = _MockCompression();
    notifications = _MockNotifications();
    when(() => compression.compress(any())).thenAnswer((i) async => _photo);
    when(
      () => notifications.showFoodScanProgress(any()),
    ).thenAnswer((_) async {});
    when(
      () => notifications.showFoodScanFailed(any()),
    ).thenAnswer((_) async {});
    when(
      () => notifications.cancelFoodScanNotification(),
    ).thenAnswer((_) async {});
  });

  Widget buildApp() => ProviderScope(
    overrides: [
      geminiServiceProvider.overrideWithValue(gemini),
      imageCompressionServiceProvider.overrideWithValue(compression),
      notificationServiceProvider.overrideWith((ref) async => notifications),
    ],
    child: MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => scanFood(context, _photo),
            child: const Text('scan'),
          ),
        ),
      ),
    ),
  );

  List<AiActivity> activities(WidgetTester tester) => ProviderScope.containerOf(
    tester.element(find.text('scan')),
  ).read(aiActivityProvider);

  testWidgets('a result waits in the activity pill until opened', (
    tester,
  ) async {
    when(() => gemini.analyzeFood(any())).thenAnswer((_) async => _toast);

    await tester.pumpWidget(buildApp());
    await tester.tap(find.text('scan'));
    await tester.pumpAndSettle();

    expect(find.byType(FoodResultSheet), findsNothing);
    final ready = activities(tester).single;
    expect(ready.isReady, isTrue);
    verify(() => notifications.cancelFoodScanNotification()).called(1);

    ready.open!();
    await tester.pumpAndSettle();

    expect(find.byType(FoodResultSheet), findsOneWidget);
    expect(activities(tester), isEmpty);
  });

  testWidgets('a timeout retries, tracking the attempt', (tester) async {
    var calls = 0;
    when(() => gemini.analyzeFood(any())).thenAnswer((_) async {
      calls++;
      if (calls == 1) {
        throw const FoodScanException('slow', FoodScanErrorType.timeout);
      }
      return _toast;
    });

    await tester.pumpWidget(buildApp());
    await tester.tap(find.text('scan'));
    await tester.pumpAndSettle();

    expect(activities(tester).single.attempt, 2);
    await tester.pump(FoodScanRetryPolicy.delayBefore(2));
    await tester.pumpAndSettle();

    expect(calls, 2);
    expect(activities(tester).single.isReady, isTrue);
  });

  testWidgets('not food shows a SnackBar and clears the pill', (tester) async {
    when(() => gemini.analyzeFood(any())).thenAnswer((_) async => null);

    await tester.pumpWidget(buildApp());
    await tester.tap(find.text('scan'));
    await tester.pumpAndSettle();

    expect(
      find.text("Couldn't identify food. Try a clearer photo."),
      findsOneWidget,
    );
    expect(activities(tester), isEmpty);
  });

  testWidgets('a final failure without a retry shows a SnackBar only', (
    tester,
  ) async {
    when(
      () => gemini.analyzeFood(any()),
    ).thenThrow(const FoodScanException('Bad key', FoodScanErrorType.apiError));

    await tester.pumpWidget(buildApp());
    await tester.tap(find.text('scan'));
    await tester.pumpAndSettle();

    expect(find.text('Bad key'), findsOneWidget);
    verifyNever(() => notifications.showFoodScanFailed(any()));
    expect(activities(tester), isEmpty);
  });
}
