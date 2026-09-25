import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/core/theme/app_theme.dart';
import 'package:mindful/features/ai/data/food_scan_repository.dart';
import 'package:mindful/features/ai/domain/food_scan.dart';
import 'package:mindful/features/ai/presentation/ai_tab.dart';

final _scan = FoodScan(
  id: 's1',
  userId: 'u1',
  scannedAt: DateTime(2026, 1, 1, 12),
  foodName: 'Fried Rice',
  calories: 550,
);

void main() {
  Widget buildTab({List<FoodScan> scans = const []}) => ProviderScope(
    overrides: [recentScansProvider.overrideWith((ref) async => scans)],
    child: MaterialApp(theme: AppTheme.dark, home: const AITab()),
  );

  testWidgets('shows the experimental banner and food checker card', (
    tester,
  ) async {
    await tester.pumpWidget(buildTab());
    await tester.pumpAndSettle();

    expect(find.text('Experimental AI Features'), findsOneWidget);
    expect(find.text('Food Calorie Checker'), findsOneWidget);
    expect(find.text('📷  Check food calories'), findsOneWidget);
  });

  testWidgets('no scans yet shows the empty-state message', (tester) async {
    await tester.pumpWidget(buildTab());
    await tester.pumpAndSettle();

    expect(
      find.text('No scans yet. Try scanning your next meal!'),
      findsOneWidget,
    );
  });

  testWidgets('with scans shows a FoodScanCard per scan', (tester) async {
    await tester.pumpWidget(buildTab(scans: [_scan]));
    await tester.pumpAndSettle();

    expect(find.text('Fried Rice'), findsOneWidget);
    expect(find.text('550'), findsOneWidget);
  });
}
