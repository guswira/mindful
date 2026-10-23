import 'package:flutter/widgets.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart'
    show LiquidGlassSettings;

/// The app's liquid glass materials (liquid_glass_widgets), tuned for the
/// dark navy + blob background — every glass surface reads one of these
/// rather than inventing its own.
///
/// Content cards stay closer to the old frosted look (more blur, a little
/// white body) so text on them stays readable over a busy custom photo;
/// navigation chrome is thicker and clearer, so it visibly refracts the
/// content scrolling under it, as on iOS 26.
abstract final class LiquidGlassPresets {
  /// Content cards — `GlassCard`.
  static const LiquidGlassSettings card = LiquidGlassSettings(
    glassColor: Color(0x0FFFFFFF),
    thickness: 16,
    blur: 14,
    lightIntensity: 0.45,
    saturation: 1.4,
    chromaticAberration: 0.005,
  );

  /// Strong cards — sheets, dialogs, highlighted cards.
  static const LiquidGlassSettings strongCard = LiquidGlassSettings(
    glassColor: Color(0x17FFFFFF),
    thickness: 22,
    blur: 18,
    lightIntensity: 0.55,
    saturation: 1.4,
    chromaticAberration: 0.008,
  );

  /// Floating chrome — the tab bar, write button and glass icon buttons.
  static const LiquidGlassSettings chrome = LiquidGlassSettings(
    glassColor: Color(0x14FFFFFF),
    thickness: 28,
    blur: 8,
    lightIntensity: 0.65,
    saturation: 1.6,
    chromaticAberration: 0.012,
  );

  /// [chrome] tinted with [color] — the prominent (tinted) glass iOS uses
  /// for a screen's primary action, e.g. the write button. Mostly opaque,
  /// so a dark glyph on it stays readable over any background.
  static LiquidGlassSettings tinted(Color color) => LiquidGlassSettings(
    glassColor: color.withValues(alpha: 0.8),
    thickness: 28,
    blur: 8,
    lightIntensity: 0.7,
    saturation: 1.6,
    chromaticAberration: 0.012,
  );
}
