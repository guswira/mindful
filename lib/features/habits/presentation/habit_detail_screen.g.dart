// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_detail_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$habitDetailControllerHash() =>
    r'8e1ab70b9bc5d0cf40b3ff99338c4025683db38b';

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

abstract class _$HabitDetailController
    extends BuildlessAutoDisposeAsyncNotifier<HabitDetailState> {
  late final String habitId;

  FutureOr<HabitDetailState> build(String habitId);
}

/// Loads a habit's completion logs a month at a time, starting with the
/// current and previous month so streaks have a sensible default window.
///
/// Copied from [HabitDetailController].
@ProviderFor(HabitDetailController)
const habitDetailControllerProvider = HabitDetailControllerFamily();

/// Loads a habit's completion logs a month at a time, starting with the
/// current and previous month so streaks have a sensible default window.
///
/// Copied from [HabitDetailController].
class HabitDetailControllerFamily extends Family<AsyncValue<HabitDetailState>> {
  /// Loads a habit's completion logs a month at a time, starting with the
  /// current and previous month so streaks have a sensible default window.
  ///
  /// Copied from [HabitDetailController].
  const HabitDetailControllerFamily();

  /// Loads a habit's completion logs a month at a time, starting with the
  /// current and previous month so streaks have a sensible default window.
  ///
  /// Copied from [HabitDetailController].
  HabitDetailControllerProvider call(String habitId) {
    return HabitDetailControllerProvider(habitId);
  }

  @override
  HabitDetailControllerProvider getProviderOverride(
    covariant HabitDetailControllerProvider provider,
  ) {
    return call(provider.habitId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'habitDetailControllerProvider';
}

/// Loads a habit's completion logs a month at a time, starting with the
/// current and previous month so streaks have a sensible default window.
///
/// Copied from [HabitDetailController].
class HabitDetailControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          HabitDetailController,
          HabitDetailState
        > {
  /// Loads a habit's completion logs a month at a time, starting with the
  /// current and previous month so streaks have a sensible default window.
  ///
  /// Copied from [HabitDetailController].
  HabitDetailControllerProvider(String habitId)
    : this._internal(
        () => HabitDetailController()..habitId = habitId,
        from: habitDetailControllerProvider,
        name: r'habitDetailControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$habitDetailControllerHash,
        dependencies: HabitDetailControllerFamily._dependencies,
        allTransitiveDependencies:
            HabitDetailControllerFamily._allTransitiveDependencies,
        habitId: habitId,
      );

  HabitDetailControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.habitId,
  }) : super.internal();

  final String habitId;

  @override
  FutureOr<HabitDetailState> runNotifierBuild(
    covariant HabitDetailController notifier,
  ) {
    return notifier.build(habitId);
  }

  @override
  Override overrideWith(HabitDetailController Function() create) {
    return ProviderOverride(
      origin: this,
      override: HabitDetailControllerProvider._internal(
        () => create()..habitId = habitId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        habitId: habitId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    HabitDetailController,
    HabitDetailState
  >
  createElement() {
    return _HabitDetailControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HabitDetailControllerProvider && other.habitId == habitId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, habitId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin HabitDetailControllerRef
    on AutoDisposeAsyncNotifierProviderRef<HabitDetailState> {
  /// The parameter `habitId` of this provider.
  String get habitId;
}

class _HabitDetailControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          HabitDetailController,
          HabitDetailState
        >
    with HabitDetailControllerRef {
  _HabitDetailControllerProviderElement(super.provider);

  @override
  String get habitId => (origin as HabitDetailControllerProvider).habitId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
