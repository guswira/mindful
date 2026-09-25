// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_language_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appLanguageControllerHash() =>
    r'2deffee0fcb6053a8113ad2c8de0aa03db4cd86d';

/// The language picked in Settings — [AppLanguage.system] until [restore]
/// loads a saved choice at startup.
///
/// Copied from [AppLanguageController].
@ProviderFor(AppLanguageController)
final appLanguageControllerProvider =
    NotifierProvider<AppLanguageController, AppLanguage>.internal(
      AppLanguageController.new,
      name: r'appLanguageControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$appLanguageControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AppLanguageController = Notifier<AppLanguage>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
