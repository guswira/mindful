import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:mindful/features/recap/domain/recap_window.dart';
import 'package:mindful/features/settings/presentation/monthly_recap_section.dart';

void main() {
  testWidgets('picking a month opens that month\'s recap', (tester) async {
    final opened = <String>[];
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) =>
              const Scaffold(body: MonthlyRecapSection()),
        ),
        GoRoute(
          path: '/recap/:month',
          builder: (context, state) {
            opened.add(state.pathParameters['month']!);
            return const SizedBox.shrink();
          },
        ),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    await tester.tap(find.text('Revisit a monthly recap'));
    await tester.pumpAndSettle();

    expect(find.text('Pick a month'), findsOneWidget);
    expect(find.textContaining('(so far)'), findsOneWidget);

    final lastMonth = DateTime(DateTime.now().year, DateTime.now().month - 1);
    await tester.tap(find.text(DateFormat.yMMMM().format(lastMonth)));
    await tester.pumpAndSettle();

    expect(opened, [recapMonthKey(lastMonth)]);
  });
}
