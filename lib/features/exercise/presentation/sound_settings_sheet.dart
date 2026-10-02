import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../shared/widgets/group_label.dart';
import '../../../shared/widgets/sheet_header.dart';
import '../domain/breathing_preferences.dart';
import 'breathing_labels.dart';
import 'exercise_providers.dart';

/// Voice guide and ambience settings, opened from a breathing session.
/// Every change applies (and persists) immediately, so the user hears it
/// while the session keeps running behind the sheet.
class SoundSettingsSheet extends ConsumerWidget {
  const SoundSettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences =
        ref.watch(breathingPreferencesControllerProvider).valueOrNull ??
        const BreathingPreferences();
    final controller = ref.read(
      breathingPreferencesControllerProvider.notifier,
    );
    final l10n = context.l10n;
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SheetHeader(
            title: l10n.soundSettingsTitle,
            onClose: () => Navigator.pop(context),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.soundVoiceGuide),
            subtitle: Text(l10n.soundVoiceGuideSubtitle),
            value: preferences.voiceEnabled,
            activeThumbColor: glass.exerciseAccent,
            onChanged: (enabled) =>
                controller.save(preferences.copyWith(voiceEnabled: enabled)),
          ),
          _VolumeSlider(
            label: l10n.soundVoiceVolume,
            value: preferences.voiceVolume,
            enabled: preferences.voiceEnabled,
            onChanged: (volume) =>
                controller.preview(preferences.copyWith(voiceVolume: volume)),
            onChangeEnd: (volume) =>
                controller.save(preferences.copyWith(voiceVolume: volume)),
          ),
          const SizedBox(height: Spacing.md),
          GroupLabel(l10n.soundAmbience),
          const SizedBox(height: Spacing.sm),
          _AmbienceWrap(
            selected: preferences.ambience,
            onChanged: (track) =>
                controller.save(preferences.copyWith(ambience: track)),
          ),
          const SizedBox(height: Spacing.sm),
          _VolumeSlider(
            label: l10n.soundAmbienceVolume,
            value: preferences.ambienceVolume,
            enabled: preferences.ambience != AmbienceTrack.none,
            onChanged: (volume) => controller.preview(
              preferences.copyWith(ambienceVolume: volume),
            ),
            onChangeEnd: (volume) =>
                controller.save(preferences.copyWith(ambienceVolume: volume)),
          ),
        ],
      ),
    );
  }
}

class _VolumeSlider extends StatelessWidget {
  const _VolumeSlider({
    required this.label,
    required this.value,
    required this.enabled,
    required this.onChanged,
    required this.onChangeEnd,
  });

  final String label;
  final double value;

  /// False while the sound it controls is off.
  final bool enabled;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return Row(
      children: [
        Icon(Icons.volume_down_outlined, size: 18, color: glass.textMuted),
        Expanded(
          child: Slider(
            value: value,
            onChanged: enabled ? onChanged : null,
            onChangeEnd: onChangeEnd,
            activeColor: glass.exerciseAccent,
            semanticFormatterCallback: (value) =>
                '$label ${(value * 100).round()}%',
          ),
        ),
        Icon(Icons.volume_up_outlined, size: 18, color: glass.textMuted),
      ],
    );
  }
}

class _AmbienceWrap extends StatelessWidget {
  const _AmbienceWrap({required this.selected, required this.onChanged});

  final AmbienceTrack selected;
  final ValueChanged<AmbienceTrack> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Spacing.sm,
      runSpacing: Spacing.sm,
      children: [
        for (final track in AmbienceTrack.values)
          _AmbienceChip(
            label: context.l10n.ambienceName(track),
            selected: track == selected,
            onTap: () => onChanged(track),
          ),
      ],
    );
  }
}

class _AmbienceChip extends StatelessWidget {
  const _AmbienceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final accent = glass.exerciseAccent;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? accent.withValues(alpha: 0.18) : glass.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? accent.withValues(alpha: 0.25) : glass.cardBorder,
            width: 0.5,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: selected ? Colors.white : glass.textSecondary,
          ),
        ),
      ),
    );
  }
}
