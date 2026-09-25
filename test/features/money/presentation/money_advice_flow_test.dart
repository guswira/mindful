import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mindfull/core/theme/app_theme.dart';
import 'package:mindfull/features/ai/domain/food_scan_exception.dart';
import 'package:mindfull/features/ai/presentation/food_scan_retry.dart';
import 'package:mindfull/features/money/data/money_repository.dart';
import 'package:mindfull/features/money/domain/entry_type.dart';
import 'package:mindfull/features/money/domain/money_advice.dart';
import 'package:mindfull/features/money/domain/money_entry.dart';
import 'package:mindfull/features/money/presentation/money_advice_flow.dart';
import 'package:mindfull/features/money/presentation/money_advice_sheet.dart';
import 'package:mindfull/shared/models/sync_status.dart';
import 'package:mindfull/shared/services/gemini_service.dart';
import 'package:mindfull/shared/services/notification_service.dart';

class _MockBox extends Mock implements Box<dynamic> {}

class _MockStorage extends Mock implements FlutterSecureStorage {}

class _MockGemini extends Mock implements GeminiService {}

class _MockNotifications extends Mock implements NotificationService {}

final _food = MoneyEntry(
  id: 'm1',
  userId: 'u1',
  type: EntryType.spending,
  amount: 12.5,
  category: 'Food',
  date: DateTime(2026, 9, 1),
  createdAt: DateTime(2026, 9, 1),
  updatedAt: DateTime(2026, 9, 1),
  syncStatus: SyncStatus.synced,
);

const _busy = FoodScanException('AI is busy', FoodScanErrorType.busy);

void main() {
  late _MockBox entriesBox;
  late _MockStorage storage;
  late _MockGemini gemini;
  late _MockNotifications notifications;

  setUp(() {
    entriesBox = _MockBox();
    storage = _MockStorage();
    gemini = _MockGemini();
    notifications = _MockNotifications();
    when(() => entriesBox.values).thenReturn([_food.toJson()]);
    when(
      () => storage.read(key: any(named: 'key')),
    ).thenAnswer((_) async => 'USD');
    when(
      () => notifications.showMoneyAdviceProgress(any()),
    ).thenAnswer((_) async {});
    when(
      () => notifications.showMoneyAdviceFailed(any()),
    ).thenAnswer((_) async {});
    when(
      () => notifications.cancelMoneyAdviceNotification(),
    ).thenAnswer((_) async {});
  });

  Widget buildApp() => ProviderScope(
    overrides: [
      moneyRepositoryProvider.overrideWith(
        (ref) async => MoneyRepository(
          entriesBox: entriesBox,
          settingsBox: _MockBox(),
          storage: storage,
        ),
      ),
      geminiServiceProvider.overrideWithValue(gemini),
      notificationServiceProvider.overrideWith((ref) async => notifications),
    ],
    child: MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => requestMoneyAdvice(context),
            child: const Text('advise'),
          ),
        ),
      ),
    ),
  );

  testWidgets('success shows progress, then the advice sheet', (tester) async {
    when(
      () => gemini.adviseOnMoney(any()),
    ).thenAnswer((_) async => const MoneyAdvice(summary: 'Mostly food.'));

    await tester.pumpWidget(buildApp());
    await tester.tap(find.text('advise'));
    await tester.pumpAndSettle();

    final summary =
        verify(() => gemini.adviseOnMoney(captureAny())).captured.single
            as String;
    expect(summary, contains('- Food: 12.50'));
    verify(
      () =>
          notifications.showMoneyAdviceProgress('Looking at your spending...'),
    ).called(1);
    verify(() => notifications.cancelMoneyAdviceNotification()).called(1);
    verifyNever(() => notifications.showMoneyAdviceFailed(any()));
    expect(find.byType(MoneyAdviceLoadingSheet), findsNothing);
    expect(find.text('Mostly food.'), findsOneWidget);
  });

  testWidgets('busy retries a minute apart, dismissing the loading sheet', (
    tester,
  ) async {
    var calls = 0;
    when(() => gemini.adviseOnMoney(any())).thenAnswer((_) async {
      calls++;
      if (calls == 1) {
        throw _busy;
      }
      return const MoneyAdvice(summary: 'Retried.');
    });

    await tester.pumpWidget(buildApp());
    await tester.tap(find.text('advise'));
    await tester.pumpAndSettle();

    expect(find.byType(MoneyAdviceLoadingSheet), findsNothing);
    verify(
      () => notifications.showMoneyAdviceProgress(
        'Google\'s servers are busy — retrying (attempt 2/5)…',
      ),
    ).called(1);

    await tester.pump(FoodScanRetryPolicy.delay);
    await tester.pumpAndSettle();

    expect(calls, 2);
    expect(find.text('Retried.'), findsOneWidget);
    verifyNever(() => notifications.showMoneyAdviceFailed(any()));
  });

  testWidgets('still busy after every attempt leaves a failure notification', (
    tester,
  ) async {
    when(() => gemini.adviseOnMoney(any())).thenThrow(_busy);

    await tester.pumpWidget(buildApp());
    await tester.tap(find.text('advise'));
    await tester.pumpAndSettle();
    for (var i = 1; i < FoodScanRetryPolicy.maxAttempts; i++) {
      await tester.pump(FoodScanRetryPolicy.delay);
      await tester.pumpAndSettle();
    }

    verify(
      () => gemini.adviseOnMoney(any()),
    ).called(FoodScanRetryPolicy.maxAttempts);
    verify(() => notifications.showMoneyAdviceFailed('AI is busy')).called(1);
    expect(find.text('AI is busy'), findsOneWidget);
  });

  testWidgets('a non-busy failure fails at once, with a SnackBar only', (
    tester,
  ) async {
    when(
      () => gemini.adviseOnMoney(any()),
    ).thenThrow(const FoodScanException('Bad key', FoodScanErrorType.apiError));

    await tester.pumpWidget(buildApp());
    await tester.tap(find.text('advise'));
    await tester.pumpAndSettle();

    verify(() => gemini.adviseOnMoney(any())).called(1);
    verifyNever(() => notifications.showMoneyAdviceFailed(any()));
    expect(find.byType(MoneyAdviceLoadingSheet), findsNothing);
    expect(find.text('Bad key'), findsOneWidget);
  });

  testWidgets('with no entries never calls Gemini', (tester) async {
    when(() => entriesBox.values).thenReturn(const <dynamic>[]);

    await tester.pumpWidget(buildApp());
    await tester.tap(find.text('advise'));
    await tester.pumpAndSettle();

    verifyNever(() => gemini.adviseOnMoney(any()));
    verifyNever(() => notifications.showMoneyAdviceProgress(any()));
    expect(
      find.text('Add some spending or income first to get advice.'),
      findsOneWidget,
    );
  });
}
