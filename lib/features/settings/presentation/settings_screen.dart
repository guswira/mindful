import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/l10n/app_language.dart';
import '../../../core/l10n/app_language_controller.dart';
import '../../../core/l10n/l10n.dart';
import '../../../shared/services/drive_service.dart';
import '../../auth/domain/auth_state.dart';
import '../data/journal_reminders_controller.dart';
import 'backup_settings_controller.dart';
import 'debug_section.dart';

/// Account/sign-out, language, notification toggles, and Drive
/// backup/restore.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.settingsTitle)),
      body: ListView(
        children: const [
          _AccountSection(),
          Divider(height: 1),
          _LanguageSection(),
          Divider(height: 1),
          _NotificationsSection(),
          Divider(height: 1),
          _DriveBackupSection(),
          Divider(height: 1),
          _DriveRestoreSection(),
          Divider(height: 1),
          DebugSection(),
        ],
      ),
    );
  }
}

class _AccountSection extends ConsumerWidget {
  const _AccountSection();

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    await ref.read(authNotifierProvider.notifier).signOut();
  }

  /// Falls back to a plain "Signed in" when the account has neither a
  /// display name nor an email.
  String _signedInLabel(AppLocalizations l10n, String? name) =>
      l10n.settingsSignedInAs(name ?? l10n.settingsSignedInFallback);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = switch (authState) {
      AuthAuthenticated(:final user) => user,
      _ => null,
    };
    final metadata = user?.userMetadata ?? const {};
    final name =
        metadata['full_name'] as String? ??
        metadata['name'] as String? ??
        user?.email;
    final photoUrl =
        metadata['avatar_url'] as String? ?? metadata['picture'] as String?;

    return Padding(
      padding: const EdgeInsets.all(Spacing.md),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: photoUrl == null ? null : NetworkImage(photoUrl),
            child: photoUrl == null ? const Icon(Icons.person) : null,
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Text(
              _signedInLabel(context.l10n, name),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          TextButton(
            onPressed: () => _signOut(context, ref),
            child: Text(context.l10n.settingsSignOut),
          ),
        ],
      ),
    );
  }
}

class _LanguageSection extends ConsumerWidget {
  const _LanguageSection();

  /// "System default (English)" etc. — names the language the device
  /// currently resolves to, so "system" isn't a mystery choice.
  static String _systemLabel(AppLocalizations l10n) {
    final deviceLocale = resolveAppLocale(
      WidgetsBinding.instance.platformDispatcher.locale,
    );
    final deviceLanguage = switch (deviceLocale.languageCode) {
      'id' => l10n.languageNameBahasa,
      _ => l10n.languageNameEnglish,
    };
    return l10n.settingsLanguageSystemWithCurrent(deviceLanguage);
  }

  static String _label(AppLocalizations l10n, AppLanguage language) =>
      switch (language) {
        AppLanguage.system => _systemLabel(l10n),
        AppLanguage.english => l10n.languageNameEnglish,
        AppLanguage.bahasa => l10n.languageNameBahasa,
      };

  Future<void> _pickLanguage(
    BuildContext context,
    WidgetRef ref,
    AppLanguage current,
  ) async {
    final l10n = context.l10n;
    final picked = await showModalBottomSheet<AppLanguage>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final language in AppLanguage.values)
              ListTile(
                title: Text(_label(l10n, language)),
                trailing: language == current ? const Icon(Icons.check) : null,
                onTap: () => Navigator.pop(context, language),
              ),
          ],
        ),
      ),
    );
    if (picked == null || !context.mounted) return;
    await ref.read(appLanguageControllerProvider.notifier).select(picked);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageControllerProvider);
    return ListTile(
      leading: const Icon(Icons.language),
      title: Text(context.l10n.settingsLanguageTitle),
      subtitle: Text(_label(context.l10n, language)),
      onTap: () => _pickLanguage(context, ref, language),
    );
  }
}

class _NotificationsSection extends ConsumerWidget {
  const _NotificationsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remindersAsync = ref.watch(journalRemindersProvider);
    final notifier = ref.read(journalRemindersProvider.notifier);

    return remindersAsync.when(
      data: (reminders) => Column(
        children: [
          SwitchListTile(
            title: Text(context.l10n.settingsMorningReminderTitle),
            subtitle: Text(context.l10n.settingsMorningReminderTime),
            value: reminders.morning,
            onChanged: notifier.setMorningEnabled,
          ),
          SwitchListTile(
            title: Text(context.l10n.settingsEveningReminderTitle),
            subtitle: Text(context.l10n.settingsEveningReminderTime),
            value: reminders.evening,
            onChanged: notifier.setEveningEnabled,
          ),
        ],
      ),
      loading: () => const Padding(
        padding: EdgeInsets.all(Spacing.md),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Text(context.l10n.settingsRemindersLoadError('$error')),
      ),
    );
  }
}

class _DriveBackupSection extends ConsumerWidget {
  const _DriveBackupSection();

  Future<void> _connect(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(backupSettingsProvider.notifier).connectDrive();
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.settingsDriveConnectError('$error'))),
      );
    }
  }

  Future<void> _disconnect(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.settingsDriveDisconnectTitle),
        content: Text(context.l10n.settingsDriveDisconnectBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.settingsDriveDisconnect),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(backupSettingsProvider.notifier).disconnectDrive();
  }

  Future<void> _backUpNow(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(backupSettingsProvider.notifier).backupNow();
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(content: Text(context.l10n.settingsBackupComplete)),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(content: Text(context.l10n.settingsBackupFailed('$error'))),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(backupSettingsProvider);

    return Padding(
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.settingsDriveBackupTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: Spacing.sm),
          switch (settingsAsync) {
            AsyncData(:final value) => _DriveBackupBody(
              state: value,
              onConnect: () => _connect(context, ref),
              onDisconnect: () => _disconnect(context, ref),
              onBackUpNow: () => _backUpNow(context, ref),
              onAutoBackupChanged: (enabled) => ref
                  .read(backupSettingsProvider.notifier)
                  .setAutoBackupEnabled(enabled),
            ),
            AsyncError(:final error) => Text(
              context.l10n.settingsDriveStatusLoadError('$error'),
            ),
            _ => const Center(child: CircularProgressIndicator()),
          },
        ],
      ),
    );
  }
}

class _DriveBackupBody extends StatelessWidget {
  const _DriveBackupBody({
    required this.state,
    required this.onConnect,
    required this.onDisconnect,
    required this.onBackUpNow,
    required this.onAutoBackupChanged,
  });

  final BackupSettingsState state;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;
  final VoidCallback onBackUpNow;
  final ValueChanged<bool> onAutoBackupChanged;

  String _lastBackupLabel(AppLocalizations l10n) =>
      switch (state.lastBackupAt) {
        final lastBackupAt? => l10n.settingsLastBackup(
          DateFormat.yMMMd().add_jm().format(lastBackupAt),
        ),
        null => l10n.settingsNoBackupsYet,
      };

  @override
  Widget build(BuildContext context) {
    if (!state.driveConnected) {
      return Align(
        alignment: Alignment.centerLeft,
        child: FilledButton(
          onPressed: onConnect,
          child: Text(context.l10n.settingsConnectDrive),
        ),
      );
    }

    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_lastBackupLabel(l10n)),
        Text(l10n.settingsPendingRecords(state.pendingRecordsCount)),
        const SizedBox(height: Spacing.sm),
        Row(
          children: [
            FilledButton(
              onPressed: onBackUpNow,
              child: Text(l10n.settingsBackUpNow),
            ),
            const SizedBox(width: Spacing.sm),
            OutlinedButton(
              onPressed: onDisconnect,
              child: Text(l10n.settingsDisconnectDrive),
            ),
          ],
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.settingsAutoBackupTitle),
          subtitle: Text(l10n.settingsAutoBackupSubtitle),
          value: state.autoBackupEnabled,
          onChanged: onAutoBackupChanged,
        ),
      ],
    );
  }
}

class _DriveRestoreSection extends ConsumerWidget {
  const _DriveRestoreSection();

  Future<void> _importFromDrive(BuildContext context, WidgetRef ref) async {
    final controller = ref.read(backupSettingsProvider.notifier);
    List<String> months;
    try {
      months = await controller.listBackups();
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(context.l10n.settingsListBackupsError('$error')),
        ),
      );
      return;
    }
    if (!context.mounted) return;
    if (months.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.settingsNoBackupsFound)),
      );
      return;
    }

    final month = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final month in months)
              ListTile(
                title: Text(month),
                onTap: () => Navigator.pop(context, month),
              ),
          ],
        ),
      ),
    );
    if (month == null || !context.mounted) return;

    await _previewAndImport(context, ref, month);
  }

  Future<void> _previewAndImport(
    BuildContext context,
    WidgetRef ref,
    String month,
  ) async {
    final controller = ref.read(backupSettingsProvider.notifier);
    BackupContents contents;
    try {
      contents = await controller.previewBackup(month);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(content: Text(context.l10n.settingsReadBackupError('$error'))),
      );
      return;
    }
    if (!context.mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.settingsImportTitle(month)),
        content: Text(
          context.l10n.settingsImportBody(
            contents.journals.length,
            contents.habits.length,
            contents.habitLogs.length,
            contents.tasks.length,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.settingsImport),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: Spacing.md),
            Text(context.l10n.settingsImporting),
          ],
        ),
      ),
    );
    try {
      final summary = await controller.importBackup(month);
      if (!context.mounted) return;
      Navigator.pop(context);
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(context.l10n.settingsImportCompleteTitle),
          content: Text(
            context.l10n.settingsImportCompleteBody(
              summary.importedJournals,
              summary.importedHabits,
              summary.importedHabitLogs,
              summary.importedTasks,
              summary.importedMoneyEntries,
              summary.skippedJournals +
                  summary.skippedHabits +
                  summary.skippedHabitLogs +
                  summary.skippedTasks +
                  summary.skippedMoneyEntries,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.commonClose),
            ),
          ],
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(content: Text(context.l10n.settingsImportFailed('$error'))),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(backupSettingsProvider);
    final connected = settingsAsync.valueOrNull?.driveConnected ?? false;
    if (!connected) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.settingsDriveRestoreTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: Spacing.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton(
              onPressed: () => _importFromDrive(context, ref),
              child: Text(context.l10n.settingsImportFromDrive),
            ),
          ),
        ],
      ),
    );
  }
}
