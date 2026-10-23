import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as lg;

import '../../features/settings/data/settings_repository.dart';
import '../platform/platform_features.dart';
import 'glass_style.dart';

/// The glass style picked in Settings — [defaultStyle] until [restore]
/// loads a saved choice at startup.
///
/// Hand-written rather than @Riverpod: riverpod_generator's analyzer 7
/// crashes on the current SDK's syntax (see SPEC.md Stack decisions).
class GlassStyleController extends Notifier<GlassStyle> {
  /// The style until the user picks one: frosted on web — the liquid
  /// glass shaders are heavy for a browser tab (and laptops on battery),
  /// while BackdropFilter blur is cheap there — liquid everywhere else.
  static GlassStyle get defaultStyle =>
      isWebPlatform ? GlassStyle.frosted : GlassStyle.liquid;

  @override
  GlassStyle build() => defaultStyle;

  /// Loads the saved choice. Awaited in main() before the first frame so
  /// the app never shows a frame in the other style.
  Future<void> restore() async {
    state =
        await ref.read(settingsRepositoryProvider).readGlassStyle() ??
        defaultStyle;
  }

  /// Persists [style] and restyles the app — after loading the liquid
  /// glass shaders when switching to liquid, since main() skips them in
  /// frosted style.
  Future<void> select(GlassStyle style) async {
    if (style == GlassStyle.liquid && state != GlassStyle.liquid) {
      await lg.LiquidGlassWidgets.initialize();
    }
    state = style;
    await ref.read(settingsRepositoryProvider).writeGlassStyle(style);
  }
}

/// The app-wide [GlassStyleController]; kept alive for the app's lifetime.
final glassStyleControllerProvider =
    NotifierProvider<GlassStyleController, GlassStyle>(
      GlassStyleController.new,
    );
