import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/auth_state.dart';

/// Shown while the silent sign-in check runs.
///
/// Holds no navigation logic itself: once [authNotifierProvider] resolves
/// to authenticated or unauthenticated, the router's redirect guard moves
/// on from here.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(authNotifierProvider);
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
