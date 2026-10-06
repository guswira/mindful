import 'package:flutter/material.dart';

import '../../core/theme/glass_theme.dart';
import 'blob_background.dart';

/// Scaffold for full-page screens pushed outside the tab shell: a
/// transparent app bar over [BlobBackground] (custom photo included).
///
/// The body extends behind the app bar — otherwise the bar's strip only
/// shows the plain scaffold color, a dark band with no blobs or photo
/// above the rest of the page. [body] is inset below the bar and status
/// bar via [SafeArea].
class GlassPageScaffold extends StatelessWidget {
  const GlassPageScaffold({
    required this.title,
    required this.body,
    this.actions = const [],
    this.resizeToAvoidBottomInset = true,
    super.key,
  });

  final Widget title;
  final Widget body;
  final List<Widget> actions;
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return Scaffold(
      backgroundColor: glass.background,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: Colors.white,
        leading: const BackButton(color: Colors.white70),
        titleTextStyle: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(color: Colors.white),
        title: title,
        actions: actions,
      ),
      body: RepaintBoundary(
        child: BlobBackground(child: SafeArea(bottom: false, child: body)),
      ),
    );
  }
}
