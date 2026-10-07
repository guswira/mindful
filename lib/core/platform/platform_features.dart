import 'package:flutter/foundation.dart';

/// Whether this is a phone build (iOS/Android) rather than desktop or web.
///
/// home_widget, quick_actions and image_picker's camera source only ship
/// phone implementations — calling them elsewhere throws
/// MissingPluginException. Reads [defaultTargetPlatform] so tests can
/// override it.
bool get isPhonePlatform =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android);
