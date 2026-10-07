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
import '../../tasks/data/task_repository.dart';
import '../../tasks/domain/task.dart';
import '../../tasks/presentation/task_tab.dart';
import '../data/habit_repository.dart';
import '../domain/habit.dart';
import '../domain/habit_action.dart';
import '../domain/habit_tag.dart';
import 'add_habit_sheet_actions.dart';
import 'add_habit_sheet_icon_color.dart';
import 'add_habit_sheet_name_field.dart';
import 'add_habit_sheet_reminder.dart';
import 'habit_tab.dart';
import 'habit_form.dart' show generateHabitFormId;

/// Bottom sheet to create or edit a habit: name, icon, color, reminder and
/// custom actions. See SPEC.md Habit Tracker and the bottom-sheet design
/// rules.
///
/// Passing [habit] pre-fills the form and switches saving to an update —
/// used by the habit row's long-press options and by the detail screen's
/// edit button.
///
/// Passing [fromTask] instead converts that task into a new routine: the
/// name (and reminder time, if it had one) are pre-filled, and the task is
/// deleted once the routine is saved. See SPEC.md Tasks & Routines.
class AddHabitSheet extends ConsumerStatefulWidget {
  const AddHabitSheet({this.habit, this.fromTask, super.key})
    : assert(habit == null || fromTask == null);

  final Habit? habit;
  final Task? fromTask;

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
  List<HabitTag> _tags = const [];
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
      _tags = habit.tagList;
      _reminderEnabled = habit.reminderDays.isNotEmpty;
      _reminderDays = habit.reminderDays;
      _reminderTime = habit.reminderTime;
    }
    final task = widget.fromTask;
    if (task != null) {
      _nameController.text = task.name;
      if (task.reminderAt case final reminderAt?) {
        _reminderEnabled = true;
        _reminderDays = _defaultReminderDays;
        _reminderTime = TimeOfDay.fromDateTime(reminderAt);
      }
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
    final tags = _savedTags();

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
            tags: tags,
          )
        : existing.copyWith(
            name: name,
            icon: _icon,
            color: _color,
            reminderDays: reminderDays,
            reminderTime: reminderTime,
            actions: _actions,
            tags: tags,
          );

    final repository = await ref.read(habitRepositoryProvider.future);
    await _saveHabit(repository, habit);
    await _scheduleReminder(habit);
    if (widget.fromTask case final task?) {
      await _deleteConvertedTask(task);
    }
    ref.invalidate(habitTabControllerProvider);
    await refreshWidgetsBestEffort(
      () => ref.read(widgetServiceProvider.future),
    );

    if (!mounted) {
      return;
    }
    Navigator.pop(context);
  }

  /// The tags to save: blank ones dropped, and null (key left out of the
  /// upsert — see [Habit.tags]) while the habit has never had any.
  List<HabitTag>? _savedTags() {
    final tags = [
      for (final tag in _tags)
        if (tag.label.trim().isNotEmpty) tag.copyWith(label: tag.label.trim()),
    ];
    return tags.isEmpty && widget.habit?.tags == null ? null : tags;
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

  /// Removes the task this routine was converted from, reminder included.
  /// A failed Supabase delete is only reported — the routine is already
  /// saved and the task is already gone from the cache by then.
  Future<void> _deleteConvertedTask(Task task) async {
    try {
      final notificationService = await ref.read(
        notificationServiceProvider.future,
      );
      await notificationService.forgetTaskReminder(task.id);
      final repository = await ref.read(taskRepositoryProvider.future);
      await repository.delete(task.id);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.taskSyncFailed(task.name, '$error')),
          ),
        );
      }
    } finally {
      ref.invalidate(taskTabControllerProvider);
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
    final convertingTask = widget.fromTask;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SheetHeader(
            title: switch ((isEditing, convertingTask)) {
              (true, _) => l10n.habitEditTitle,
              (false, Task()) => l10n.habitConvertTitle,
              (false, null) => l10n.habitBuildNewTitle,
            },
            onClose: () => Navigator.pop(context),
          ),
          if (convertingTask != null) ...[
            const SizedBox(height: Spacing.xs),
            Text(
              l10n.habitConvertHint(convertingTask.name),
              style: TextStyle(color: glass.textMuted, fontSize: 12),
            ),
          ],
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
          const SizedBox(height: 20),
          _SectionLabel(l10n.habitSectionTags),
          const SizedBox(height: Spacing.xs),
          Text(
            l10n.habitTagsHint,
            style: TextStyle(color: glass.textHint, fontSize: 12),
          ),
          const SizedBox(height: Spacing.sm),
          HabitTagsInlineEditor(
            tags: _tags,
            onChanged: (tags) => setState(() => _tags = tags),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: TintedPill(
              label: switch ((isEditing, convertingTask)) {
                (true, _) => l10n.habitSaveChanges,
                (false, Task()) => l10n.habitConvertSave,
                (false, null) => l10n.habitAddHabit,
              },
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
