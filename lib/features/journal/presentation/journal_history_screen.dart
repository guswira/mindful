import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/l10n/l10n.dart';
import '../../../shared/widgets/glass_page_scaffold.dart';
import '../data/journal_entries_controller.dart';
import '../domain/journal_entry.dart';
import '../domain/journal_grouping.dart';
import 'journal_calendar_card.dart';
import 'journal_tab_list.dart';

/// Full-page journal history (`/journal/history`): search, a month
/// calendar, and the entries grouped by day. Tapping a day narrows the
/// list to it; a search query looks across every month instead. See
/// SPEC.md Mindfulness Tab.
class JournalHistoryScreen extends ConsumerStatefulWidget {
  const JournalHistoryScreen({this.now, super.key});

  /// Overrides the current time (tests).
  final DateTime? now;

  @override
  ConsumerState<JournalHistoryScreen> createState() =>
      _JournalHistoryScreenState();
}

class _JournalHistoryScreenState extends ConsumerState<JournalHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  late final DateTime _today = DateUtils.dateOnly(widget.now ?? DateTime.now());
  late DateTime _month = DateTime(_today.year, _today.month);
  DateTime? _selected;
  String _query = '';

  bool get _searching => _query.trim().isNotEmpty;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _changeMonth(int delta) => setState(() {
    _month = DateTime(_month.year, _month.month + delta);
    _selected = null;
  });

  void _toggleDay(DateTime day) =>
      setState(() => _selected = day == _selected ? null : day);

  List<JournalEntry> _visible(List<JournalEntry> entries) {
    final selected = _selected;
    if (_searching) {
      return searchJournalEntries(entries, _query);
    }
    if (selected != null) {
      return journalEntriesOnDay(entries, selected);
    }
    return journalEntriesInMonth(entries, _month);
  }

  String _emptyLabel(AppLocalizations l10n) {
    final selected = _selected;
    if (_searching) {
      return l10n.journalEmpty;
    }
    if (selected != null) {
      return l10n.journalHistoryDayEmpty(DateFormat.MMMd().format(selected));
    }
    return l10n.journalHistoryMonthEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final entries = ref.watch(journalEntriesProvider).valueOrNull ?? const [];
    return GlassPageScaffold(
      title: Text(l10n.journalHistoryTitle),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, Spacing.sm, 20, 0),
            sliver: SliverToBoxAdapter(
              child: JournalSearchField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
          ),
          if (!_searching)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, Spacing.sm, 20, 0),
              sliver: SliverToBoxAdapter(
                child: JournalCalendarCard(
                  month: _month,
                  today: _today,
                  countsByDay: journalEntryCountsByDay(entries),
                  selected: _selected,
                  onMonthChanged: _changeMonth,
                  onDayTap: _toggleDay,
                ),
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
            sliver: JournalGroupedSliverList(
              items: groupJournalEntriesByDay(
                _visible(entries),
                // Search spans years; a month's days don't need one.
                (_searching ? DateFormat.yMMMEd() : DateFormat.MMMEd()).format,
              ),
              emptyLabel: _emptyLabel(l10n),
            ),
          ),
        ],
      ),
    );
  }
}
