// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$habitByIdHash() => r'e9d4709e49c48419dd4f29a163d50e0ad76408ae';

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

/// The cached habit with [id], or null if it doesn't exist.
///
/// Shared by the detail and edit screens so they don't each re-derive it
/// from the repository.
///
/// Copied from [habitById].
@ProviderFor(habitById)
const habitByIdProvider = HabitByIdFamily();

/// The cached habit with [id], or null if it doesn't exist.
///
/// Shared by the detail and edit screens so they don't each re-derive it
/// from the repository.
///
/// Copied from [habitById].
class HabitByIdFamily extends Family<AsyncValue<Habit?>> {
  /// The cached habit with [id], or null if it doesn't exist.
  ///
  /// Shared by the detail and edit screens so they don't each re-derive it
  /// from the repository.
  ///
  /// Copied from [habitById].
  const HabitByIdFamily();

  /// The cached habit with [id], or null if it doesn't exist.
  ///
  /// Shared by the detail and edit screens so they don't each re-derive it
  /// from the repository.
  ///
  /// Copied from [habitById].
  HabitByIdProvider call(String id) {
    return HabitByIdProvider(id);
  }

  @override
  HabitByIdProvider getProviderOverride(covariant HabitByIdProvider provider) {
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
  String? get name => r'habitByIdProvider';
}

/// The cached habit with [id], or null if it doesn't exist.
///
/// Shared by the detail and edit screens so they don't each re-derive it
/// from the repository.
///
/// Copied from [habitById].
class HabitByIdProvider extends AutoDisposeFutureProvider<Habit?> {
  /// The cached habit with [id], or null if it doesn't exist.
  ///
  /// Shared by the detail and edit screens so they don't each re-derive it
  /// from the repository.
  ///
  /// Copied from [habitById].
  HabitByIdProvider(String id)
    : this._internal(
        (ref) => habitById(ref as HabitByIdRef, id),
        from: habitByIdProvider,
        name: r'habitByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$habitByIdHash,
        dependencies: HabitByIdFamily._dependencies,
        allTransitiveDependencies: HabitByIdFamily._allTransitiveDependencies,
        id: id,
      );

  HabitByIdProvider._internal(
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
  Override overrideWith(
    FutureOr<Habit?> Function(HabitByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: HabitByIdProvider._internal(
        (ref) => create(ref as HabitByIdRef),
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
  AutoDisposeFutureProviderElement<Habit?> createElement() {
    return _HabitByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HabitByIdProvider && other.id == id;
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
mixin HabitByIdRef on AutoDisposeFutureProviderRef<Habit?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _HabitByIdProviderElement extends AutoDisposeFutureProviderElement<Habit?>
    with HabitByIdRef {
  _HabitByIdProviderElement(super.provider);

  @override
  String get id => (origin as HabitByIdProvider).id;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
