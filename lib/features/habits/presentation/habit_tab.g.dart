// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_tab.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$habitTabControllerHash() =>
    r'8384dc85d2ffd35873897608c3ef0315de914795';

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
