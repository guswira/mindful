// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'breathing_preferences.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BreathingPreferences _$BreathingPreferencesFromJson(
  Map<String, dynamic> json,
) => _BreathingPreferences(
  voiceEnabled: json['voiceEnabled'] as bool? ?? true,
  voiceVolume: (json['voiceVolume'] as num?)?.toDouble() ?? 0.8,
  ambience:
      $enumDecodeNullable(_$AmbienceTrackEnumMap, json['ambience']) ??
      AmbienceTrack.rain,
  ambienceVolume: (json['ambienceVolume'] as num?)?.toDouble() ?? 0.5,
  custom: json['custom'] == null
      ? const CustomBreathing()
      : CustomBreathing.fromJson(json['custom'] as Map<String, dynamic>),
);

Map<String, dynamic> _$BreathingPreferencesToJson(
  _BreathingPreferences instance,
) => <String, dynamic>{
  'voiceEnabled': instance.voiceEnabled,
  'voiceVolume': instance.voiceVolume,
  'ambience': _$AmbienceTrackEnumMap[instance.ambience]!,
  'ambienceVolume': instance.ambienceVolume,
  'custom': instance.custom.toJson(),
};

const _$AmbienceTrackEnumMap = {
  AmbienceTrack.none: 'none',
  AmbienceTrack.rain: 'rain',
  AmbienceTrack.ocean: 'ocean',
  AmbienceTrack.wind: 'wind',
  AmbienceTrack.drone: 'drone',
};

_CustomBreathing _$CustomBreathingFromJson(Map<String, dynamic> json) =>
    _CustomBreathing(
      inhale: (json['inhale'] as num?)?.toInt() ?? 4,
      hold: (json['hold'] as num?)?.toInt() ?? 2,
      exhale: (json['exhale'] as num?)?.toInt() ?? 6,
      holdAfter: (json['holdAfter'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$CustomBreathingToJson(_CustomBreathing instance) =>
    <String, dynamic>{
      'inhale': instance.inhale,
      'hold': instance.hold,
      'exhale': instance.exhale,
      'holdAfter': instance.holdAfter,
    };
