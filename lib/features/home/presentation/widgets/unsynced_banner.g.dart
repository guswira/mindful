// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unsynced_banner.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$hasStalePendingWritesHash() =>
    r'ef5975a6e8a657f39099cb20ec57e6997db875cc';

/// Whether any pending write (journal entry, habit log or task) is older
/// than 24 hours — SPEC.md's threshold for showing [UnsyncedBanner].
///
/// Habit logs have no write timestamp of their own (only a completion
/// [HabitLog.date]), so their log date is used as an approximation of when
/// the write happened.
///
/// Copied from [hasStalePendingWrites].
@ProviderFor(hasStalePendingWrites)
final hasStalePendingWritesProvider = AutoDisposeFutureProvider<bool>.internal(
  hasStalePendingWrites,
  name: r'hasStalePendingWritesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$hasStalePendingWritesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HasStalePendingWritesRef = AutoDisposeFutureProviderRef<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
