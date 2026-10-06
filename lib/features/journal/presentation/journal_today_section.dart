import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../shared/widgets/glass_bottom_sheet.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/section_header.dart';
import '../data/journal_entries_controller.dart';
import '../domain/journal_entry.dart';
import 'add_journal_sheet.dart';
import 'journal_prompt_rows.dart';
import 'journal_tab_list.dart';

/// Today's entries, newest first, from an already-newest-first list.
List<JournalEntry> todaysJournalEntries(
  List<JournalEntry> entries,
  DateTime now,
) => [
  for (final entry in entries)
    if (DateUtils.isSameDay(entry.date, now)) entry,
]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

/// The Mindfulness tab's journal half: "Today's journal" + "view all"
/// (full by-date history), then today's entries as a horizontal strip
/// with a write card — or, with nothing written today, the same
/// plan / review prompts as home's Mindfulness card.
class JournalTodaySection extends ConsumerWidget {
  const JournalTodaySection({super.key});

  /// Height of the strip's cards.
  static const double _stripHeight = 132;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final entries = ref.watch(journalEntriesProvider).valueOrNull ?? const [];
    final today = todaysJournalEntries(entries, DateTime.now());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SectionHeader(
            title: l10n.journalTodaySection,
            titleColor: glass.journalAccent,
            actionLabel: l10n.commonViewAll,
            onAction: () => context.push('/journal/history'),
          ),
        ),
        if (today.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: GlassCard(
              padding: EdgeInsets.zero,
              child: JournalPromptRows(),
            ),
          )
        else
          SizedBox(
            height: _stripHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: today.length + 1,
              separatorBuilder: (_, _) => const SizedBox(width: Spacing.sm),
              itemBuilder: (context, index) => index < today.length
                  ? JournalTodayCard(entry: today[index])
                  : const _WriteCard(),
            ),
          ),
      ],
    );
  }
}

void _openAddJournalSheet(BuildContext context) => showGlassBottomSheet(
  context: context,
  builder: (_) => const AddJournalSheet(),
);

/// Trailing card in the strip for adding another entry today.
class _WriteCard extends StatelessWidget {
  const _WriteCard();

  static const double _width = 96;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return SizedBox(
      width: _width,
      child: Semantics(
        button: true,
        child: GestureDetector(
          onTap: () => _openAddJournalSheet(context),
          behavior: HitTestBehavior.opaque,
          child: GlassCard(
            borderRadius: 16,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: glass.journalAccent),
                const SizedBox(height: Spacing.xs),
                Text(
                  context.l10n.journalWrite,
                  style: TextStyle(color: glass.journalAccent),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
