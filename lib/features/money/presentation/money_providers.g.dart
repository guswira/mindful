// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'money_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$monthlyBudgetHash() => r'b9df96d5fa621715b5f2c5ceb56d0c29c13cae83';

/// The signed-in user's monthly budget, or null if it hasn't been set.
///
/// Copied from [monthlyBudget].
@ProviderFor(monthlyBudget)
final monthlyBudgetProvider =
    AutoDisposeFutureProvider<BudgetSettings?>.internal(
      monthlyBudget,
      name: r'monthlyBudgetProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$monthlyBudgetHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MonthlyBudgetRef = AutoDisposeFutureProviderRef<BudgetSettings?>;
String _$dailyBudgetHash() => r'308ab82cb8101982c3a2367840b04a44a49c63dd';

/// The signed-in user's daily budget, or null if it hasn't been set.
///
/// Copied from [dailyBudget].
@ProviderFor(dailyBudget)
final dailyBudgetProvider = AutoDisposeFutureProvider<BudgetSettings?>.internal(
  dailyBudget,
  name: r'dailyBudgetProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$dailyBudgetHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DailyBudgetRef = AutoDisposeFutureProviderRef<BudgetSettings?>;
String _$budgetCurrencyHash() => r'7db91a963495ca6eaeefccecef0a00397f956554';

/// The currency both budgets are set in. See
/// [MoneyRepository.getCurrency].
///
/// Copied from [budgetCurrency].
@ProviderFor(budgetCurrency)
final budgetCurrencyProvider = AutoDisposeFutureProvider<String>.internal(
  budgetCurrency,
  name: r'budgetCurrencyProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$budgetCurrencyHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BudgetCurrencyRef = AutoDisposeFutureProviderRef<String>;
String _$moneyEntriesHash() => r'b5496d450c7766573cc88cdec5dea130b5ea6c70';

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

/// Money entries within [range] (inclusive), newest first. A null [range]
/// returns every cached entry.
///
/// Copied from [moneyEntries].
@ProviderFor(moneyEntries)
const moneyEntriesProvider = MoneyEntriesFamily();

/// Money entries within [range] (inclusive), newest first. A null [range]
/// returns every cached entry.
///
/// Copied from [moneyEntries].
class MoneyEntriesFamily extends Family<AsyncValue<List<MoneyEntry>>> {
  /// Money entries within [range] (inclusive), newest first. A null [range]
  /// returns every cached entry.
  ///
  /// Copied from [moneyEntries].
  const MoneyEntriesFamily();

  /// Money entries within [range] (inclusive), newest first. A null [range]
  /// returns every cached entry.
  ///
  /// Copied from [moneyEntries].
  MoneyEntriesProvider call(DateTimeRange<DateTime>? range) {
    return MoneyEntriesProvider(range);
  }

  @override
  MoneyEntriesProvider getProviderOverride(
    covariant MoneyEntriesProvider provider,
  ) {
    return call(provider.range);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'moneyEntriesProvider';
}

/// Money entries within [range] (inclusive), newest first. A null [range]
/// returns every cached entry.
///
/// Copied from [moneyEntries].
class MoneyEntriesProvider extends AutoDisposeFutureProvider<List<MoneyEntry>> {
  /// Money entries within [range] (inclusive), newest first. A null [range]
  /// returns every cached entry.
  ///
  /// Copied from [moneyEntries].
  MoneyEntriesProvider(DateTimeRange<DateTime>? range)
    : this._internal(
        (ref) => moneyEntries(ref as MoneyEntriesRef, range),
        from: moneyEntriesProvider,
        name: r'moneyEntriesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$moneyEntriesHash,
        dependencies: MoneyEntriesFamily._dependencies,
        allTransitiveDependencies:
            MoneyEntriesFamily._allTransitiveDependencies,
        range: range,
      );

  MoneyEntriesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.range,
  }) : super.internal();

  final DateTimeRange<DateTime>? range;

  @override
  Override overrideWith(
    FutureOr<List<MoneyEntry>> Function(MoneyEntriesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MoneyEntriesProvider._internal(
        (ref) => create(ref as MoneyEntriesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        range: range,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<MoneyEntry>> createElement() {
    return _MoneyEntriesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MoneyEntriesProvider && other.range == range;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, range.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MoneyEntriesRef on AutoDisposeFutureProviderRef<List<MoneyEntry>> {
  /// The parameter `range` of this provider.
  DateTimeRange<DateTime>? get range;
}

class _MoneyEntriesProviderElement
    extends AutoDisposeFutureProviderElement<List<MoneyEntry>>
    with MoneyEntriesRef {
  _MoneyEntriesProviderElement(super.provider);

  @override
  DateTimeRange<DateTime>? get range => (origin as MoneyEntriesProvider).range;
}

String _$remainingBudgetHash() => r'ecba4aed17e2ff8b1d5d6b3ffde7b78d335eb523';

/// Each budget type's remaining amount for its current period (amount −
/// spending + income), 0 for a type that hasn't been set. See
/// [MoneyRepository.getRemaining].
///
/// Copied from [remainingBudget].
@ProviderFor(remainingBudget)
final remainingBudgetProvider =
    AutoDisposeFutureProvider<Map<BudgetType, double>>.internal(
      remainingBudget,
      name: r'remainingBudgetProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$remainingBudgetHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RemainingBudgetRef =
    AutoDisposeFutureProviderRef<Map<BudgetType, double>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
