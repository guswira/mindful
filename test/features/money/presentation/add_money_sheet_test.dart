import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mindful/core/theme/app_theme.dart';
import 'package:mindful/features/auth/domain/auth_state.dart';
import 'package:mindful/features/money/data/money_repository.dart';
import 'package:mindful/features/money/domain/entry_type.dart';
import 'package:mindful/features/money/domain/money_entry.dart';
import 'package:mindful/features/money/presentation/add_money_sheet.dart';
import 'package:mindful/shared/models/sync_status.dart';
import 'package:mindful/shared/services/widget_service.dart';
import 'package:mindful/shared/widgets/shake_widget.dart';
import 'package:mindful/shared/widgets/tinted_pill.dart';

class _MockBox extends Mock implements Box<dynamic> {}

class _MockSecureStorage extends Mock implements FlutterSecureStorage {}

class _MockWidgetService extends Mock implements WidgetService {}

final _entry = MoneyEntry(
  id: 'm1',
  userId: 'u1',
  type: EntryType.income,
  amount: 50,
  category: 'Gift',
  date: DateTime(2026, 1, 1),
  createdAt: DateTime(2026, 1, 1),
  updatedAt: DateTime(2026, 1, 1),
  syncStatus: SyncStatus.synced,
);

void main() {
  late _MockBox entriesBox;
  late _MockBox settingsBox;
  late _MockSecureStorage storage;

  setUp(() {
    entriesBox = _MockBox();
    settingsBox = _MockBox();
    storage = _MockSecureStorage();
    when(
      () => storage.read(key: any(named: 'key')),
    ).thenAnswer((_) async => null);
  });

  Widget buildSheet({
    EntryType defaultType = EntryType.spending,
    MoneyEntry? entry,
  }) => ProviderScope(
    overrides: [
      moneyRepositoryProvider.overrideWith(
        (ref) async => MoneyRepository(
          entriesBox: entriesBox,
          settingsBox: settingsBox,
          storage: storage,
        ),
      ),
      currentUserIdProvider.overrideWithValue('u1'),
      // Avoids the save flow's best-effort widget refresh reaching real
      // (uninitialized) Hive boxes via journal/habit/task repositories.
      widgetServiceProvider.overrideWith((ref) async {
        final service = _MockWidgetService();
        when(() => service.updateWidgetData()).thenAnswer((_) async {});
        return service;
      }),
    ],
    child: MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: AddMoneySheet(defaultType: defaultType, entry: entry),
      ),
    ),
  );

  testWidgets(
    'defaults to spending: red pill active, spending categories shown',
    (tester) async {
      await tester.pumpWidget(buildSheet());

      expect(find.text('💸 Spending'), findsOneWidget);
      expect(find.text('💰 Income'), findsOneWidget);
      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Salary'), findsNothing);
      expect(find.widgetWithText(TintedPill, 'Save'), findsOneWidget);
    },
  );

  testWidgets('amount field defaults to the IDR currency prefix', (
    tester,
  ) async {
    await tester.pumpWidget(buildSheet());
    await tester.pumpAndSettle();

    expect(find.text('IDR'), findsOneWidget);
  });

  testWidgets('amount field prefixes with the configured budget currency', (
    tester,
  ) async {
    when(
      () => storage.read(key: any(named: 'key')),
    ).thenAnswer((_) async => 'USD');

    await tester.pumpWidget(buildSheet());
    await tester.pumpAndSettle();

    expect(find.text('USD'), findsOneWidget);
    expect(find.text('IDR'), findsNothing);
  });

  testWidgets('switching to income swaps the category list', (tester) async {
    await tester.pumpWidget(buildSheet());

    await tester.tap(find.text('💰 Income'));
    await tester.pump();

    expect(find.text('Salary'), findsOneWidget);
    expect(find.text('Food'), findsNothing);
  });

  testWidgets('tapping Save with no amount shakes the amount field', (
    tester,
  ) async {
    await tester.pumpWidget(buildSheet());

    await tester.tap(find.widgetWithText(TintedPill, 'Save'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final transform = tester.widget<Transform>(
      find.descendant(
        of: find.byType(ShakeWidget),
        matching: find.byType(Transform),
      ),
    );
    expect(transform.transform.getTranslation().x, isNot(0));
  });

  testWidgets('pre-fills fields and shows "Save changes" when editing', (
    tester,
  ) async {
    await tester.pumpWidget(buildSheet(entry: _entry));

    expect(find.text('Edit entry'), findsOneWidget);
    expect(find.text('50'), findsOneWidget);
    expect(find.widgetWithText(TintedPill, 'Save changes'), findsOneWidget);
  });

  testWidgets(
    'saving a new entry strips the leftover time-of-day from its default '
    'date, so it still lands in "today" ranges instead of reading as after '
    'midnight',
    (tester) async {
      when(() => entriesBox.put(any(), any())).thenAnswer((_) async {});

      await tester.pumpWidget(buildSheet());
      await tester.enterText(find.byType(TextField).first, '50000');
      await tester.tap(find.widgetWithText(TintedPill, 'Save'));
      await tester.pump();

      final captured = verify(
        () => entriesBox.put(any(), captureAny()),
      ).captured;
      final saved = MoneyEntry.fromJson(
        Map<String, dynamic>.from(captured.last as Map),
      );
      expect(
        saved.date,
        DateTime(saved.date.year, saved.date.month, saved.date.day),
      );
    },
  );
}
