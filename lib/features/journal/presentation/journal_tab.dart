import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../shared/widgets/blob_background.dart';
import '../data/journal_entries_controller.dart';
import '../data/journal_repository.dart';
import '../domain/journal_entry.dart';
import 'journal_tab_list.dart';

part 'journal_tab.g.dart';

/// A signed URL for the private Supabase Storage photo at [path], valid for
/// an hour — cheap enough to re-fetch per widget build via [ref.watch].
@riverpod
Future<String> journalPhotoUrl(Ref ref, String path) async {
  final repository = await ref.watch(journalRepositoryProvider.future);
  return repository.signedPhotoUrl(path);
}

/// List of past entries, newest first, grouped by month, with search. See
/// SPEC.md Daily Journal Tab.
class JournalTab extends ConsumerStatefulWidget {
  const JournalTab({super.key});

  @override
  ConsumerState<JournalTab> createState() => _JournalTabState();
}

class _JournalTabState extends ConsumerState<JournalTab> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final entriesAsync = ref.watch(journalEntriesProvider);

    return Scaffold(
      body: RepaintBoundary(
        child: BlobBackground(
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.l10n.journalTabTitle,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: JournalSearchField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _query = value),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: entriesAsync.when(
                    data: (entries) =>
                        JournalGroupedList(items: _filterAndGroup(entries)),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, _) => Center(
                      child: Text(
                        context.l10n.journalLoadFailed('$error'),
                        style: TextStyle(color: glass.textSecondary),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Filters by [_query] then flattens into a list of month-header strings
  /// and [JournalEntry]s, assuming [entries] already arrive newest first.
  List<Object> _filterAndGroup(List<JournalEntry> entries) {
    final lower = _query.trim().toLowerCase();
    final filtered = lower.isEmpty
        ? entries
        : entries
              .where(
                (e) =>
                    e.body.toLowerCase().contains(lower) ||
                    (e.title?.toLowerCase().contains(lower) ?? false),
              )
              .toList();

    final items = <Object>[];
    String? currentMonth;
    for (final entry in filtered) {
      final month = DateFormat.yMMMM().format(entry.date);
      if (month != currentMonth) {
        items.add(month);
        currentMonth = month;
      }
      items.add(entry);
    }
    return items;
  }
}
