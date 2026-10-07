// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_tab.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$archivedHabitsHash() => r'7dd984ddd1993bf49784e7a640d6098e22e12740';

/// Archived habits, newest first — re-read whenever today's list reloads,
/// so archiving/restoring/deleting moves a habit between the two at once.
///
/// Copied from [archivedHabits].
@ProviderFor(archivedHabits)
final archivedHabitsProvider = AutoDisposeFutureProvider<List<Habit>>.internal(
  archivedHabits,
  name: r'archivedHabitsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$archivedHabitsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ArchivedHabitsRef = AutoDisposeFutureProviderRef<List<Habit>>;
String _$habitTabControllerHash() =>
    r'aa36602674b0a148ea8d9dc5dd757d34acab833d';

/// Loads today's active habits and their completion status, and logs new
/// completions to the cache (then Supabase, best-effort).
///
/// Copied from [HabitTabController].
@ProviderFor(HabitTabController)
final habitTabControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      HabitTabController,
      List<HabitTabItem>
    >.internal(
      HabitTabController.new,
      name: r'habitTabControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$habitTabControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$HabitTabController = AutoDisposeAsyncNotifier<List<HabitTabItem>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
