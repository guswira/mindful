import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../shared/widgets/blob_background.dart';
import '../../money/presentation/widgets/remaining_budget_widget.dart';
import 'widgets/greeting_header.dart';
import 'widgets/journal_section.dart';
import 'widgets/streak_row.dart';
import 'widgets/today_tasks_strip.dart';
import 'widgets/unsynced_banner.dart';
import 'widgets/upcoming_habits_strip.dart';

/// Unified daily overview: greeting, streaks, today's tasks, today's
/// habits and a journal prompt. See SPEC.md Home Screen.
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: glass.background,
      body: RepaintBoundary(
        child: BlobBackground(
          child: SafeArea(
            bottom: false,
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const GreetingHeader(),
                      const SizedBox(height: 16),
                      const UnsyncedBanner(),
                      const StreakRow(),
                      const SizedBox(height: 16),
                      const RemainingBudgetWidget(),
                      const SizedBox(height: 24),
                      _SectionHeader(
                        title: l10n.homeSectionTodayTasks,
                        viewAllPath: '/home/tasks',
                      ),
                      const TodayTasksStrip(),
                      const SizedBox(height: 24),
                      _SectionHeader(
                        title: l10n.homeSectionHabits,
                        viewAllPath: '/home/habits',
                      ),
                      const UpcomingHabitsStrip(),
                      const SizedBox(height: 24),
                      _SectionHeader(
                        title: l10n.homeSectionJournal,
                        viewAllPath: '/home/journal',
                      ),
                      const JournalSection(),
                      const SizedBox(height: 100),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.viewAllPath});

  final String title;
  final String viewAllPath;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          GestureDetector(
            onTap: () => context.go(viewAllPath),
            child: Text(
              context.l10n.commonViewAll,
              style: TextStyle(fontSize: 13, color: glass.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}
