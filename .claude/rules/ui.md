---
paths:
  - "lib/**/presentation/**/*.dart"
  - "lib/**/widgets/**/*.dart"
  - "lib/**/screens/**/*.dart"
  - "lib/**/pages/**/*.dart"
---

- Flat hierarchy: aim for max 4–5 levels of nesting before extracting a widget.
- No magic numbers — spacing and sizing go through a constants file or the theme.
- Adaptive layouts use `LayoutBuilder` or `MediaQuery`, not hardcoded breakpoints.
- One widget = one responsibility. If a widget has more than one visual concern, split it.