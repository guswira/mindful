// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_scan_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$foodScanRepositoryHash() =>
    r'0360dd19cc431a63028b186c8b882773bbd89233';

/// The app-wide [FoodScanRepository].
///
/// Copied from [foodScanRepository].
@ProviderFor(foodScanRepository)
final foodScanRepositoryProvider =
    AutoDisposeProvider<FoodScanRepository>.internal(
      foodScanRepository,
      name: r'foodScanRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$foodScanRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FoodScanRepositoryRef = AutoDisposeProviderRef<FoodScanRepository>;
String _$recentScansHash() => r'23d9cce9b299f4923ac4062153aba874fdc6e6bc';

/// The signed-in user's last 10 food scans, newest first.
///
/// Copied from [recentScans].
@ProviderFor(recentScans)
final recentScansProvider = AutoDisposeFutureProvider<List<FoodScan>>.internal(
  recentScans,
  name: r'recentScansProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$recentScansHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecentScansRef = AutoDisposeFutureProviderRef<List<FoodScan>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
