import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/glass_theme.dart';

/// Builds a screen from a deferred library once [load] (its
/// `loadLibrary`) completes — on web that library is a separate .js file
/// fetched on first use, which keeps it out of the first download. Native
/// builds load it at once.
///
/// Shows the app background while loading (a spinner only if it takes a
/// moment), and a retry if the download fails.
class DeferredScreen extends StatefulWidget {
  const DeferredScreen({required this.load, required this.builder, super.key});

  /// The deferred library's `loadLibrary`.
  final Future<void> Function() load;

  /// Builds the screen; only called after [load] has completed.
  final WidgetBuilder builder;

  @override
  State<DeferredScreen> createState() => _DeferredScreenState();
}

class _DeferredScreenState extends State<DeferredScreen> {
  late Future<void> _loading = widget.load();

  void _retry() {
    final loading = widget.load();
    setState(() {
      _loading = loading;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loading,
      builder: (context, snapshot) => switch (snapshot) {
        AsyncSnapshot(connectionState: ConnectionState.done, hasError: false) =>
          widget.builder(context),
        AsyncSnapshot(hasError: true) => _LoadFailed(onRetry: _retry),
        _ => const _Loading(),
      },
    );
  }
}

/// The app background, plus a spinner once loading passes a short delay —
/// a fast load never flashes it.
class _Loading extends StatefulWidget {
  const _Loading();

  @override
  State<_Loading> createState() => _LoadingState();
}

class _LoadingState extends State<_Loading> {
  static const Duration _spinnerDelay = Duration(milliseconds: 300);

  late final Timer _timer;
  bool _showSpinner = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(_spinnerDelay, () => setState(() => _showSpinner = true));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return ColoredBox(
      color: glass.background,
      child: Center(
        child: _showSpinner
            ? CircularProgressIndicator(color: glass.writeAccent)
            : null,
      ),
    );
  }
}

class _LoadFailed extends StatelessWidget {
  const _LoadFailed({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: glass.background,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.commonPageLoadFailed,
              textAlign: TextAlign.center,
              style: TextStyle(color: glass.textSecondary),
            ),
            TextButton(onPressed: onRetry, child: Text(l10n.commonRetry)),
          ],
        ),
      ),
    );
  }
}
