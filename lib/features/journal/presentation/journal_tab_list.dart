import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../shared/widgets/glass_bottom_sheet.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/unsynced_badge.dart';
import '../domain/journal_entry.dart';
import 'journal_detail_sheet.dart';
import 'journal_labels.dart';
import 'journal_tab.dart' show journalPhotoUrlProvider;

/// Glass search input for the journal history screen — its border highlights in
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

/// [items] (group-header strings interleaved with [JournalEntry]s) as
/// glass cards, for a [CustomScrollView]. Shows [emptyLabel] when there's
/// nothing to list.
class JournalGroupedSliverList extends StatelessWidget {
  const JournalGroupedSliverList({
    required this.items,
    required this.emptyLabel,
    super.key,
  });

  final List<Object> items;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      final glass = Theme.of(context).extension<GlassTheme>()!;
      return SliverPadding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        sliver: SliverToBoxAdapter(
          child: Center(
            child: Text(emptyLabel, style: TextStyle(color: glass.textMuted)),
          ),
        ),
      );
    }
    return SliverList.builder(
      itemCount: items.length,
      itemBuilder: (context, index) => switch (items[index]) {
        final String header => _GroupHeader(header),
        final JournalEntry entry => _JournalEntryCard(entry: entry),
        _ => const SizedBox.shrink(),
      },
    );
  }
}

/// Opens [entry] in [JournalDetailSheet].
void showJournalDetail(BuildContext context, JournalEntry entry) =>
    showGlassBottomSheet(
      context: context,
      builder: (_) => JournalDetailSheet(journalId: entry.id),
    );

class _GroupHeader extends StatelessWidget {
  const _GroupHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: glass.journalAccent,
        ),
      ),
    );
  }
}

/// The entry's [JournalType] as a small journalAccent label.
class JournalTypeBadge extends StatelessWidget {
  const JournalTypeBadge({required this.type, super.key});

  final JournalType type;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return Row(
      children: [
        Icon(journalTypeIcon(type), size: 13, color: glass.journalAccent),
        const SizedBox(width: Spacing.xs),
        Flexible(
          child: Text(
            context.l10n.journalTypeName(type),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: glass.journalAccent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

/// A fixed-width card for the Mindfulness tab's horizontal "today"
/// strip: type, mood, the start of the body and the time it was written.
class JournalTodayCard extends StatelessWidget {
  const JournalTodayCard({required this.entry, super.key});

  /// Card width — the strip's height is sized around it.
  static const double width = 200;

  final JournalEntry entry;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final textTheme = Theme.of(context).textTheme;
    final mood = entry.mood;
    return SizedBox(
      width: width,
      child: GestureDetector(
        onTap: () => showJournalDetail(context, entry),
        behavior: HitTestBehavior.opaque,
        child: GlassCard(
          borderRadius: 16,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: JournalTypeBadge(type: entry.type)),
                  if (mood != null)
                    Icon(
                      moodIcon(mood),
                      size: 16,
                      color: glass.textSecondary,
                      semanticLabel: context.l10n.moodName(mood),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Expanded(
                child: Text(
                  entry.body,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(color: Colors.white),
                ),
              ),
              Row(
                children: [
                  Text(
                    DateFormat.jm().format(entry.createdAt.toLocal()),
                    style: textTheme.labelSmall?.copyWith(
                      color: glass.textMuted,
                    ),
                  ),
                  const Spacer(),
                  UnsyncedBadge(syncStatus: entry.syncStatus),
                ],
              ),
            ],
          ),
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
          onTap: () => showJournalDetail(context, entry),
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
                          Flexible(child: JournalTypeBadge(type: entry.type)),
                          const SizedBox(width: Spacing.sm),
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
        Icon(
          moodIcon(mood),
          size: 20,
          color: Colors.white.withValues(alpha: 0.7),
          semanticLabel: context.l10n.moodName(mood),
        ),
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
