// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$breathingSessionsHash() => r'13f7f1b4332645909e242f2b90729585b1176ecb';

/// Every cached breathing session, newest first. Invalidate after saving
/// one so the tab's stats and calendar pick it up.
///
/// Copied from [breathingSessions].
@ProviderFor(breathingSessions)
final breathingSessionsProvider =
    AutoDisposeFutureProvider<List<BreathingSession>>.internal(
      breathingSessions,
      name: r'breathingSessionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$breathingSessionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BreathingSessionsRef =
    AutoDisposeFutureProviderRef<List<BreathingSession>>;
String _$exerciseStatsHash() => r'a3df063a2ed6c37368fdb14ef94a0a1ea39d14a1';

/// Totals, streak and per-day activity for the Exercise tab.
///
/// Copied from [exerciseStats].
@ProviderFor(exerciseStats)
final exerciseStatsProvider = AutoDisposeFutureProvider<ExerciseStats>.internal(
  exerciseStats,
  name: r'exerciseStatsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$exerciseStatsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ExerciseStatsRef = AutoDisposeFutureProviderRef<ExerciseStats>;
String _$breathingPreferencesControllerHash() =>
    r'577770f818112797d30298a21bf1e18b407aae86';

/// Sound and Customize-pattern settings. Kept alive so a running session
/// and the sound sheet over it always share one copy.
///
/// Copied from [BreathingPreferencesController].
@ProviderFor(BreathingPreferencesController)
final breathingPreferencesControllerProvider =
    AsyncNotifierProvider<
      BreathingPreferencesController,
      BreathingPreferences
    >.internal(
      BreathingPreferencesController.new,
      name: r'breathingPreferencesControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$breathingPreferencesControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$BreathingPreferencesController = AsyncNotifier<BreathingPreferences>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
