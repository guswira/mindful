import 'package:flutter/widgets.dart';

import 'glass_style.dart';

/// Hands the chosen [GlassStyle] down to every glass widget. An
/// InheritedWidget rather than a provider so the widgets stay usable
/// without a ProviderScope (e.g. widget tests); with no scope above them
/// they draw [GlassStyle.liquid].
class GlassStyleScope extends InheritedWidget {
  const GlassStyleScope({required this.style, required super.child, super.key});

  final GlassStyle style;

  /// The nearest scope's [style], or [GlassStyle.liquid] if there's none.
  static GlassStyle of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<GlassStyleScope>()?.style ??
      GlassStyle.liquid;

  @override
  bool updateShouldNotify(GlassStyleScope oldWidget) =>
      style != oldWidget.style;
}
