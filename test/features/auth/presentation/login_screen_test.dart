import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:supabase_flutter/supabase_flutter.dart' show AuthException;

import 'package:mindful/core/l10n/app_language.dart';
import 'package:mindful/core/l10n/app_language_controller.dart';
import 'package:mindful/core/l10n/l10n.dart';
import 'package:mindful/core/theme/app_theme.dart';
import 'package:mindful/features/auth/domain/auth_state.dart';
import 'package:mindful/features/auth/presentation/login_screen.dart';
import 'package:mindful/features/auth/presentation/widgets/login_feature_carousel.dart';
import 'package:mindful/features/settings/data/settings_repository.dart';

class _FailingAuthNotifier extends AuthNotifier {
  @override
  AuthState build() => const AuthState.unauthenticated();

  @override
  Future<void> signIn() async =>
      throw const AuthException('Unacceptable audience in id_token');
}

class _FakeSettingsRepository extends Fake implements SettingsRepository {
  @override
  Future<void> writeAppLanguage(AppLanguage language) async {}
}

/// Rebuilds MaterialApp with the picked language, like `App` does.
class _LocalizedApp extends ConsumerWidget {
  const _LocalizedApp();

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp(
    theme: AppTheme.dark,
    locale: ref.watch(appLanguageControllerProvider).locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: const LoginScreen(),
  );
}

/// The login screen with animations off, so the carousel holds still and
/// `pumpAndSettle` can settle.
Widget _app({List overrides = const [], bool disableAnimations = true}) =>
    ProviderScope(
      overrides: [...overrides],
      child: MaterialApp(
        theme: AppTheme.dark,
        home: Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(disableAnimations: disableAnimations),
            child: const LoginScreen(),
          ),
        ),
      ),
    );

void main() {
  testWidgets('shows the feature tour and a "Sign in with Google" button', (
    tester,
  ) async {
    await tester.pumpWidget(_app());

    expect(find.byIcon(Icons.login), findsOneWidget);
    expect(find.text('Sign in with Google'), findsOneWidget);
    expect(find.text('Daily journal'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('swiping the tour moves to the next feature', (tester) async {
    await tester.pumpWidget(_app());

    await tester.fling(find.byType(PageView), const Offset(-400, 0), 1000);
    await tester.pumpAndSettle();

    expect(find.text('Tasks & routines'), findsOneWidget);
    expect(find.text('Daily journal'), findsNothing);
  });

  testWidgets('the tour advances on its own when animations are on', (
    tester,
  ) async {
    await tester.pumpWidget(_app(disableAnimations: false));

    await tester.pump(LoginFeatureCarousel.autoAdvanceInterval);
    // The idle animation loops forever, so pump through the page
    // transition instead of settling.
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Tasks & routines'), findsOneWidget);
  });

  testWidgets('the tour holds still when animations are disabled', (
    tester,
  ) async {
    await tester.pumpWidget(_app());

    await tester.pump(LoginFeatureCarousel.autoAdvanceInterval * 2);
    await tester.pumpAndSettle();

    expect(find.text('Daily journal'), findsOneWidget);
  });

  testWidgets('a Supabase token-exchange failure clears the spinner and '
      'shows the error', (tester) async {
    await tester.pumpWidget(
      _app(
        overrides: [
          authNotifierProvider.overrideWith(_FailingAuthNotifier.new),
        ],
      ),
    );

    await tester.tap(find.text('Sign in with Google'));
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(
      find.text('Sign in failed: Unacceptable audience in id_token'),
      findsOneWidget,
    );
  });

  testWidgets('the language button switches the screen to Bahasa', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(
            _FakeSettingsRepository(),
          ),
        ],
        child: const _LocalizedApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bahasa Indonesia'));
    await tester.pumpAndSettle();

    expect(find.text('Masuk dengan Google'), findsOneWidget);
    expect(find.text('Jurnal harian'), findsOneWidget);
  });
}
