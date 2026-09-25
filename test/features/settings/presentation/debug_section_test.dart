import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mindfull/features/settings/presentation/debug_section.dart';
import 'package:mindfull/shared/services/notification_service.dart';

class _MockNotificationService extends Mock implements NotificationService {}

void main() {
  late _MockNotificationService notificationService;

  setUp(() {
    notificationService = _MockNotificationService();
  });

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationServiceProvider.overrideWith(
            (ref) async => notificationService,
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: DebugSection())),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the schedule test notification button', (tester) async {
    await pump(tester);

    expect(
      find.widgetWithText(OutlinedButton, 'Schedule test notification (5 min)'),
      findsOneWidget,
    );
  });

  testWidgets(
    'tapping it schedules a test notification and confirms the time',
    (tester) async {
      when(
        () => notificationService.scheduleTestNotification(),
      ).thenAnswer((_) async => DateTime(2026, 1, 1, 20, 45));
      await pump(tester);

      await tester.tap(find.byType(OutlinedButton));
      await tester.pumpAndSettle();

      verify(() => notificationService.scheduleTestNotification()).called(1);
      // The exact formatted time is locale/ICU-data dependent in a test
      // environment — just confirm the confirmation text itself showed.
      expect(
        find.textContaining('Test notification scheduled for'),
        findsOneWidget,
      );
    },
  );

  testWidgets('shows an error SnackBar if scheduling fails', (tester) async {
    when(
      () => notificationService.scheduleTestNotification(),
    ).thenThrow(Exception('boom'));
    await pump(tester);

    await tester.tap(find.byType(OutlinedButton));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Could not schedule test notification'),
      findsOneWidget,
    );
  });
}
