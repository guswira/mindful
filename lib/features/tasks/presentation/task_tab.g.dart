// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_tab.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$taskTabControllerHash() => r'54319de9b9999b404f2c1cc83ac78267319ff064';

/// Loads all tasks and marks completions, refreshed from Supabase in the
/// background. See SPEC.md Task Manager.
///
/// Copied from [TaskTabController].
@ProviderFor(TaskTabController)
final taskTabControllerProvider =
    AutoDisposeAsyncNotifierProvider<TaskTabController, List<Task>>.internal(
      TaskTabController.new,
      name: r'taskTabControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$taskTabControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TaskTabController = AutoDisposeAsyncNotifier<List<Task>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
