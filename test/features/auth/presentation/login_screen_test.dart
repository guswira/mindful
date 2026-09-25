import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:supabase_flutter/supabase_flutter.dart' show AuthException;

import 'package:mindfull/features/auth/domain/auth_state.dart';
import 'package:mindfull/features/auth/presentation/login_screen.dart';

class _FailingAuthNotifier extends AuthNotifier {
  @override
  AuthState build() => const AuthState.unauthenticated();

  @override
  Future<void> signIn() async =>
      throw const AuthException('Unacceptable audience in id_token');
}

void main() {
  testWidgets('shows a "Sign in with Google" button and nothing else', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: LoginScreen())),
    );

    expect(find.byIcon(Icons.login), findsOneWidget);
    expect(find.text('Sign in with Google'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('a Supabase token-exchange failure clears the spinner and '
      'shows the error', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authNotifierProvider.overrideWith(_FailingAuthNotifier.new),
        ],
        child: const MaterialApp(home: LoginScreen()),
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
}
