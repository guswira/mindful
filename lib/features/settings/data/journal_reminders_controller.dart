import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../shared/services/notification_service.dart';
import 'settings_repository.dart';

part 'journal_reminders_controller.g.dart';

/// Whether the journal's morning and evening reminders are on.
typedef JournalReminderState = ({bool morning, bool evening});

/// Reads and toggles the journal reminder settings, keeping the OS-level
/// notification schedule in sync with what's persisted.
@riverpod
class JournalReminders extends _$JournalReminders {
  @override
  Future<JournalReminderState> build() async {
    final repository = ref.watch(settingsRepositoryProvider);
    final morning = await repository.isJournalMorningReminderEnabled();
    final evening = await repository.isJournalEveningReminderEnabled();

    final service = await ref.watch(notificationServiceProvider.future);
    await service.setJournalMorningReminderEnabled(morning);
    await service.setJournalEveningReminderEnabled(evening);

    return (morning: morning, evening: evening);
  }

  /// Toggles the 8:00 AM reminder.
  Future<void> setMorningEnabled(bool enabled) async {
    final repository = ref.read(settingsRepositoryProvider);
    final service = await ref.read(notificationServiceProvider.future);
    await repository.setJournalMorningReminderEnabled(enabled);
    await service.setJournalMorningReminderEnabled(enabled);
    state = AsyncData((morning: enabled, evening: (await future).evening));
  }

  /// Toggles the 10:00 PM reminder.
  Future<void> setEveningEnabled(bool enabled) async {
    final repository = ref.read(settingsRepositoryProvider);
    final service = await ref.read(notificationServiceProvider.future);
    await repository.setJournalEveningReminderEnabled(enabled);
    await service.setJournalEveningReminderEnabled(enabled);
    state = AsyncData((morning: (await future).morning, evening: enabled));
  }
}
