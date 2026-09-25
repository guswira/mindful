import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:mindful/core/router/app_intent_actions.dart';

void main() {
  GoRouter buildRouter(String initialLocation) => GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const Text('splash')),
      GoRoute(path: '/home/today', builder: (_, _) => const Text('home')),
    ],
  );

  testWidgets('runs right away when already on a home tab', (tester) async {
    final router = buildRouter('/home/today');
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    var runs = 0;

    runWhenOnHome(router, () => runs++);

    expect(runs, 1);
  });

  testWidgets('waits for the redirect off the splash screen', (tester) async {
    final router = buildRouter('/splash');
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    var runs = 0;

    runWhenOnHome(router, () => runs++);
    await tester.pump();
    expect(runs, 0);

    router.go('/home/today');
    await tester.pumpAndSettle();
    expect(runs, 1);

    // Only once — the listener is removed after firing.
    router.go('/splash');
    await tester.pumpAndSettle();
    router.go('/home/today');
    await tester.pumpAndSettle();
    expect(runs, 1);
  });

  testWidgets('ignores unknown actions', (tester) async {
    final router = buildRouter('/home/today');
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    handleAppIntentAction(router, 'somethingElse');
    handleAppIntentAction(router, null);
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsNothing);
  });
}
