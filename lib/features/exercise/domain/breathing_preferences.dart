import 'package:freezed_annotation/freezed_annotation.dart';

part 'breathing_preferences.freezed.dart';
part 'breathing_preferences.g.dart';

/// A looping background sound bundled under `assets/ambience/`.
enum AmbienceTrack {
  none,
  rain,
  ocean,
  wind,
  drone;

  /// Path relative to `assets/` (what audioplayers' `AssetSource` expects),
  /// or null for [none].
  String? get assetPath => this == none ? null : 'ambience/$name.wav';
}

/// Device-local sound and Customize-pattern settings for breathing
/// sessions. Not synced — like the custom background, it's a preference
/// for this device, not user data.
@freezed
abstract class BreathingPreferences with _$BreathingPreferences {
  const factory BreathingPreferences({
    @Default(true) bool voiceEnabled,
    @Default(0.8) double voiceVolume,
    @Default(AmbienceTrack.rain) AmbienceTrack ambience,
    @Default(0.5) double ambienceVolume,
    @Default(CustomBreathing()) CustomBreathing custom,
  }) = _BreathingPreferences;

  factory BreathingPreferences.fromJson(Map<String, dynamic> json) =>
      _$BreathingPreferencesFromJson(json);
}

/// Second counts for the Customize exercise. Inhale and exhale are at
/// least [minBreath]; either hold may be 0, which skips that step.
@freezed
abstract class CustomBreathing with _$CustomBreathing {
  const factory CustomBreathing({
    @Default(4) int inhale,
    @Default(2) int hold,
    @Default(6) int exhale,
    @Default(0) int holdAfter,
  }) = _CustomBreathing;

  factory CustomBreathing.fromJson(Map<String, dynamic> json) =>
      _$CustomBreathingFromJson(json);

  /// Shortest allowed inhale/exhale, in seconds.
  static const int minBreath = 1;

  /// Longest allowed count for any step, in seconds.
  static const int maxSeconds = 20;
}
