import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindfull/features/settings/data/journal_reminders_controller.dart';
import 'package:mindfull/features/settings/presentation/settings_screen.dart';

class _FakeJournalReminders extends JournalReminders {
  _FakeJournalReminders(this._initial);

  JournalReminderState _initial;
  final morningCalls = <bool>[];
  final eveningCalls = <bool>[];

  @override
  Future<JournalReminderState> build() async => _initial;

  @override
  Future<void> setMorningEnabled(bool enabled) async {
    morningCalls.add(enabled);
    _initial = (morning: enabled, evening: _initial.evening);
    state = AsyncData(_initial);
  }

  @override
  Future<void> setEveningEnabled(bool enabled) async {
    eveningCalls.add(enabled);
    _initial = (morning: _initial.morning, evening: enabled);
    state = AsyncData(_initial);
  }
}

void main() {
  testWidgets('shows and toggles the morning and evening reminder switches', (
    tester,
  ) async {
    final fake = _FakeJournalReminders((morning: true, evening: false));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [journalRemindersProvider.overrideWith(() => fake)],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    final switches = tester
        .widgetList<SwitchListTile>(find.byType(SwitchListTile))
        .toList();
    expect(switches, hasLength(2));
    expect(switches[0].value, isTrue);
    expect(switches[1].value, isFalse);

    await tester.tap(find.byType(SwitchListTile).last);
    await tester.pumpAndSettle();

    expect(fake.eveningCalls, [true]);
    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile).last).value,
      isTrue,
    );
  });
}
