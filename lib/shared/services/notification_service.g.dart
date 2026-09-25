// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$notificationServiceHash() =>
    r'63e5e2f58aab83c1deb99c28ba35997a386df6b9';

/// See also [notificationService].
@ProviderFor(notificationService)
final notificationServiceProvider =
    FutureProvider<NotificationService>.internal(
      notificationService,
      name: r'notificationServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$notificationServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NotificationServiceRef = FutureProviderRef<NotificationService>;
String _$notificationTapHash() => r'1398ceeeeff2393c6520e86b5fa1f082eae24e5b';

/// Payloads of tapped notifications, forwarded from [notificationServiceProvider].
///
/// Copied from [notificationTap].
@ProviderFor(notificationTap)
final notificationTapProvider = AutoDisposeStreamProvider<String?>.internal(
  notificationTap,
  name: r'notificationTapProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationTapHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NotificationTapRef = AutoDisposeStreamProviderRef<String?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
