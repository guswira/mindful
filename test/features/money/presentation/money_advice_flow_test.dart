import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mindful/core/theme/app_theme.dart';
import 'package:mindful/features/ai/domain/food_scan_exception.dart';
import 'package:mindful/features/ai/presentation/food_scan_retry.dart';
import 'package:mindful/features/money/data/money_repository.dart';
import 'package:mindful/features/money/domain/entry_type.dart';
import 'package:mindful/features/money/domain/money_advice.dart';
import 'package:mindful/features/money/domain/money_entry.dart';
import 'package:mindful/features/money/presentation/money_advice_flow.dart';
import 'package:mindful/shared/models/sync_status.dart';
import 'package:mindful/shared/services/ai_activity.dart';
import 'package:mindful/shared/services/gemini_service.dart';
import 'package:mindful/shared/services/notification_service.dart';

class _MockBox extends Mock implements Box<dynamic> {}

class _MockStorage extends Mock implements FlutterSecureStorage {}

class _MockGemini extends Mock implements GeminiService {}

class _MockNotifications extends Mock implements NotificationService {}

// Today, so it's inside the Money tab's default period (This Month).
final _today = DateTime(
  DateTime.now().year,
  DateTime.now().month,
  DateTime.now().day,
);

final _food = MoneyEntry(
  id: 'm1',
  userId: 'u1',
  type: EntryType.spending,
  amount: 12.5,
  category: 'Food',
  date: _today,
  createdAt: _today,
  updatedAt: _today,
  syncStatus: SyncStatus.synced,
);

final _oldFood = _food.copyWith(
  id: 'm0',
  amount: 99,
  date: DateTime(_today.year - 1, 1, 1),
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

  List<AiActivity> activities(WidgetTester tester) => ProviderScope.containerOf(
    tester.element(find.text('advise')),
  ).read(aiActivityProvider);

  /// Taps the "ready" pill the way the app-wide indicator would.
  Future<void> openReady(WidgetTester tester) async {
    final ready = activities(tester).single;
    expect(ready.isReady, isTrue);
    ready.open!();
    await tester.pumpAndSettle();
  }

  testWidgets('success shows progress, then offers the advice', (tester) async {
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
    // Never pops over the screen on its own — only once opened.
    expect(find.text('Mostly food.'), findsNothing);

    await openReady(tester);

    expect(find.text('Mostly food.'), findsOneWidget);
    expect(activities(tester), isEmpty);
  });

  testWidgets('sends only the selected period\'s entries', (tester) async {
    when(
      () => entriesBox.values,
    ).thenReturn([_food.toJson(), _oldFood.toJson()]);
    when(
      () => gemini.adviseOnMoney(any()),
    ).thenAnswer((_) async => const MoneyAdvice(summary: 'ok'));

    await tester.pumpWidget(buildApp());
    await tester.tap(find.text('advise'));
    await tester.pumpAndSettle();

    final summary =
        verify(() => gemini.adviseOnMoney(captureAny())).captured.single
            as String;
    expect(summary, contains('Total spending: 12.50'));
    expect(summary, isNot(contains('99.00')));
  });

  testWidgets('busy retries after a wait, tracking the attempt', (
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

    expect(activities(tester).single.attempt, 2);
    verify(
      () => notifications.showMoneyAdviceProgress(
        'Google\'s servers are busy — retrying (attempt 2/5)…',
      ),
    ).called(1);

    await tester.pump(FoodScanRetryPolicy.delayBefore(2));
    await tester.pumpAndSettle();

    expect(calls, 2);
    await openReady(tester);
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
    for (var i = 2; i <= FoodScanRetryPolicy.maxAttempts; i++) {
      await tester.pump(FoodScanRetryPolicy.delayBefore(i));
      await tester.pumpAndSettle();
    }

    verify(
      () => gemini.adviseOnMoney(any()),
    ).called(FoodScanRetryPolicy.maxAttempts);
    verify(() => notifications.showMoneyAdviceFailed('AI is busy')).called(1);
    expect(find.text('AI is busy'), findsOneWidget);
    expect(activities(tester), isEmpty);
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
    expect(find.text('Bad key'), findsOneWidget);
    expect(activities(tester), isEmpty);
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
