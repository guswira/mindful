import 'package:json_annotation/json_annotation.dart';

/// The breathing exercises on the Exercise tab.
///
/// Stored by its [JsonValue] in `breathing_sessions.exercise`, so a Dart
/// rename never orphans old rows. [name] is used in the session route
/// (`/exercise/breathing/:exercise`).
enum BreathingExercise {
  @JsonValue('equal')
  equal,
  @JsonValue('box')
  box,
  @JsonValue('4_7_8')
  fourSevenEight,
  @JsonValue('hold_test')
  holdTest,
  @JsonValue('custom')
  custom;

  /// The exercise whose [name] is [value], or null for an unknown route.
  static BreathingExercise? fromName(String? value) =>
      values.asNameMap()[value];
}
