import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/core/theme/app_theme.dart';
import 'package:mindful/features/money/domain/entry_type.dart';
import 'package:mindful/features/money/domain/money_entry.dart';
import 'package:mindful/features/money/presentation/money_detail_sheet.dart';
import 'package:mindful/shared/models/sync_status.dart';

final _spending = MoneyEntry(
  id: 'm1',
  userId: 'u1',
  type: EntryType.spending,
  amount: 12.5,
  category: 'Food',
  note: 'Lunch',
  date: DateTime(2026, 1, 1),
  createdAt: DateTime(2026, 1, 1),
  updatedAt: DateTime(2026, 1, 1),
  syncStatus: SyncStatus.synced,
);

void main() {
  Widget buildSheet(MoneyEntry entry) => ProviderScope(
    child: MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: MoneyDetailSheet(entry: entry)),
    ),
  );

  testWidgets('shows type badge, amount, category and note', (tester) async {
    await tester.pumpWidget(buildSheet(_spending));

    expect(find.text('Spending'), findsOneWidget);
    expect(find.text('-12.50'), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Lunch'), findsOneWidget);
  });

  testWidgets('the overflow menu offers Edit and Delete', (tester) async {
    await tester.pumpWidget(buildSheet(_spending));

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
  });
}
