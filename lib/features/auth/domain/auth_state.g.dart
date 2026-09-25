// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentUserIdHash() => r'5f79f1a93b5852b7ef29a40be00784f45ab61810';

/// The signed-in user's Supabase id.
///
/// Throws if read while unauthenticated — callers only run once the
/// router's redirect guard has already required an authenticated session.
///
/// Copied from [currentUserId].
@ProviderFor(currentUserId)
final currentUserIdProvider = AutoDisposeProvider<String>.internal(
  currentUserId,
  name: r'currentUserIdProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentUserIdHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentUserIdRef = AutoDisposeProviderRef<String>;
String _$authNotifierHash() => r'a2da67998f66544bf26114c19200a2be7407419a';

/// Drives [AuthState] from [AuthRepository] and exposes sign-in/out actions.
///
/// Copied from [AuthNotifier].
@ProviderFor(AuthNotifier)
final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>.internal(
  AuthNotifier.new,
  name: r'authNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AuthNotifier = Notifier<AuthState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
