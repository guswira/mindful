/// The app-wide glass look, picked in Settings → Glass style — the one
/// style reference every glass widget reads (via `GlassStyleScope.of`)
/// instead of deciding its look on its own. See SPEC.md Glass style.
///
/// Kept free of Flutter imports: settings_repository.dart (code-generated)
/// imports it, and the generators' pinned analyzer can't read the newer
/// Flutter SDK source — see build.yaml.
enum GlassStyle {
  /// Shader-refracted glass with springy, morphing interactions
  /// (liquid_glass_widgets) and the platform's tab bar position.
  liquid,

  /// The original blurred glass (BackdropFilter) and bottom nav island.
  /// Lighter on the GPU — a fallback for older phones.
  frosted;

  /// Parses a value written by [name]; anything unknown means [liquid].
  static GlassStyle fromStorage(String? value) => GlassStyle.values.firstWhere(
    (style) => style.name == value,
    orElse: () => liquid,
  );
}
