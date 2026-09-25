import 'package:flutter/material.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../shared/widgets/glass_card.dart';
import 'habit_form.dart' show habitWeekdayLabels;

/// The "Reminder" section of [AddHabitSheet]: an on/off switch, its time
/// once enabled, and which days it repeats on.
class HabitReminderSection extends StatelessWidget {
  const HabitReminderSection({
    required this.enabled,
    required this.time,
    required this.days,
    required this.onEnabledChanged,
    required this.onPickTime,
    required this.onDayToggled,
    super.key,
  });

  final bool enabled;
  final TimeOfDay? time;
  final List<int> days;
  final ValueChanged<bool> onEnabledChanged;
  final VoidCallback onPickTime;
  final ValueChanged<int> onDayToggled;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Switch(
              value: enabled,
              activeThumbColor: glass.habitAccent,
              onChanged: onEnabledChanged,
            ),
            const Spacer(),
            if (enabled && time != null)
              GestureDetector(
                onTap: onPickTime,
                child: Text(
                  time!.format(context),
                  style: TextStyle(
                    color: glass.habitAccent,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: enabled
              ? _RepeatDays(days: days, onDayToggled: onDayToggled)
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _RepeatDays extends StatelessWidget {
  const _RepeatDays({required this.days, required this.onDayToggled});

  final List<int> days;
  final ValueChanged<int> onDayToggled;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final labels = habitWeekdayLabels(context.l10n);
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.habitRepeatOn,
            style: TextStyle(color: glass.textMuted, fontSize: 13),
          ),
          const SizedBox(height: Spacing.sm),
          Wrap(
            spacing: 6,
            children: [
              for (var day = 0; day < labels.length; day++)
                _DayChip(
                  label: labels[day],
                  selected: days.contains(day),
                  onTap: () => onDayToggled(day),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
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
    final chip = GlassCard(
      strong: selected,
      borderRadius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          color: selected ? glass.habitAccent : glass.textMuted,
        ),
      ),
    );
    return GestureDetector(
      onTap: onTap,
      child: selected
          ? DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: glass.habitAccent, width: 1),
              ),
              child: chip,
            )
          : chip,
    );
  }
}
