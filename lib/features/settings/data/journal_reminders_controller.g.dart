// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journal_reminders_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$journalRemindersHash() => r'44ba94d5b5ad2ec304d6eca968ec1a08bc6d0a6a';

/// Reads and toggles the journal reminder settings, keeping the OS-level
/// notification schedule in sync with what's persisted.
///
/// Copied from [JournalReminders].
@ProviderFor(JournalReminders)
final journalRemindersProvider =
    AutoDisposeAsyncNotifierProvider<
      JournalReminders,
      JournalReminderState
    >.internal(
      JournalReminders.new,
      name: r'journalRemindersProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$journalRemindersHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$JournalReminders = AutoDisposeAsyncNotifier<JournalReminderState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
