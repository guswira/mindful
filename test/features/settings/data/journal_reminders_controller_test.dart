import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mindful/core/l10n/app_language.dart';
import 'package:mindful/features/settings/data/journal_reminders_controller.dart';
import 'package:mindful/features/settings/data/settings_repository.dart';
import 'package:mindful/shared/services/notification_service.dart';

class _FakeSettingsRepository implements SettingsRepository {
  bool morning = true;
  bool evening = false;

  @override
  Future<bool> isJournalMorningReminderEnabled() async => morning;

  @override
  Future<bool> isJournalEveningReminderEnabled() async => evening;

  @override
  Future<void> setJournalMorningReminderEnabled(bool enabled) async {
    morning = enabled;
  }

  @override
  Future<void> setJournalEveningReminderEnabled(bool enabled) async {
    evening = enabled;
  }

  @override
  Future<AppLanguage> readAppLanguage() async => AppLanguage.system;

  @override
  Future<void> writeAppLanguage(AppLanguage language) async {}
}

class _MockNotificationService extends Mock implements NotificationService {}

void main() {
  late _FakeSettingsRepository repository;
  late _MockNotificationService notificationService;
  late ProviderContainer container;

  setUp(() {
    repository = _FakeSettingsRepository();
    notificationService = _MockNotificationService();

    when(
      () => notificationService.setJournalMorningReminderEnabled(any()),
    ).thenAnswer((_) async {});
    when(
      () => notificationService.setJournalEveningReminderEnabled(any()),
    ).thenAnswer((_) async {});

    container = ProviderContainer(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(repository),
        notificationServiceProvider.overrideWith(
          (ref) async => notificationService,
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  test(
    'build reads persisted state and applies it to the OS scheduler',
    () async {
      final state = await container.read(journalRemindersProvider.future);

      expect(state.morning, isTrue);
      expect(state.evening, isFalse);
      verify(
        () => notificationService.setJournalMorningReminderEnabled(true),
      ).called(1);
      verify(
        () => notificationService.setJournalEveningReminderEnabled(false),
      ).called(1);
    },
  );

  test('setMorningEnabled persists and reschedules', () async {
    await container.read(journalRemindersProvider.future);
    await container
        .read(journalRemindersProvider.notifier)
        .setMorningEnabled(false);

    expect(repository.morning, isFalse);
    verify(
      () => notificationService.setJournalMorningReminderEnabled(false),
    ).called(1);

    final state = await container.read(journalRemindersProvider.future);
    expect(state.morning, isFalse);
  });

  test('setEveningEnabled persists and reschedules', () async {
    await container.read(journalRemindersProvider.future);
    await container
        .read(journalRemindersProvider.notifier)
        .setEveningEnabled(true);

    expect(repository.evening, isTrue);
    verify(
      () => notificationService.setJournalEveningReminderEnabled(true),
    ).called(1);

    final state = await container.read(journalRemindersProvider.future);
    expect(state.evening, isTrue);
  });
}
