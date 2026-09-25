// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_reminders_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$habitRemindersHash() => r'e1828a3b20d0b00aa36912d711c59a5721fc1b64';

/// Re-schedules every active habit's reminder on app start.
///
/// Unlike the journal's reminders (see `JournalReminders`), a habit's
/// reminder is otherwise only ever (re)scheduled once, at the moment its
/// Add/Edit sheet is saved — nothing re-arms it afterward. If the OS ever
/// drops a previously scheduled alarm (the app was force-stopped, an OEM
/// battery manager killed it, ...), it would stay silently unscheduled
/// until the user happened to re-open and re-save that exact habit. This
/// runs the same reconciliation the journal reminders get, for every habit
/// that should currently have one.
///
/// Best-effort: this runs unconditionally at every app start (see
/// router.dart), before anything's confirmed the cache is even reachable —
/// a failure here shouldn't crash startup, just skip reconciling this once.
///
/// Copied from [habitReminders].
@ProviderFor(habitReminders)
final habitRemindersProvider = AutoDisposeFutureProvider<void>.internal(
  habitReminders,
  name: r'habitRemindersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$habitRemindersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HabitRemindersRef = AutoDisposeFutureProviderRef<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
