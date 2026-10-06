import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthException;

import '../../../core/constants/spacing.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../shared/widgets/blob_background.dart';
import '../../../shared/widgets/tinted_pill.dart';
import '../domain/auth_state.dart';
import 'widgets/login_feature_carousel.dart';
import 'widgets/login_feature_slide.dart';
import 'widgets/login_language_button.dart';

/// An animated tour of the app's features above a single "Sign in with
/// Google" button — no email/password. The tour is what a new user sees
/// before committing to sign in, so it shows what's waiting on the other
/// side.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  /// About a [TintedPill]'s height, so the spinner doesn't shift the layout.
  static const double _signInButtonHeight = 32;

  bool _isSigningIn = false;

  Future<void> _handleSignIn() async {
    setState(() => _isSigningIn = true);
    Object? error;
    try {
      await ref.read(authNotifierProvider.notifier).signIn();
    } catch (e) {
      // Not just GoogleSignInException — the Supabase token exchange that
      // follows a successful Google sign-in throws AuthException, and
      // letting that escape left the spinner up forever.
      debugPrint('Sign-in failed: $e');
      error = e;
    }

    if (!mounted) return;
    if (_failureDetail(error) case final detail?) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.authSignInFailed(detail))),
      );
    }
    setState(() => _isSigningIn = false);
  }

  /// What to show after "Sign in failed:", or null when there's nothing to
  /// report — no error, or the user cancelled the Google prompt.
  static String? _failureDetail(Object? error) => switch (error) {
    null => null,
    GoogleSignInException(code: GoogleSignInExceptionCode.canceled) => null,
    GoogleSignInException(:final description) => description ?? '',
    AuthException(:final message) => message,
    _ => '$error',
  };

  /// One slide per main feature, each in its tab's accent.
  List<LoginFeature> _features(AppLocalizations l10n, GlassTheme glass) => [
    LoginFeature(
      icon: Icons.menu_book_outlined,
      color: glass.journalAccent,
      title: l10n.loginFeatureJournalTitle,
      body: l10n.loginFeatureJournalBody,
    ),
    LoginFeature(
      icon: Icons.checklist_rounded,
      color: glass.taskAccent,
      title: l10n.loginFeatureRoutinesTitle,
      body: l10n.loginFeatureRoutinesBody,
    ),
    LoginFeature(
      icon: Icons.account_balance_wallet_outlined,
      color: glass.moneyAccent,
      title: l10n.loginFeatureMoneyTitle,
      body: l10n.loginFeatureMoneyBody,
    ),
    LoginFeature(
      icon: Icons.air_rounded,
      color: glass.exerciseAccent,
      title: l10n.loginFeatureBreathingTitle,
      body: l10n.loginFeatureBreathingBody,
    ),
    LoginFeature(
      icon: Icons.restaurant_outlined,
      color: glass.aiAccent,
      title: l10n.loginFeatureAiTitle,
      body: l10n.loginFeatureAiBody,
    ),
    LoginFeature(
      icon: Icons.calendar_month_outlined,
      color: glass.writeAccent,
      title: l10n.loginFeatureRecapTitle,
      body: l10n.loginFeatureRecapBody,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final l10n = context.l10n;
    return Scaffold(
      body: RepaintBoundary(
        child: BlobBackground(
          child: SafeArea(
            child: Column(
              children: [
                const Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      Spacing.md,
                      Spacing.sm,
                      Spacing.md,
                      0,
                    ),
                    child: LoginLanguageButton(),
                  ),
                ),
                Text(
                  l10n.appTitle,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  l10n.loginTagline,
                  style: TextStyle(fontSize: 13, color: glass.textSecondary),
                ),
                Expanded(
                  child: LoginFeatureCarousel(features: _features(l10n, glass)),
                ),
                Padding(
                  padding: const EdgeInsets.all(Spacing.lg),
                  child: _buildSignInButton(l10n, glass),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Full-width [TintedPill] like every other primary action, in the
  /// brand teal; a spinner of the same height while signing in.
  Widget _buildSignInButton(AppLocalizations l10n, GlassTheme glass) {
    if (_isSigningIn) {
      return SizedBox(
        height: _signInButtonHeight,
        child: Center(
          child: SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: glass.writeAccent,
            ),
          ),
        ),
      );
    }
    return SizedBox(
      width: double.infinity,
      child: TintedPill(
        label: l10n.authSignInWithGoogle,
        icon: Icons.login,
        color: glass.writeAccent,
        onTap: _handleSignIn,
      ),
    );
  }
}
