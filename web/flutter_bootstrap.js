{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  config: {
    // Skwasm runs single-threaded on purpose: multi-threading needs the
    // COOP/COEP headers, which can break the Google sign-in and Drive
    // popups (see SPEC.md Web, Load speed).
    suppressMultithreadingWarning: true,
  },
  // No serviceWorkerSettings: Flutter's service worker is deprecated (the
  // generated one is an empty stub), and web/_headers handles caching.
});
