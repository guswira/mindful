import 'web_loader_stub.dart'
    if (dart.library.js_interop) 'web_loader_web.dart'
    as platform;

/// Fades out web/index.html's loading screen, revealing the app beneath
/// it. Called once the first real screen (not the splash) has painted, so
/// the loader hands over straight to it. No-op off the web.
void hideWebLoader() => platform.hideWebLoader();
