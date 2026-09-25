---
paths:
  - "test/**/*.dart"
---

- Use `testWidgets` with `tester.pumpWidget(const ProviderScope(child: App()))`.
- Prefer `find.byType` over `find.text` for localized strings.
- Golden tests live in `test/golden/` and only run with `--update-goldens` when asked.