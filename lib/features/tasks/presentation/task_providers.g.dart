// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$taskByIdHash() => r'0d4be1d50f8c4ca621cc9718c6c7ce60ec80f597';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// The cached task with [id], or null if it doesn't exist.
///
/// Shared by the detail and edit screens so they don't each re-derive it
/// from the repository.
///
/// Copied from [taskById].
@ProviderFor(taskById)
const taskByIdProvider = TaskByIdFamily();

/// The cached task with [id], or null if it doesn't exist.
///
/// Shared by the detail and edit screens so they don't each re-derive it
/// from the repository.
///
/// Copied from [taskById].
class TaskByIdFamily extends Family<AsyncValue<Task?>> {
  /// The cached task with [id], or null if it doesn't exist.
  ///
  /// Shared by the detail and edit screens so they don't each re-derive it
  /// from the repository.
  ///
  /// Copied from [taskById].
  const TaskByIdFamily();

  /// The cached task with [id], or null if it doesn't exist.
  ///
  /// Shared by the detail and edit screens so they don't each re-derive it
  /// from the repository.
  ///
  /// Copied from [taskById].
  TaskByIdProvider call(String id) {
    return TaskByIdProvider(id);
  }

  @override
  TaskByIdProvider getProviderOverride(covariant TaskByIdProvider provider) {
    return call(provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'taskByIdProvider';
}

/// The cached task with [id], or null if it doesn't exist.
///
/// Shared by the detail and edit screens so they don't each re-derive it
/// from the repository.
///
/// Copied from [taskById].
class TaskByIdProvider extends AutoDisposeFutureProvider<Task?> {
  /// The cached task with [id], or null if it doesn't exist.
  ///
  /// Shared by the detail and edit screens so they don't each re-derive it
  /// from the repository.
  ///
  /// Copied from [taskById].
  TaskByIdProvider(String id)
    : this._internal(
        (ref) => taskById(ref as TaskByIdRef, id),
        from: taskByIdProvider,
        name: r'taskByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$taskByIdHash,
        dependencies: TaskByIdFamily._dependencies,
        allTransitiveDependencies: TaskByIdFamily._allTransitiveDependencies,
        id: id,
      );

  TaskByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(FutureOr<Task?> Function(TaskByIdRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: TaskByIdProvider._internal(
        (ref) => create(ref as TaskByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Task?> createElement() {
    return _TaskByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TaskByIdProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TaskByIdRef on AutoDisposeFutureProviderRef<Task?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _TaskByIdProviderElement extends AutoDisposeFutureProviderElement<Task?>
    with TaskByIdRef {
  _TaskByIdProviderElement(super.provider);

  @override
  String get id => (origin as TaskByIdProvider).id;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
