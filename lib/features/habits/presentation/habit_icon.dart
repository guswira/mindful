import 'package:flutter/material.dart';

import '../../../core/theme/glass_theme.dart';
import '../domain/habit.dart';
import 'habit_form.dart' show parseHexColorOr;

/// Flat icon for each preset routine emoji, keyed without the U+FE0F
/// variation selector (see [habitIconData]).
///
/// Routines still store the emoji in `habits.icon` — Drive backups and the
/// native home/lock screen widgets read it as-is — so this mapping is
/// display-only and needs no data migration.
const Map<String, IconData> _habitIcons = {
  '💪': Icons.sports_gymnastics_rounded,
  '🏃': Icons.directions_run_rounded,
  '📚': Icons.menu_book_rounded,
  '🧘': Icons.self_improvement_rounded,
  '💧': Icons.water_drop_outlined,
  '🥗': Icons.restaurant_rounded,
  '😴': Icons.bedtime_outlined,
  '🎯': Icons.track_changes_rounded,
  '✍': Icons.edit_rounded,
  '🎵': Icons.music_note_rounded,
  '🌿': Icons.spa_outlined,
  '🧹': Icons.cleaning_services_outlined,
  '💊': Icons.medication_outlined,
  '🛁': Icons.bathtub_outlined,
  '🌅': Icons.wb_twilight_rounded,
  '🏋': Icons.fitness_center_rounded,
  '🚴': Icons.directions_bike_rounded,
  '🧠': Icons.psychology_outlined,
  '❤': Icons.favorite_outline_rounded,
  '⭐': Icons.star_outline_rounded,
};

/// The flat icon for a stored routine [emoji], or null for one outside the
/// presets. Ignores U+FE0F, which some keyboards add and others don't.
IconData? habitIconData(String emoji) =>
    _habitIcons[emoji.replaceAll('\uFE0F', '')];

/// [habit]'s user-picked color (`habits.color`), or habitAccent when it
/// won't parse — what its icon, action chips and logged state are tinted.
Color routineColorOf(BuildContext context, Habit habit) => parseHexColorOr(
  habit.color,
  Theme.of(context).extension<GlassTheme>()!.habitAccent,
);

/// A routine's icon: the preset's flat icon in the routine's color, or the
/// stored emoji itself when there's no matching icon.
class HabitIcon extends StatelessWidget {
  /// [habit]'s icon in [Habit.color] (habitAccent if that won't parse).
  HabitIcon.of(Habit habit, {this.size = 20, super.key})
    : icon = habit.icon,
      hexColor = habit.color,
      color = null;

  /// A stored emoji [icon] in an explicit [color] (e.g. the icon picker).
  const HabitIcon({
    required this.icon,
    required Color this.color,
    this.size = 20,
    super.key,
  }) : hexColor = null;

  /// The stored `habits.icon` emoji.
  final String icon;
  final Color? color;
  final String? hexColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).extension<GlassTheme>()!.habitAccent;
    final resolved = color ?? parseHexColorOr(hexColor ?? '', accent);
    return switch (habitIconData(icon)) {
      final data? => Icon(data, size: size, color: resolved),
      null => Text(icon, style: TextStyle(fontSize: size)),
    };
  }
}
