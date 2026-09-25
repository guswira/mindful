import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/l10n/l10n.dart';
import '../data/journal_entries_controller.dart';
import '../domain/journal_entry.dart';
import 'journal_photo_viewer.dart';
import 'journal_tab_list.dart' show JournalPhotoThumbnail;

enum _MoreAction { edit, delete }

/// Bottom sheet showing a journal entry's full text and photos, with
/// edit/delete via the overflow menu. See SPEC.md Journal Editor Screen
/// and the bottom-sheet design rules.
class JournalDetailSheet extends ConsumerWidget {
  const JournalDetailSheet({required this.journalId, super.key});

  final String journalId;

  Future<void> _showMoreActions(
    BuildContext context,
    WidgetRef ref,
    JournalEntry entry,
  ) async {
    final action = await showModalBottomSheet<_MoreAction>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(context.l10n.commonEdit),
              onTap: () => Navigator.pop(context, _MoreAction.edit),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: Text(
                context.l10n.commonDelete,
                style: const TextStyle(color: Colors.red),
              ),
              onTap: () => Navigator.pop(context, _MoreAction.delete),
            ),
          ],
        ),
      ),
    );
    if (!context.mounted || action == null) {
      return;
    }
    switch (action) {
      case _MoreAction.edit:
        // Only the nested actions sheet closes here — the detail sheet
        // stays underneath the full-page editor it pushes, so popping the
        // editor returns the user to it.
        Navigator.pop(context);
        context.push('/journal/${entry.id}/edit');
      case _MoreAction.delete:
        await _confirmDelete(context, ref, entry);
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    JournalEntry entry,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.journalDeleteConfirmTitle),
        content: Text(context.l10n.journalDeleteConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.commonDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) {
      return;
    }

    await ref.read(journalEntriesProvider.notifier).deleteEntry(entry);
    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entry = ref.watch(journalEntryProvider(journalId));
    if (entry == null) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                DateFormat('MMMM d, yyyy').format(entry.date),
                style: const TextStyle(color: Colors.white60, fontSize: 14),
              ),
              const Spacer(),
              if (entry.mood != null) ...[
                Text(entry.mood!.emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: Spacing.sm),
              ],
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showMoreActions(context, ref, entry),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          if (entry.title case final title? when title.isNotEmpty) ...[
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: Spacing.sm),
          ],
          Text(
            entry.body,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 15,
              height: 1.6,
            ),
          ),
          if (entry.photoUrls.isNotEmpty) ...[
            const SizedBox(height: Spacing.md),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: entry.photoUrls.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(width: Spacing.sm),
                itemBuilder: (context, index) {
                  final path = entry.photoUrls[index];
                  return GestureDetector(
                    onTap: () => showJournalPhotoViewer(context, path),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 100,
                        height: 100,
                        child: JournalPhotoThumbnail(path: path),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
