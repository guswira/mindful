import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/glass_theme.dart';
import '../../../../shared/widgets/glass_bottom_sheet.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../ai/data/food_scan_repository.dart';
import '../../../exercise/presentation/breathing_picker_sheet.dart';
import '../../../exercise/presentation/exercise_providers.dart';
import '../../../habits/presentation/add_habit_sheet.dart';
import '../../../habits/presentation/habit_tab.dart';
import '../../../journal/data/journal_entries_controller.dart';
import '../../../journal/presentation/add_journal_sheet.dart';
import '../../../journal/presentation/journal_prompt_rows.dart';
import '../../../money/domain/entry_type.dart';
import '../../../money/presentation/add_money_sheet.dart';
import '../../../money/presentation/budget_settings_sheet.dart';
import '../../../money/presentation/money_providers.dart';
import '../../../tasks/presentation/add_task_sheet.dart';
import '../../../tasks/presentation/task_tab.dart';
import '../../domain/be_mindful_steps.dart';

/// Walks a new user through every feature, two at a time: each step stays
/// until it's been tried once, then the next one takes its place. Hidden
/// once every step is done. See SPEC.md Home Screen.
class BeMindfulSection extends ConsumerWidget {
  const BeMindfulSection({super.key});

  Map<BeMindfulStep, BeMindfulStepStatus> _statuses(WidgetRef ref) => {
    BeMindfulStep.routine: _statusOf(
      ref.watch(habitTabControllerProvider),
      (routines) => routines.isNotEmpty,
    ),
    BeMindfulStep.spending: _statusOf(
      ref.watch(moneyEntriesProvider(null)),
      (entries) => entries.any((entry) => entry.type == EntryType.spending),
    ),
    BeMindfulStep.task: _statusOf(
      ref.watch(taskTabControllerProvider),
      (tasks) => tasks.isNotEmpty,
    ),
    BeMindfulStep.foodScan: _statusOf(
      ref.watch(recentScansProvider),
      (scans) => scans.isNotEmpty,
    ),
    BeMindfulStep.breathing: _statusOf(
      ref.watch(breathingSessionsProvider),
      (sessions) => sessions.isNotEmpty,
    ),
    BeMindfulStep.journal: _statusOf(
      ref.watch(journalEntriesProvider),
      (entries) => entries.isNotEmpty,
    ),
    BeMindfulStep.budget: _budgetStatus(ref),
  };

  BeMindfulStepStatus _budgetStatus(WidgetRef ref) => _statusOf(
    ref.watch(activeBudgetsProvider),
    (budgets) => budgets.isNotEmpty,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = beMindfulProgress(_statuses(ref));
    if (progress.shown.isEmpty) {
      return const SizedBox.shrink();
    }
    return _BeMindfulContent(progress: progress);
  }
}

/// A reload keeps its previous value, so a step never flickers back to
/// loading while its data refreshes.
BeMindfulStepStatus _statusOf<T>(AsyncValue<T> value, bool Function(T) isDone) {
  if (value case AsyncValue(hasValue: true, :final T value)) {
    return isDone(value) ? BeMindfulStepStatus.done : BeMindfulStepStatus.todo;
  }
  return value.hasError
      ? BeMindfulStepStatus.unknown
      : BeMindfulStepStatus.loading;
}

class _BeMindfulContent extends StatelessWidget {
  const _BeMindfulContent({required this.progress});

  final BeMindfulProgress progress;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final l10n = context.l10n;
    final shown = progress.shown;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              l10n.homeBeMindfulIntro,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: glass.textSecondary,
              ),
            ),
          ),
          GlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (final (index, step) in shown.indexed) ...[
                  if (index > 0) const PromptRowDivider(),
                  _StepRow(step: step),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One [BeMindfulStep] as a [PromptRow] that opens the feature it shows.
class _StepRow extends StatelessWidget {
  const _StepRow({required this.step});

  final BeMindfulStep step;

  void _open(BuildContext context) => switch (step) {
    BeMindfulStep.routine => _sheet(context, const AddHabitSheet()),
    BeMindfulStep.spending => _sheet(context, const AddMoneySheet()),
    BeMindfulStep.task => _sheet(context, const AddTaskSheet()),
    BeMindfulStep.foodScan => context.go('/home/ai'),
    BeMindfulStep.breathing => pickBreathingExercise(context),
    BeMindfulStep.journal => _sheet(context, const AddJournalSheet()),
    BeMindfulStep.budget => _sheet(context, const BudgetSettingsSheet()),
  };

  void _sheet(BuildContext context, Widget sheet) =>
      showGlassBottomSheet(context: context, builder: (_) => sheet);

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final l10n = context.l10n;
    final (icon, color, title, subtitle, action) = switch (step) {
      BeMindfulStep.routine => (
        Icons.eco_outlined,
        glass.habitAccent,
        l10n.homeBuildFirstRoutine,
        l10n.homeBuildFirstRoutineSubtitle,
        l10n.homeBuildFirstRoutineAction,
      ),
      BeMindfulStep.spending => (
        Icons.account_balance_wallet_outlined,
        glass.moneyAccent,
        l10n.homeMindfulSpendingTitle,
        l10n.homeMindfulSpendingSubtitle,
        l10n.homeMindfulSpendingAction,
      ),
      BeMindfulStep.task => (
        Icons.checklist_rounded,
        glass.taskAccent,
        l10n.homeMindfulTaskTitle,
        l10n.homeMindfulTaskSubtitle,
        l10n.homeMindfulTaskAction,
      ),
      BeMindfulStep.foodScan => (
        Icons.restaurant_outlined,
        glass.aiAccent,
        l10n.homeMindfulFoodTitle,
        l10n.homeMindfulFoodSubtitle,
        l10n.homeMindfulFoodAction,
      ),
      BeMindfulStep.breathing => (
        Icons.air_rounded,
        glass.exerciseAccent,
        l10n.homeMindfulBreathingStepTitle,
        l10n.homeMindfulBreathingStepSubtitle,
        l10n.homeMindfulBreathingStepAction,
      ),
      BeMindfulStep.journal => (
        Icons.menu_book_outlined,
        glass.journalAccent,
        l10n.homeMindfulJournalTitle,
        l10n.homeMindfulJournalSubtitle,
        l10n.homeMindfulJournalAction,
      ),
      BeMindfulStep.budget => (
        Icons.track_changes_rounded,
        glass.moneyAccent,
        l10n.homeMindfulBudgetTitle,
        l10n.homeMindfulBudgetSubtitle,
        l10n.homeMindfulBudgetAction,
      ),
    };
    return PromptRow(
      icon: icon,
      iconColor: color,
      title: title,
      subtitle: subtitle,
      pillLabel: action,
      pillColor: color,
      onTap: () => _open(context),
    );
  }
}
