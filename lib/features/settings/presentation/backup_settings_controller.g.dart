// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup_settings_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$backupSettingsHash() => r'd9103e8e6cc1b67682f48c81b41def44e9a31ccb';

/// Drive connect/disconnect, manual + auto backup, and restore — see
/// SPEC.md Settings > Drive backup/restore sections.
///
/// Copied from [BackupSettings].
@ProviderFor(BackupSettings)
final backupSettingsProvider =
    AutoDisposeAsyncNotifierProvider<
      BackupSettings,
      BackupSettingsState
    >.internal(
      BackupSettings.new,
      name: r'backupSettingsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$backupSettingsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$BackupSettings = AutoDisposeAsyncNotifier<BackupSettingsState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
