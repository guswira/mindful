---
paths:
  - "lib/**/*.dart"
---

- Extract repeated widget subtrees into private `_MyWidget` classes, not methods,
  so Flutter can skip rebuilds.
- Use `RepaintBoundary` around widgets that animate independently.
- Avoid `setState` on a parent when only a child needs to rebuild.
- `const` constructors on leaf widgets eliminate rebuild cost entirely.
- Prefer `EdgeInsets.symmetric` / `.only` over `.all` when sides differ.
- Keep files under ~200 lines. If a file grows beyond that, split by responsibility.