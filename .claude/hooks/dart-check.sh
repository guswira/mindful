#!/bin/bash
# PostToolUse: format the edited Dart file, then analyze only that file.
input=$(cat)
file=$(jq -r '.tool_input.file_path // empty' <<<"$input")

# Skip non-Dart and generated files
case "$file" in
  *.g.dart|*.freezed.dart|*.mocks.dart) exit 0 ;;
  *.dart) ;;
  *) exit 0 ;;
esac

# Format silently
dart format "$file" >/dev/null 2>&1

# Analyze only this file, cap output
out=$(dart analyze "$file" 2>&1 \
      | grep -E '^[[:space:]]+(error|warning)' \
      | head -15)

if [ -n "$out" ]; then
  echo "$out" >&2
  exit 2   # shows stderr to Claude for PostToolUse
fi
exit 0