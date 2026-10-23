import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as lg;

import 'core/l10n/app_language.dart';
import 'core/l10n/app_language_controller.dart';
import 'core/l10n/l10n.dart';
import 'core/router/router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/glass_style_scope.dart';
import 'core/theme/glass_style_controller.dart';
import 'features/settings/presentation/custom_background_controller.dart';
import 'shared/services/ai_activity.dart';
import 'shared/widgets/ai_activity_indicator.dart';
import 'shared/widgets/app_background_scope.dart';
import 'shared/widgets/glass_scroll_behavior.dart';

/// Root widget — MaterialApp.router wired to [appRouterProvider],
/// [AppTheme], the language, background photo and glass style chosen in
/// Settings, the liquid glass navigation shell and the AI activity pill.
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
    final glassStyle = ref.watch(glassStyleControllerProvider);
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
      scrollBehavior: const GlassScrollBehavior(),
      builder: (context, child) => GlassStyleScope(
        style: glassStyle,
        child: AppBackgroundScope(
          imagePath: backgroundPath,
          // Publishes iPhone Duo's vertical bar strip to the tab bar (see
          // NavPlacement.verticalStrip); inert everywhere else.
          child: lg.GlassNavigationShell(
            // Glass menus portal to the root overlay, outside every route's
            // Scaffold — this gives their text a Material ancestor.
            child: Material(
              type: MaterialType.transparency,
              child: Consumer(
                builder: (context, ref, router) => AiActivityOverlay(
                  activities: ref.watch(aiActivityProvider),
                  onDismiss: ref.read(aiActivityProvider.notifier).finish,
                  child: router ?? const SizedBox.shrink(),
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
