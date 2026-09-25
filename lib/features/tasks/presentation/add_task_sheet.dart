import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../shared/services/notification_service.dart';
import '../../../shared/services/widget_service.dart';
import '../../../shared/widgets/shake_widget.dart';
import '../../../shared/widgets/sheet_header.dart';
import '../../../shared/widgets/tinted_pill.dart';
import '../../auth/domain/auth_state.dart';
import '../data/task_repository.dart';
import '../domain/task.dart';
import '../domain/task_checkbox.dart';
import 'add_task_sheet_rows.dart';
import 'add_task_sheet_subtasks.dart';
import 'task_providers.dart';
import 'task_tab.dart';

/// Bottom sheet to create or edit a task: name, optional subtasks, due
/// date and reminder. See SPEC.md Task Manager and the bottom-sheet
/// design rules.
///
/// Passing [task] pre-fills the form and switches saving to an update —
/// used by [TaskDetailSheet]'s edit action and by the task row's long-press
/// edit action.
class AddTaskSheet extends ConsumerStatefulWidget {
  const AddTaskSheet({this.task, super.key});

  final Task? task;

  @override
  ConsumerState<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends ConsumerState<AddTaskSheet> {
  static const _defaultReminderTime = TimeOfDay(hour: 9, minute: 0);

  final _nameController = TextEditingController();
  final _nameShake = GlobalKey<ShakeWidgetState>();
  List<TaskCheckbox> _checkboxes = const [];
  DateTime? _dueDate;
  TimeOfDay? _reminderTime;
  bool _showSubtasks = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    if (task != null) {
      _nameController.text = task.name;
      _checkboxes = task.checkboxes;
      _dueDate = task.dueDate;
      _reminderTime = task.reminderAt == null
          ? null
          : TimeOfDay.fromDateTime(task.reminderAt!);
      _showSubtasks = task.checkboxes.isNotEmpty;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      // Setting a due date defaults the reminder to 9am on that date, per
      // SPEC.md — the user can still adjust or clear it from its own row.
      setState(() {
        _dueDate = picked;
        _reminderTime = _defaultReminderTime;
      });
    }
  }

  void _clearDueDate() {
    setState(() {
      _dueDate = null;
      _reminderTime = null;
    });
  }

  Future<void> _pickReminderTime() async {
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
    final now = DateTime.now();
    final dueDate = _dueDate;
    final reminderTime = _reminderTime;
    final reminderAt = (dueDate != null && reminderTime != null)
        ? DateTime(
            dueDate.year,
            dueDate.month,
            dueDate.day,
            reminderTime.hour,
            reminderTime.minute,
          )
        : null;

    final existing = widget.task;
    final task = existing == null
        ? Task(
            id: const Uuid().v4(),
            userId: ref.read(currentUserIdProvider),
            name: name,
            createdAt: now,
            updatedAt: now,
            dueDate: dueDate,
            reminderAt: reminderAt,
            checkboxes: _checkboxes,
          )
        : existing.copyWith(
            name: name,
            updatedAt: now,
            dueDate: dueDate,
            reminderAt: reminderAt,
            checkboxes: _checkboxes,
          );

    final repository = await ref.read(taskRepositoryProvider.future);
    await (existing == null
        ? repository.create(task)
        : repository.update(task));
    await _scheduleReminder(task);
    await refreshWidgetsBestEffort(
      () => ref.read(widgetServiceProvider.future),
    );

    if (!mounted) {
      return;
    }
    if (existing == null) {
      final taskTab = ref.read(taskTabControllerProvider.notifier);
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(
        SnackBar(
          content: Text(context.l10n.taskAdded),
          action: SnackBarAction(
            label: context.l10n.taskUndo,
            onPressed: () => taskTab.delete(task.id),
          ),
        ),
      );
    } else {
      ref.invalidate(taskByIdProvider(task.id));
      Navigator.pop(context);
    }
  }

  /// Best-effort: a scheduling failure (e.g. a platform-channel hiccup)
  /// shouldn't leave this sheet stuck open with the task already saved.
  Future<void> _scheduleReminder(Task task) async {
    try {
      final notificationService = await ref.read(
        notificationServiceProvider.future,
      );
      await notificationService.scheduleTaskReminder(task);
    } catch (error) {
      // Best-effort — see doc comment — but still worth knowing about.
      debugPrint('Failed to schedule task reminder: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final l10n = context.l10n;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SheetHeader(
            title: l10n.taskSheetTitle,
            onClose: () => Navigator.pop(context),
          ),
          const SizedBox(height: Spacing.md),
          TaskNameField(shakeKey: _nameShake, controller: _nameController),
          const SizedBox(height: Spacing.sm),
          SheetOptionRow(
            icon: Icons.calendar_today_outlined,
            label: l10n.taskAddDueDate,
            value: _dueDate == null
                ? null
                : DateFormat.yMMMd().format(_dueDate!),
            onTap: _pickDueDate,
            onClear: _clearDueDate,
          ),
          const Divider(color: Colors.white10, height: 1),
          SheetOptionRow(
            icon: Icons.notifications_none,
            label: l10n.taskAddReminder,
            value: _reminderTime?.format(context),
            enabled: _dueDate != null,
            onTap: _pickReminderTime,
            onClear: () => setState(() => _reminderTime = null),
          ),
          const Divider(color: Colors.white10, height: 1),
          SubtasksToggleRow(
            value: _showSubtasks,
            onChanged: (value) => setState(() => _showSubtasks = value),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            child: _showSubtasks
                ? SubtasksEditor(
                    checkboxes: _checkboxes,
                    onChanged: (checkboxes) =>
                        setState(() => _checkboxes = checkboxes),
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: Spacing.lg),
          SizedBox(
            width: double.infinity,
            child: TintedPill(
              label: widget.task == null
                  ? l10n.taskAddTask
                  : l10n.taskSaveChanges,
              color: glass.taskAccent,
              onTap: _saving ? null : _save,
            ),
          ),
        ],
      ),
    );
  }
}
