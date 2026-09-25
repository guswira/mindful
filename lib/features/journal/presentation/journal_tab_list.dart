import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../shared/widgets/glass_bottom_sheet.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/unsynced_badge.dart';
import '../domain/journal_entry.dart';
import 'journal_detail_sheet.dart';
import 'journal_tab.dart' show journalPhotoUrlProvider;

/// Glass search input for [JournalTab] — its border highlights in
/// journalAccent while focused. See SPEC.md Daily Journal Tab.
class JournalSearchField extends StatefulWidget {
  const JournalSearchField({
    required this.controller,
    required this.onChanged,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  State<JournalSearchField> createState() => _JournalSearchFieldState();
}

class _JournalSearchFieldState extends State<JournalSearchField> {
  final _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(
      () => setState(() => _focused = _focusNode.hasFocus),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _focused ? glass.journalAccent : glass.cardBorder,
          width: _focused ? 1 : 0.5,
        ),
      ),
      child: GlassCard(
        borderRadius: 14,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          onChanged: widget.onChanged,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: context.l10n.journalSearchHint,
            hintStyle: TextStyle(color: glass.textHint),
            prefixIcon: Icon(Icons.search, color: glass.textMuted, size: 20),
            border: InputBorder.none,
            isDense: true,
          ),
        ),
      ),
    );
  }
}

/// [items] (month-header strings interleaved with [JournalEntry]s) as
/// glass cards. See SPEC.md Daily Journal Tab.
class JournalGroupedList extends StatelessWidget {
  const JournalGroupedList({required this.items, super.key});

  final List<Object> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      final glass = Theme.of(context).extension<GlassTheme>()!;
      return Center(
        child: Text(
          context.l10n.journalEmpty,
          style: TextStyle(color: glass.textMuted),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 88),
      itemCount: items.length,
      itemBuilder: (context, index) => switch (items[index]) {
        final String month => _MonthHeader(month),
        final JournalEntry entry => _JournalEntryCard(entry: entry),
        _ => const SizedBox.shrink(),
      },
    );
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader(this.month);

  final String month;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
      child: Text(
        month,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: glass.journalAccent,
        ),
      ),
    );
  }
}

class _JournalEntryCard extends StatelessWidget {
  const _JournalEntryCard({required this.entry});

  final JournalEntry entry;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final firstLine = entry.body.split('\n').first;
    final dateLabel = DateFormat.yMMMd().format(entry.date);
    final mood = entry.mood;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => showGlassBottomSheet(
            context: context,
            builder: (_) => JournalDetailSheet(journalId: entry.id),
          ),
          child: GlassCard(
            borderRadius: 16,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (entry.photoUrls.isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: JournalPhotoThumbnail(path: entry.photoUrls.first),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                if (mood != null) ...[
                  _MoodBadge(mood: mood, color: glass.journalAccent),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            dateLabel,
                            style: TextStyle(
                              fontSize: 12,
                              color: glass.textMuted,
                            ),
                          ),
                          const Spacer(),
                          UnsyncedBadge(syncStatus: entry.syncStatus),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        firstLine,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
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

class _MoodBadge extends StatelessWidget {
  const _MoodBadge({required this.mood, required this.color});

  final Mood mood;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(mood.emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 2),
        Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
      ],
    );
  }
}

/// Thumbnail for a journal photo stored in Supabase Storage, fetched via a
/// short-lived signed URL since the `photos` bucket is private.
class JournalPhotoThumbnail extends ConsumerWidget {
  const JournalPhotoThumbnail({
    required this.path,
    this.fit = BoxFit.cover,
    super.key,
  });

  final String path;
  final BoxFit fit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final urlAsync = ref.watch(journalPhotoUrlProvider(path));
    return urlAsync.when(
      data: (url) => CachedNetworkImage(
        imageUrl: url,
        fit: fit,
        placeholder: (context, url) => const ColoredBox(color: Colors.black12),
        errorWidget: (context, url, error) =>
            const Icon(Icons.broken_image_outlined),
      ),
      loading: () => const ColoredBox(color: Colors.black12),
      error: (_, _) => const Icon(Icons.broken_image_outlined),
    );
  }
}
