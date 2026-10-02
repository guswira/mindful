// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'breathing_session_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$breathingSessionsBoxHash() =>
    r'3540dce291405005fabcce99f439117d49a362a2';

/// The Hive box caching breathing sessions, keyed by session id.
///
/// Copied from [breathingSessionsBox].
@ProviderFor(breathingSessionsBox)
final breathingSessionsBoxProvider = FutureProvider<Box<dynamic>>.internal(
  breathingSessionsBox,
  name: r'breathingSessionsBoxProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$breathingSessionsBoxHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BreathingSessionsBoxRef = FutureProviderRef<Box<dynamic>>;
String _$breathingSessionRepositoryHash() =>
    r'409c8f80d1e700f5ef2a4be7b8e31e0ab19bf69a';

/// The app-wide [BreathingSessionRepository].
///
/// Copied from [breathingSessionRepository].
@ProviderFor(breathingSessionRepository)
final breathingSessionRepositoryProvider =
    FutureProvider<BreathingSessionRepository>.internal(
      breathingSessionRepository,
      name: r'breathingSessionRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$breathingSessionRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BreathingSessionRepositoryRef =
    FutureProviderRef<BreathingSessionRepository>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
