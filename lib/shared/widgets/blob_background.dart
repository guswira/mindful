import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/constants/layout.dart';
import '../../core/theme/glass_theme.dart';
import 'app_background_scope.dart';

/// The 3-blob blurred background layer used behind content on every main
/// screen, per the frosted glass dark theme.
///
/// With a custom photo set in Settings (via [AppBackgroundScope]) the photo
/// fills the screen under a background-colored scrim, and the blobs and
/// glass content sit on top as usual — so cards and text stay legible on
/// any photo, bright or busy.
///
/// [child] sits in a [BackdropGroup], so every `GlassCard` on the screen
/// shares one backdrop read — see `GlassCard` for why.
class BlobBackground extends StatelessWidget {
  const BlobBackground({
    required this.child,
    this.maxContentWidth = AppLayout.maxContentWidth,
    super.key,
  });

  final Widget child;

  /// How wide [child] may get on a big screen — wider for list + detail
  /// layouts ([AppLayout.maxTwoPaneWidth]).
  final double maxContentWidth;

  @override
  Widget build(BuildContext context) {
    final imagePath = AppBackgroundScope.imagePathOf(context);
    final separator = AppLayout.verticalSeparator(context);
    // Capped so content doesn't stretch across a Mac/iPad window, while
    // the photo and blobs above still fill it.
    final content = Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxContentWidth),
        child: BackdropGroup(child: child),
      ),
    );
    return Stack(
      children: [
        if (imagePath != null)
          Positioned.fill(child: _CustomPhoto(path: imagePath)),
        const Positioned.fill(child: IgnorePointer(child: _Blobs())),
        // On a screen split by a hinge / half-open fold, a capped (single
        // column) screen moves onto the left half rather than straddling
        // the split; an uncapped one (list + detail) lines up with it
        // itself. Every BlobBackground fills the screen, so the
        // separator's screen x is also x here.
        if (separator != null && maxContentWidth.isFinite)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: separator.left,
            child: content,
          )
        else
          content,
      ],
    );
  }
}

/// How much of the theme background color covers a custom photo.
const double customBackgroundScrimOpacity = 0.55;

class _CustomPhoto extends StatelessWidget {
  const _CustomPhoto({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    final scrim =
        Theme.of(context).extension<GlassTheme>()?.background ??
        const Color(0xFF0A1628);
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(
            File(path),
            fit: BoxFit.cover,
            gaplessPlayback: true,
            // The file can vanish (cleared app data, restored backup) —
            // fall back to the plain background rather than an error box.
            errorBuilder: (context, error, stackTrace) =>
                const SizedBox.shrink(),
          ),
          ColoredBox(
            color: scrim.withValues(alpha: customBackgroundScrimOpacity),
          ),
        ],
      ),
    );
  }
}

class _Blobs extends StatelessWidget {
  const _Blobs();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        Positioned(
          top: -40,
          right: -30,
          child: _Blob(size: 200, color: Color(0xFF14E6AA), opacity: 0.18),
        ),
        Positioned(
          bottom: 200,
          left: -40,
          child: _Blob(size: 160, color: Color(0xFF378ADD), opacity: 0.18),
        ),
        Positioned(
          top: 280,
          right: 20,
          child: _Blob(size: 120, color: Color(0xFF9E9E9E), opacity: 0.12),
        ),
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.color, required this.opacity});

  final double size;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withValues(alpha: opacity),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
