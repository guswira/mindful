// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'money_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$moneyEntriesBoxHash() => r'887cafff5d740dd98e9e3f970774f26e2e2a5827';

/// The Hive box caching money entries, keyed by entry id.
///
/// Copied from [moneyEntriesBox].
@ProviderFor(moneyEntriesBox)
final moneyEntriesBoxProvider = FutureProvider<Box<dynamic>>.internal(
  moneyEntriesBox,
  name: r'moneyEntriesBoxProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$moneyEntriesBoxHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MoneyEntriesBoxRef = FutureProviderRef<Box<dynamic>>;
String _$budgetSettingsBoxHash() => r'20f0da5f5f49601fd5571be9f0f1451346e633a1';

/// The Hive box caching budget settings — up to one row per [BudgetType].
///
/// Copied from [budgetSettingsBox].
@ProviderFor(budgetSettingsBox)
final budgetSettingsBoxProvider = FutureProvider<Box<dynamic>>.internal(
  budgetSettingsBox,
  name: r'budgetSettingsBoxProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$budgetSettingsBoxHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BudgetSettingsBoxRef = FutureProviderRef<Box<dynamic>>;
String _$moneyRepositoryHash() => r'415117c8cc0ef211d11565836b64f03ba41f28db';

/// The app-wide [MoneyRepository], backed by the opened Hive boxes.
///
/// Copied from [moneyRepository].
@ProviderFor(moneyRepository)
final moneyRepositoryProvider = FutureProvider<MoneyRepository>.internal(
  moneyRepository,
  name: r'moneyRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$moneyRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MoneyRepositoryRef = FutureProviderRef<MoneyRepository>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
