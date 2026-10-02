import 'package:flutter/widgets.dart';

/// Hands the user's custom background photo down to every
/// [BlobBackground]. An InheritedWidget rather than a provider so
/// [BlobBackground] stays usable without a ProviderScope (e.g. in widget
/// tests); with no scope above it, the default background is used.
class AppBackgroundScope extends InheritedWidget {
  const AppBackgroundScope({
    required this.imagePath,
    required super.child,
    super.key,
  });

  /// Absolute path of the custom photo; null for the default background.
  final String? imagePath;

  /// The nearest scope's [imagePath], or null if there's none.
  static String? imagePathOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<AppBackgroundScope>()
      ?.imagePath;

  @override
  bool updateShouldNotify(AppBackgroundScope oldWidget) =>
      imagePath != oldWidget.imagePath;
}
