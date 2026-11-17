// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_background_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$customBackgroundControllerHash() =>
    r'6953d3b39c84937134ddcf5119d0d2441c9763ce';

/// The custom background photo's path (null = the default navy + blobs),
/// read by [App] and handed to every [BlobBackground] via
/// [AppBackgroundScope].
///
/// Copied from [CustomBackgroundController].
@ProviderFor(CustomBackgroundController)
final customBackgroundControllerProvider =
    AsyncNotifierProvider<CustomBackgroundController, String?>.internal(
      CustomBackgroundController.new,
      name: r'customBackgroundControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$customBackgroundControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CustomBackgroundController = AsyncNotifier<String?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
