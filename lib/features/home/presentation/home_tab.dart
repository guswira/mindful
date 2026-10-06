import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../shared/widgets/blob_background.dart';
import '../../../shared/widgets/section_header.dart';
import '../../money/presentation/widgets/remaining_budget_widget.dart';
import '../../recap/presentation/widgets/monthly_recap_banner.dart';
import 'widgets/be_mindful_section.dart';
import 'widgets/greeting_header.dart';
import 'widgets/mindfulness_section.dart';
import 'widgets/today_todo_card.dart';
import 'widgets/unsynced_banner.dart';

/// Unified daily overview: greeting, budget, getting-started prompts,
/// today's todo (tasks then routines) and mindfulness prompts. See SPEC.md Home Screen.
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
                      const MonthlyRecapHomeBanner(),
                      const RemainingBudgetWidget(),
                      const SizedBox(height: 24),
                      const BeMindfulSection(),
                      SectionHeader(
                        title: l10n.homeSectionTodayTasks,
                        actionLabel: l10n.commonViewAll,
                        onAction: () => context.go('/home/tasks'),
                      ),
                      const TodayTodoCard(),
                      const SizedBox(height: 24),
                      SectionHeader(
                        title: l10n.homeSectionMindfulness,
                        actionLabel: l10n.commonViewAll,
                        onAction: () => context.go('/home/journal'),
                      ),
                      const MindfulnessSection(),
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
