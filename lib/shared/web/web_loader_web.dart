import 'dart:js_interop';
import 'dart:js_interop_unsafe';

/// Calls `window.mindfulHideLoader` (web/index.html), if the page has it —
/// a custom index.html or a test page may not.
void hideWebLoader() {
  if (globalContext.has('mindfulHideLoader')) {
    globalContext.callMethod('mindfulHideLoader'.toJS);
  }
}
