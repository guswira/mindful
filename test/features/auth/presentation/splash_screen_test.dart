import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindfull/features/auth/presentation/splash_screen.dart';

void main() {
  testWidgets('shows a loading indicator while auth state resolves', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: SplashScreen())),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
