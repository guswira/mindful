import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../shared/widgets/sheet_header.dart';
import '../../../shared/widgets/tinted_pill.dart';
import '../domain/breathing_pattern.dart';
import '../domain/breathing_preferences.dart';
import 'exercise_providers.dart';

/// Sets the Customize exercise's second count for each step. Pops with
/// true once saved.
class CustomPatternSheet extends ConsumerStatefulWidget {
  const CustomPatternSheet({required this.initial, super.key});

  final CustomBreathing initial;

  @override
  ConsumerState<CustomPatternSheet> createState() => _CustomPatternSheetState();
}

class _CustomPatternSheetState extends ConsumerState<CustomPatternSheet> {
  late CustomBreathing _custom = widget.initial;

  Future<void> _save() async {
    final controller = ref.read(
      breathingPreferencesControllerProvider.notifier,
    );
    final preferences =
        ref.read(breathingPreferencesControllerProvider).valueOrNull ??
        const BreathingPreferences();
    await controller.save(preferences.copyWith(custom: _custom));
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final glass = Theme.of(context).extension<GlassTheme>()!;
    const breath = CustomBreathing.minBreath;
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SheetHeader(
            title: l10n.customPatternTitle,
            onClose: () => Navigator.pop(context),
          ),
          _StepRow(
            label: l10n.breathingPhaseInhale,
            value: _custom.inhale,
            min: breath,
            onChanged: (v) =>
                setState(() => _custom = _custom.copyWith(inhale: v)),
          ),
          _StepRow(
            label: l10n.breathingPhaseHold,
            value: _custom.hold,
            min: 0,
            onChanged: (v) =>
                setState(() => _custom = _custom.copyWith(hold: v)),
          ),
          _StepRow(
            label: l10n.breathingPhaseExhale,
            value: _custom.exhale,
            min: breath,
            onChanged: (v) =>
                setState(() => _custom = _custom.copyWith(exhale: v)),
          ),
          _StepRow(
            label: l10n.customPatternHoldAfter,
            value: _custom.holdAfter,
            min: 0,
            onChanged: (v) =>
                setState(() => _custom = _custom.copyWith(holdAfter: v)),
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            l10n.customPatternCycle(
              BreathingPattern.custom(_custom).cycleSeconds,
            ),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: glass.textMuted),
          ),
          const SizedBox(height: Spacing.lg),
          SizedBox(
            width: double.infinity,
            child: TintedPill(
              label: l10n.customPatternSave,
              color: glass.exerciseAccent,
              onTap: _save,
            ),
          ),
        ],
      ),
    );
  }
}

/// One step's label with a − / value / + stepper, clamped to
/// [min]…[CustomBreathing.maxSeconds].
class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.label,
    required this.value,
    required this.min,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int min;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: textTheme.bodyLarge?.copyWith(color: Colors.white),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          color: glass.exerciseAccent,
          tooltip: l10n.customPatternDecrease(label),
          onPressed: value > min ? () => onChanged(value - 1) : null,
        ),
        SizedBox(
          width: 52,
          child: Text(
            l10n.customPatternSeconds(value),
            textAlign: TextAlign.center,
            style: textTheme.titleMedium?.copyWith(color: Colors.white),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          color: glass.exerciseAccent,
          tooltip: l10n.customPatternIncrease(label),
          onPressed: value < CustomBreathing.maxSeconds
              ? () => onChanged(value + 1)
              : null,
        ),
      ],
    );
  }
}
