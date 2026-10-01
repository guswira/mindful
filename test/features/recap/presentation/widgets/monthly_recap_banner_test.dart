import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/core/theme/glass_theme.dart';
import 'package:mindful/features/recap/presentation/monthly_recap_providers.dart';
import 'package:mindful/features/recap/presentation/widgets/monthly_recap_banner.dart';

Future<void> _pump(WidgetTester tester, DateTime? month) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [monthlyRecapBannerMonthProvider.overrideWith((ref) => month)],
      child: MaterialApp(
        theme: ThemeData(extensions: [GlassTheme.dark()]),
        home: const Scaffold(body: MonthlyRecapHomeBanner()),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the finished month with no way to dismiss it', (
    tester,
  ) async {
    await _pump(tester, DateTime(2020, 9));

    expect(find.text('Your September recap is ready'), findsOneWidget);
    expect(find.byType(IconButton), findsNothing);
  });

  testWidgets('renders nothing outside the recap window', (tester) async {
    await _pump(tester, null);

    expect(find.textContaining('recap'), findsNothing);
  });
}
