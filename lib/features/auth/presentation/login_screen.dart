import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthException;

import '../../../core/l10n/l10n.dart';
import '../domain/auth_state.dart';

/// "Sign in with Google" button only — no email/password.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isSigningIn
            ? const CircularProgressIndicator()
            : FilledButton.icon(
                onPressed: _handleSignIn,
                icon: const Icon(Icons.login),
                label: Text(context.l10n.authSignInWithGoogle),
              ),
      ),
    );
  }
}
