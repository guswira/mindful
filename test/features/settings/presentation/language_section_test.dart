import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindfull/core/l10n/app_language.dart';
import 'package:mindfull/core/l10n/app_language_controller.dart';
import 'package:mindfull/features/settings/data/journal_reminders_controller.dart';
import 'package:mindfull/features/settings/data/settings_repository.dart';
import 'package:mindfull/features/settings/presentation/settings_screen.dart';

class _FakeJournalReminders extends JournalReminders {
  @override
  Future<JournalReminderState> build() async => (morning: true, evening: true);
}

class _FakeSettingsRepository extends Fake implements SettingsRepository {
  final writtenLanguages = <AppLanguage>[];

  @override
  Future<void> writeAppLanguage(AppLanguage language) async {
    writtenLanguages.add(language);
  }
}

void main() {
  testWidgets('picking Bahasa Indonesia selects and persists it', (
    tester,
  ) async {
    final repository = _FakeSettingsRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          journalRemindersProvider.overrideWith(_FakeJournalReminders.new),
          settingsRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Language'), findsOneWidget);
    expect(find.textContaining('System default'), findsOneWidget);

    await tester.tap(find.text('Language'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Bahasa Indonesia'));
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(SettingsScreen)),
    );
    expect(container.read(appLanguageControllerProvider), AppLanguage.bahasa);
    expect(repository.writtenLanguages, [AppLanguage.bahasa]);
    expect(find.text('Bahasa Indonesia'), findsOneWidget);
  });
}
