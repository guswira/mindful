// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journal_tab.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$journalPhotoUrlHash() => r'89505b0ad8d4587851635eb6c46585c411ea1258';

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

/// A signed URL for the private Supabase Storage photo at [path], valid for
/// an hour — cheap enough to re-fetch per widget build via [ref.watch].
///
/// Copied from [journalPhotoUrl].
@ProviderFor(journalPhotoUrl)
const journalPhotoUrlProvider = JournalPhotoUrlFamily();

/// A signed URL for the private Supabase Storage photo at [path], valid for
/// an hour — cheap enough to re-fetch per widget build via [ref.watch].
///
/// Copied from [journalPhotoUrl].
class JournalPhotoUrlFamily extends Family<AsyncValue<String>> {
  /// A signed URL for the private Supabase Storage photo at [path], valid for
  /// an hour — cheap enough to re-fetch per widget build via [ref.watch].
  ///
  /// Copied from [journalPhotoUrl].
  const JournalPhotoUrlFamily();

  /// A signed URL for the private Supabase Storage photo at [path], valid for
  /// an hour — cheap enough to re-fetch per widget build via [ref.watch].
  ///
  /// Copied from [journalPhotoUrl].
  JournalPhotoUrlProvider call(String path) {
    return JournalPhotoUrlProvider(path);
  }

  @override
  JournalPhotoUrlProvider getProviderOverride(
    covariant JournalPhotoUrlProvider provider,
  ) {
    return call(provider.path);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'journalPhotoUrlProvider';
}

/// A signed URL for the private Supabase Storage photo at [path], valid for
/// an hour — cheap enough to re-fetch per widget build via [ref.watch].
///
/// Copied from [journalPhotoUrl].
class JournalPhotoUrlProvider extends AutoDisposeFutureProvider<String> {
  /// A signed URL for the private Supabase Storage photo at [path], valid for
  /// an hour — cheap enough to re-fetch per widget build via [ref.watch].
  ///
  /// Copied from [journalPhotoUrl].
  JournalPhotoUrlProvider(String path)
    : this._internal(
        (ref) => journalPhotoUrl(ref as JournalPhotoUrlRef, path),
        from: journalPhotoUrlProvider,
        name: r'journalPhotoUrlProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$journalPhotoUrlHash,
        dependencies: JournalPhotoUrlFamily._dependencies,
        allTransitiveDependencies:
            JournalPhotoUrlFamily._allTransitiveDependencies,
        path: path,
      );

  JournalPhotoUrlProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.path,
  }) : super.internal();

  final String path;

  @override
  Override overrideWith(
    FutureOr<String> Function(JournalPhotoUrlRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: JournalPhotoUrlProvider._internal(
        (ref) => create(ref as JournalPhotoUrlRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        path: path,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<String> createElement() {
    return _JournalPhotoUrlProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is JournalPhotoUrlProvider && other.path == path;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, path.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin JournalPhotoUrlRef on AutoDisposeFutureProviderRef<String> {
  /// The parameter `path` of this provider.
  String get path;
}

class _JournalPhotoUrlProviderElement
    extends AutoDisposeFutureProviderElement<String>
    with JournalPhotoUrlRef {
  _JournalPhotoUrlProviderElement(super.provider);

  @override
  String get path => (origin as JournalPhotoUrlProvider).path;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
