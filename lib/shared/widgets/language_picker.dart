import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_language.dart';
import '../../core/l10n/app_language_controller.dart';
import '../../core/l10n/l10n.dart';

/// "System default (English)" etc. — names the language the device
/// currently resolves to, so "system" isn't a mystery choice.
String _systemLabel(AppLocalizations l10n) {
  final deviceLocale = resolveAppLocale(
    WidgetsBinding.instance.platformDispatcher.locale,
  );
  final deviceLanguage = switch (deviceLocale.languageCode) {
    'id' => l10n.languageNameBahasa,
    _ => l10n.languageNameEnglish,
  };
  return l10n.settingsLanguageSystemWithCurrent(deviceLanguage);
}

/// The display name of [language] in the current app language.
String appLanguageLabel(AppLocalizations l10n, AppLanguage language) =>
    switch (language) {
      AppLanguage.system => _systemLabel(l10n),
      AppLanguage.english => l10n.languageNameEnglish,
      AppLanguage.bahasa => l10n.languageNameBahasa,
    };

/// Shows the language sheet (Settings and the login screen share it) and
/// switches the app to the picked language. Dismissing it changes nothing.
Future<void> pickAppLanguage(BuildContext context, WidgetRef ref) async {
  final l10n = context.l10n;
  final current = ref.read(appLanguageControllerProvider);
  final picked = await showModalBottomSheet<AppLanguage>(
    context: context,
    builder: (context) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          for (final language in AppLanguage.values)
            ListTile(
              title: Text(appLanguageLabel(l10n, language)),
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
