// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journal_entries_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$journalEntryHash() => r'8b7a3ec5a2faeacf3a60689280c781680dc4deb9';

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

/// A single entry looked up from the cached [journalEntriesProvider] list.
///
/// Copied from [journalEntry].
@ProviderFor(journalEntry)
const journalEntryProvider = JournalEntryFamily();

/// A single entry looked up from the cached [journalEntriesProvider] list.
///
/// Copied from [journalEntry].
class JournalEntryFamily extends Family<JournalEntry?> {
  /// A single entry looked up from the cached [journalEntriesProvider] list.
  ///
  /// Copied from [journalEntry].
  const JournalEntryFamily();

  /// A single entry looked up from the cached [journalEntriesProvider] list.
  ///
  /// Copied from [journalEntry].
  JournalEntryProvider call(String id) {
    return JournalEntryProvider(id);
  }

  @override
  JournalEntryProvider getProviderOverride(
    covariant JournalEntryProvider provider,
  ) {
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
  String? get name => r'journalEntryProvider';
}

/// A single entry looked up from the cached [journalEntriesProvider] list.
///
/// Copied from [journalEntry].
class JournalEntryProvider extends AutoDisposeProvider<JournalEntry?> {
  /// A single entry looked up from the cached [journalEntriesProvider] list.
  ///
  /// Copied from [journalEntry].
  JournalEntryProvider(String id)
    : this._internal(
        (ref) => journalEntry(ref as JournalEntryRef, id),
        from: journalEntryProvider,
        name: r'journalEntryProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$journalEntryHash,
        dependencies: JournalEntryFamily._dependencies,
        allTransitiveDependencies:
            JournalEntryFamily._allTransitiveDependencies,
        id: id,
      );

  JournalEntryProvider._internal(
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
    JournalEntry? Function(JournalEntryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: JournalEntryProvider._internal(
        (ref) => create(ref as JournalEntryRef),
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
  AutoDisposeProviderElement<JournalEntry?> createElement() {
    return _JournalEntryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is JournalEntryProvider && other.id == id;
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
mixin JournalEntryRef on AutoDisposeProviderRef<JournalEntry?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _JournalEntryProviderElement
    extends AutoDisposeProviderElement<JournalEntry?>
    with JournalEntryRef {
  _JournalEntryProviderElement(super.provider);

  @override
  String get id => (origin as JournalEntryProvider).id;
}

String _$journalEntriesHash() => r'3a25a7e1738fd3d10932b987e01fe721377cd048';

/// Journal entries, newest first — cache-backed with Supabase sync.
///
/// Copied from [JournalEntries].
@ProviderFor(JournalEntries)
final journalEntriesProvider =
    AutoDisposeAsyncNotifierProvider<
      JournalEntries,
      List<JournalEntry>
    >.internal(
      JournalEntries.new,
      name: r'journalEntriesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$journalEntriesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$JournalEntries = AutoDisposeAsyncNotifier<List<JournalEntry>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
