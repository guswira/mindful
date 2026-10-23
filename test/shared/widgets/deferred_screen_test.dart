import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/core/theme/glass_theme.dart';
import 'package:mindful/l10n/generated/app_localizations.dart';
import 'package:mindful/shared/widgets/deferred_screen.dart';

Widget _app(DeferredScreen screen) => MaterialApp(
  theme: ThemeData(extensions: [GlassTheme.dark()]),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: screen,
);

void main() {
  testWidgets('builds the screen once loaded, spinner only if slow', (
    tester,
  ) async {
    final loading = Completer<void>();
    await tester.pumpWidget(
      _app(
        DeferredScreen(
          load: () => loading.future,
          builder: (_) => const Text('loaded'),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsNothing);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    loading.complete();
    await tester.pump();
    expect(find.text('loaded'), findsOneWidget);
  });

  testWidgets('a failed load offers a retry', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      _app(
        DeferredScreen(
          load: () async {
            calls++;
            if (calls == 1) {
              throw Exception('offline');
            }
          },
          builder: (_) => const Text('loaded'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text("Couldn't load this page. Check your connection."),
      findsOneWidget,
    );

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('loaded'), findsOneWidget);
    expect(calls, 2);
  });
}
