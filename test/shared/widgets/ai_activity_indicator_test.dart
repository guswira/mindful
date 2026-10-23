import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/core/theme/app_theme.dart';
import 'package:mindful/l10n/generated/app_localizations.dart';
import 'package:mindful/shared/services/ai_activity.dart';
import 'package:mindful/shared/widgets/ai_activity_indicator.dart';

void main() {
  Widget wrap(List<AiActivity> activities, {void Function(int)? onDismiss}) =>
      MaterialApp(
        theme: AppTheme.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: AiActivityIndicator(
            activities: activities,
            onDismiss: onDismiss ?? (_) {},
          ),
        ),
      );

  testWidgets('a running request shows a spinner and what it is doing', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(const [AiActivity(id: 0, kind: AiActivityKind.foodScan)]),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Analyzing your food...'), findsOneWidget);
  });

  testWidgets('a retry shows the attempt', (tester) async {
    await tester.pumpWidget(
      wrap(const [
        AiActivity(
          id: 0,
          kind: AiActivityKind.moneyAdvice,
          attempt: 2,
          maxAttempts: 5,
        ),
      ]),
    );

    expect(
      find.text('Looking at your spending... · attempt 2/5'),
      findsOneWidget,
    );
  });

  testWidgets('a ready result opens on tap and can be dismissed', (
    tester,
  ) async {
    var opened = 0;
    int? dismissed;
    await tester.pumpWidget(
      wrap([
        AiActivity(id: 7, kind: AiActivityKind.foodScan, open: () => opened++),
      ], onDismiss: (id) => dismissed = id),
    );

    expect(find.byType(CircularProgressIndicator), findsNothing);
    await tester.tap(find.text('Food result ready — tap to view'));
    expect(opened, 1);

    await tester.tap(find.byTooltip('Close'));
    expect(dismissed, 7);
  });

  testWidgets('shows nothing with no activity', (tester) async {
    await tester.pumpWidget(wrap(const []));

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(Text), findsNothing);
  });
}
