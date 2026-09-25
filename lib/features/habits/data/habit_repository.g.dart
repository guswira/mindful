// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$habitsBoxHash() => r'82700b07110b9ec63589c9972ec3c3a7f4040acb';

/// The Hive box caching habit definitions, keyed by habit id.
///
/// Copied from [habitsBox].
@ProviderFor(habitsBox)
final habitsBoxProvider = FutureProvider<Box<dynamic>>.internal(
  habitsBox,
  name: r'habitsBoxProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$habitsBoxHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HabitsBoxRef = FutureProviderRef<Box<dynamic>>;
String _$habitLogsBoxHash() => r'8bb75ffa047cebb1a1604aad54c39eab722710e6';

/// The Hive box caching habit completion logs, keyed by `habitId_date`.
///
/// Copied from [habitLogsBox].
@ProviderFor(habitLogsBox)
final habitLogsBoxProvider = FutureProvider<Box<dynamic>>.internal(
  habitLogsBox,
  name: r'habitLogsBoxProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$habitLogsBoxHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HabitLogsBoxRef = FutureProviderRef<Box<dynamic>>;
String _$habitRepositoryHash() => r'7073f2ddad926a90c89a2c5d1f06b12f0593f75a';

/// The app-wide [HabitRepository], backed by the opened Hive boxes.
///
/// Copied from [habitRepository].
@ProviderFor(habitRepository)
final habitRepositoryProvider = FutureProvider<HabitRepository>.internal(
  habitRepository,
  name: r'habitRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$habitRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HabitRepositoryRef = FutureProviderRef<HabitRepository>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
