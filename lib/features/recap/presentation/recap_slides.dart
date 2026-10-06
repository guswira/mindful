import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/glass_theme.dart';
import '../../money/presentation/money_labels.dart';
import '../domain/monthly_recap.dart';
import 'recap_slide_data.dart';

/// The slideshow for [recap]: intro, routines, tasks, cashflow, AI, outro.
List<RecapSlideData> buildRecapSlides(
  MonthlyRecap recap,
  AppLocalizations l10n,
  GlassTheme glass,
) {
  final monthName = DateFormat.MMMM().format(recap.month);
  final nextMonthName = DateFormat.MMMM().format(
    DateTime(recap.month.year, recap.month.month + 1),
  );
  return [
    RecapSlideData(
      accent: glass.writeAccent,
      icon: Icons.nightlight_outlined,
      title: l10n.recapIntroLabel,
      heroText: recap.isComplete
          ? l10n.recapIntroTitle(monthName)
          : l10n.recapIntroSoFarTitle(monthName),
      heroLabel: DateFormat.y().format(recap.month),
      motivation: l10n.recapIntroMotivation,
    ),
    _routines(recap.routines, l10n, glass),
    _tasks(recap.tasks, l10n, glass),
    _cashflow(recap.cashflow, l10n, glass),
    _ai(recap.ai, l10n, glass),
    RecapSlideData(
      accent: glass.writeAccent,
      icon: Icons.rocket_launch_outlined,
      title: l10n.recapOutroLabel,
      heroText: l10n.recapOutroTitle,
      heroLabel: '',
      motivation: recap.isComplete
          ? l10n.recapOutroBody(nextMonthName)
          : l10n.recapOutroSoFarBody,
      isLast: true,
    ),
  ];
}

String _toneLine(
  RecapTone tone, {
  required String great,
  required String good,
  required String starting,
  required String empty,
}) => switch (tone) {
  RecapTone.great => great,
  RecapTone.good => good,
  RecapTone.starting => starting,
  RecapTone.empty => empty,
};

String _count(double value) => NumberFormat.decimalPattern().format(value);

int _percent(double ratio) => (ratio * 100).round();

RecapSlideData _routines(
  RoutineRecap r,
  AppLocalizations l10n,
  GlassTheme glass,
) => RecapSlideData(
  accent: glass.habitAccent,
  icon: Icons.self_improvement_rounded,
  title: l10n.recapRoutinesTitle,
  heroValue: r.checkIns.toDouble(),
  formatHero: _count,
  heroLabel: l10n.recapRoutinesHeroLabel,
  stats: [
    (
      value: l10n.recapPercent(_percent(r.completionRate)),
      label: l10n.recapStatCompletion,
    ),
    (value: l10n.recapDays(r.perfectDays), label: l10n.recapStatPerfectDays),
    (
      value: l10n.recapDays(r.longestStreak),
      label: l10n.recapStatLongestStreak,
    ),
    if (r.bestHabitName case final name?)
      (value: name, label: l10n.recapStatTopRoutine),
  ],
  motivation: _toneLine(
    r.tone,
    great: l10n.recapRoutinesGreat,
    good: l10n.recapRoutinesGood,
    starting: l10n.recapRoutinesStarting,
    empty: l10n.recapRoutinesEmpty,
  ),
);

RecapSlideData _tasks(TaskRecap t, AppLocalizations l10n, GlassTheme glass) =>
    RecapSlideData(
      accent: glass.taskAccent,
      icon: Icons.checklist_rounded,
      title: l10n.recapTasksTitle,
      heroValue: t.completed.toDouble(),
      formatHero: _count,
      heroLabel: l10n.recapTasksHeroLabel,
      stats: [
        (value: _count(t.added.toDouble()), label: l10n.recapStatAdded),
        (value: _count(t.stillOpen.toDouble()), label: l10n.recapStatStillOpen),
        (
          value: l10n.recapPercent(_percent(t.completionRate)),
          label: l10n.recapStatCompletion,
        ),
      ],
      motivation: _toneLine(
        t.tone,
        great: l10n.recapTasksGreat,
        good: l10n.recapTasksGood,
        starting: l10n.recapTasksStarting,
        empty: l10n.recapTasksEmpty,
      ),
    );

RecapSlideData _cashflow(
  CashflowRecap c,
  AppLocalizations l10n,
  GlassTheme glass,
) {
  String money(double value) =>
      '${c.currency} ${NumberFormat('#,##0').format(value)}';
  final netSign = c.net > 0 ? '+' : (c.net < 0 ? '-' : '');
  return RecapSlideData(
    accent: glass.moneyAccent,
    icon: Icons.account_balance_wallet_outlined,
    title: l10n.recapMoneyTitle,
    heroValue: c.spending,
    formatHero: money,
    heroLabel: l10n.recapMoneyHeroLabel,
    stats: [
      (value: money(c.income), label: l10n.recapStatIncome),
      (value: '$netSign${money(c.net.abs())}', label: l10n.recapStatNet),
      if (c.budget case final budget?)
        (
          value: l10n.recapPercent(_percent(c.spending / budget)),
          label: l10n.recapStatBudgetUsed,
        ),
      (value: l10n.recapDays(c.noSpendDays), label: l10n.recapStatNoSpendDays),
      if (c.topCategory case final category?)
        (
          value: categoryLabel(l10n, category),
          label: l10n.recapStatTopCategory,
        ),
    ],
    motivation: _toneLine(
      c.tone,
      great: l10n.recapMoneyGreat,
      good: l10n.recapMoneyGood,
      starting: l10n.recapMoneyStarting,
      empty: l10n.recapMoneyEmpty,
    ),
  );
}

RecapSlideData _ai(AiRecap? a, AppLocalizations l10n, GlassTheme glass) =>
    RecapSlideData(
      accent: glass.aiAccent,
      icon: Icons.auto_awesome_outlined,
      title: l10n.recapAiTitle,
      heroValue: (a?.scans ?? 0).toDouble(),
      formatHero: _count,
      heroLabel: l10n.recapAiHeroLabel,
      stats: [
        if (a != null && a.scans > 0) ...[
          (
            value: l10n.recapKcal(a.averageCalories),
            label: l10n.recapStatAvgCalories,
          ),
          (
            value: l10n.recapKcal(a.totalCalories),
            label: l10n.recapStatTotalCalories,
          ),
          if (a.topFood case final food?)
            (value: food, label: l10n.recapStatTopFood),
        ],
      ],
      motivation: a == null
          ? l10n.recapAiUnavailable
          : _toneLine(
              a.tone,
              great: l10n.recapAiGreat,
              good: l10n.recapAiGood,
              starting: l10n.recapAiStarting,
              empty: l10n.recapAiEmpty,
            ),
    );
