import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindfull/features/home/presentation/widgets/unsynced_banner.dart';

void main() {
  testWidgets('renders nothing when nothing is stale', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          hasStalePendingWritesProvider.overrideWith((ref) async => false),
        ],
        child: const MaterialApp(home: Scaffold(body: UnsyncedBanner())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text("Some changes haven't synced yet"), findsNothing);
  });

  testWidgets('shows a subtle banner when writes are stale', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          hasStalePendingWritesProvider.overrideWith((ref) async => true),
        ],
        child: const MaterialApp(home: Scaffold(body: UnsyncedBanner())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text("Some changes haven't synced yet"), findsOneWidget);
  });
}
