// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tasksBoxHash() => r'ac9c98e99b6e8b004e6d2b22a63c111c6e434f20';

/// The Hive box caching tasks, keyed by task id.
///
/// Copied from [tasksBox].
@ProviderFor(tasksBox)
final tasksBoxProvider = FutureProvider<Box<dynamic>>.internal(
  tasksBox,
  name: r'tasksBoxProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$tasksBoxHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TasksBoxRef = FutureProviderRef<Box<dynamic>>;
String _$taskRepositoryHash() => r'9e58d52a6707e1c0caacc88f6e9bea93561dd729';

/// The app-wide [TaskRepository], backed by the opened Hive box.
///
/// Copied from [taskRepository].
@ProviderFor(taskRepository)
final taskRepositoryProvider = FutureProvider<TaskRepository>.internal(
  taskRepository,
  name: r'taskRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$taskRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TaskRepositoryRef = FutureProviderRef<TaskRepository>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
