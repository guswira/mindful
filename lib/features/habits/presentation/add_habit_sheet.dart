import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../shared/services/notification_service.dart';
import '../../../shared/services/widget_service.dart';
import '../../../shared/widgets/shake_widget.dart';
import '../../../shared/widgets/sheet_header.dart';
import '../../../shared/widgets/tinted_pill.dart';
import '../../auth/domain/auth_state.dart';
import '../data/habit_repository.dart';
import '../domain/habit.dart';
import '../domain/habit_action.dart';
import 'add_habit_sheet_actions.dart';
import 'add_habit_sheet_icon_color.dart';
import 'add_habit_sheet_name_field.dart';
import 'add_habit_sheet_reminder.dart';
import 'habit_form.dart' show generateHabitFormId;

/// Bottom sheet to create or edit a habit: name, icon, color, reminder and
/// custom actions. See SPEC.md Habit Tracker and the bottom-sheet design
/// rules.
///
/// Passing [habit] pre-fills the form and switches saving to an update —
/// used by the habit row's long-press options and by the detail screen's
/// edit button.
class AddHabitSheet extends ConsumerStatefulWidget {
  const AddHabitSheet({this.habit, super.key});

  final Habit? habit;

  @override
  ConsumerState<AddHabitSheet> createState() => _AddHabitSheetState();
}

class _AddHabitSheetState extends ConsumerState<AddHabitSheet> {
  static const _defaultReminderTime = TimeOfDay(hour: 8, minute: 0);
  static const _defaultReminderDays = [0, 1, 2, 3, 4];

  final _nameController = TextEditingController();
  final _nameShake = GlobalKey<ShakeWidgetState>();
  String _icon = habitSheetIconPresets.first;
  String _color = habitSheetColorPresets.first;
  List<HabitAction> _actions = const [];
  bool _reminderEnabled = false;
  List<int> _reminderDays = const [];
  TimeOfDay? _reminderTime;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final habit = widget.habit;
    if (habit != null) {
      _nameController.text = habit.name;
      _icon = habit.icon;
      _color = habit.color;
      _actions = habit.actions;
      _reminderEnabled = habit.reminderDays.isNotEmpty;
      _reminderDays = habit.reminderDays;
      _reminderTime = habit.reminderTime;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _setReminderEnabled(bool enabled) {
    setState(() {
      _reminderEnabled = enabled;
      if (enabled) {
        _reminderTime ??= _defaultReminderTime;
        if (_reminderDays.isEmpty) {
          _reminderDays = _defaultReminderDays;
        }
      }
    });
  }

  void _toggleDay(int day) {
    setState(() {
      _reminderDays = _reminderDays.contains(day)
          ? [
              for (final existing in _reminderDays)
                if (existing != day) existing,
            ]
          : ([..._reminderDays, day]..sort());
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? _defaultReminderTime,
    );
    if (!mounted || picked == null) {
      return;
    }
    setState(() => _reminderTime = picked);
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _nameShake.currentState?.shake();
      return;
    }

    setState(() => _saving = true);
    final reminderDays = _reminderEnabled ? _reminderDays : const <int>[];
    final reminderTime = _reminderEnabled ? _reminderTime : null;

    final existing = widget.habit;
    final habit = existing == null
        ? Habit(
            id: generateHabitFormId(),
            userId: ref.read(currentUserIdProvider),
            name: name,
            icon: _icon,
            color: _color,
            createdAt: DateTime.now(),
            reminderDays: reminderDays,
            reminderTime: reminderTime,
            actions: _actions,
          )
        : existing.copyWith(
            name: name,
            icon: _icon,
            color: _color,
            reminderDays: reminderDays,
            reminderTime: reminderTime,
            actions: _actions,
          );

    final repository = await ref.read(habitRepositoryProvider.future);
    await _saveHabit(repository, habit);
    await _scheduleReminder(habit);
    await refreshWidgetsBestEffort(
      () => ref.read(widgetServiceProvider.future),
    );

    if (!mounted) {
      return;
    }
    Navigator.pop(context);
  }

  Future<void> _saveHabit(HabitRepository repository, Habit habit) async {
    try {
      await repository.saveHabit(habit);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.habitSavedLocallySyncFailed('$error')),
        ),
      );
    }
  }

  /// Best-effort: a scheduling failure (e.g. a platform-channel hiccup)
  /// shouldn't leave this sheet stuck open with the habit already saved.
  Future<void> _scheduleReminder(Habit habit) async {
    try {
      final notificationService = await ref.read(
        notificationServiceProvider.future,
      );
      await notificationService.scheduleHabitReminder(habit);
    } catch (error) {
      // Best-effort — see doc comment — but still worth knowing about.
      debugPrint('Failed to schedule habit reminder: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final l10n = context.l10n;
    final isEditing = widget.habit != null;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SheetHeader(
            title: isEditing ? l10n.habitEditTitle : l10n.habitBuildNewTitle,
            onClose: () => Navigator.pop(context),
          ),
          const SizedBox(height: Spacing.md),
          HabitNameField(shakeKey: _nameShake, controller: _nameController),
          const SizedBox(height: 20),
          _SectionLabel(l10n.habitSectionIcon),
          const SizedBox(height: Spacing.sm),
          HabitIconGrid(
            selected: _icon,
            onChanged: (icon) => setState(() => _icon = icon),
          ),
          const SizedBox(height: 20),
          _SectionLabel(l10n.habitSectionColor),
          const SizedBox(height: Spacing.sm),
          HabitColorRow(
            selected: _color,
            onChanged: (color) => setState(() => _color = color),
          ),
          const SizedBox(height: 20),
          _SectionLabel(l10n.habitSectionReminder),
          const SizedBox(height: Spacing.sm),
          HabitReminderSection(
            enabled: _reminderEnabled,
            time: _reminderTime,
            days: _reminderDays,
            onEnabledChanged: _setReminderEnabled,
            onPickTime: _pickTime,
            onDayToggled: _toggleDay,
          ),
          const SizedBox(height: 20),
          _SectionLabel(l10n.habitSectionCustomActions),
          const SizedBox(height: Spacing.xs),
          Text(
            l10n.habitCustomActionsHint,
            style: TextStyle(color: glass.textHint, fontSize: 12),
          ),
          const SizedBox(height: Spacing.sm),
          HabitActionsInlineEditor(
            actions: _actions,
            onChanged: (actions) => setState(() => _actions = actions),
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            l10n.habitCustomActionsEmptyHint,
            style: TextStyle(color: glass.textHint, fontSize: 11),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: TintedPill(
              label: isEditing ? l10n.habitSaveChanges : l10n.habitAddHabit,
              color: glass.habitAccent,
              onTap: _saving ? null : _save,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return Text(label, style: TextStyle(color: glass.textMuted, fontSize: 13));
  }
}
