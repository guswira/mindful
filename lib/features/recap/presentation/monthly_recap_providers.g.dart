// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_recap_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$monthlyRecapHash() => r'aa96820b0f871b4108bf9c4d1b43fd9c01b82e53';

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

/// [month]'s recap, from the Hive caches plus a fresh fetch of that
/// month's habit logs and food scans.
///
/// Copied from [monthlyRecap].
@ProviderFor(monthlyRecap)
const monthlyRecapProvider = MonthlyRecapFamily();

/// [month]'s recap, from the Hive caches plus a fresh fetch of that
/// month's habit logs and food scans.
///
/// Copied from [monthlyRecap].
class MonthlyRecapFamily extends Family<AsyncValue<MonthlyRecap>> {
  /// [month]'s recap, from the Hive caches plus a fresh fetch of that
  /// month's habit logs and food scans.
  ///
  /// Copied from [monthlyRecap].
  const MonthlyRecapFamily();

  /// [month]'s recap, from the Hive caches plus a fresh fetch of that
  /// month's habit logs and food scans.
  ///
  /// Copied from [monthlyRecap].
  MonthlyRecapProvider call(DateTime month) {
    return MonthlyRecapProvider(month);
  }

  @override
  MonthlyRecapProvider getProviderOverride(
    covariant MonthlyRecapProvider provider,
  ) {
    return call(provider.month);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'monthlyRecapProvider';
}

/// [month]'s recap, from the Hive caches plus a fresh fetch of that
/// month's habit logs and food scans.
///
/// Copied from [monthlyRecap].
class MonthlyRecapProvider extends AutoDisposeFutureProvider<MonthlyRecap> {
  /// [month]'s recap, from the Hive caches plus a fresh fetch of that
  /// month's habit logs and food scans.
  ///
  /// Copied from [monthlyRecap].
  MonthlyRecapProvider(DateTime month)
    : this._internal(
        (ref) => monthlyRecap(ref as MonthlyRecapRef, month),
        from: monthlyRecapProvider,
        name: r'monthlyRecapProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$monthlyRecapHash,
        dependencies: MonthlyRecapFamily._dependencies,
        allTransitiveDependencies:
            MonthlyRecapFamily._allTransitiveDependencies,
        month: month,
      );

  MonthlyRecapProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.month,
  }) : super.internal();

  final DateTime month;

  @override
  Override overrideWith(
    FutureOr<MonthlyRecap> Function(MonthlyRecapRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MonthlyRecapProvider._internal(
        (ref) => create(ref as MonthlyRecapRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        month: month,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<MonthlyRecap> createElement() {
    return _MonthlyRecapProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MonthlyRecapProvider && other.month == month;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, month.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MonthlyRecapRef on AutoDisposeFutureProviderRef<MonthlyRecap> {
  /// The parameter `month` of this provider.
  DateTime get month;
}

class _MonthlyRecapProviderElement
    extends AutoDisposeFutureProviderElement<MonthlyRecap>
    with MonthlyRecapRef {
  _MonthlyRecapProviderElement(super.provider);

  @override
  DateTime get month => (origin as MonthlyRecapProvider).month;
}

String _$monthlyRecapBannerMonthHash() =>
    r'201c4b27ceacf3e01c3ec5d1e14937d49d2e1d5b';

/// The month the home banner offers a recap for right now, or null outside
/// the window (see [recapMonthForBanner]). Not dismissible — it shows
/// every day of the window.
///
/// Copied from [monthlyRecapBannerMonth].
@ProviderFor(monthlyRecapBannerMonth)
final monthlyRecapBannerMonthProvider = AutoDisposeProvider<DateTime?>.internal(
  monthlyRecapBannerMonth,
  name: r'monthlyRecapBannerMonthProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$monthlyRecapBannerMonthHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MonthlyRecapBannerMonthRef = AutoDisposeProviderRef<DateTime?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
