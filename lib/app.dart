import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/l10n/app_language.dart';
import 'core/l10n/app_language_controller.dart';
import 'core/l10n/l10n.dart';
import 'core/router/router.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/presentation/custom_background_controller.dart';
import 'shared/widgets/app_background_scope.dart';

/// Root widget — MaterialApp.router wired to [appRouterProvider],
/// [AppTheme], and the language and background photo chosen in Settings.
class App extends ConsumerWidget {
  const App({super.key});

  /// Also keeps [currentL10n] in step with the resolved locale, so
  /// context-free copy (notifications, services) matches the UI.
  static Locale _resolveLocale(Locale? locale, Iterable<Locale> _) {
    final resolved = resolveAppLocale(locale);
    setCurrentAppLocale(resolved);
    return resolved;
  }

  static String _title(BuildContext context) => context.l10n.appTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backgroundPath = ref
        .watch(customBackgroundControllerProvider)
        .valueOrNull;
    return MaterialApp.router(
      onGenerateTitle: _title,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      locale: ref.watch(appLanguageControllerProvider).locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      localeResolutionCallback: _resolveLocale,
      routerConfig: ref.watch(appRouterProvider),
      builder: (context, child) => AppBackgroundScope(
        imagePath: backgroundPath,
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
