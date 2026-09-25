import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/spacing.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../shared/models/sync_status.dart';
import '../../../habits/data/habit_repository.dart';
import '../../../journal/data/journal_repository.dart';
import '../../../tasks/data/task_repository.dart';

part 'unsynced_banner.g.dart';

/// Whether any pending write (journal entry, habit log or task) is older
/// than 24 hours — SPEC.md's threshold for showing [UnsyncedBanner].
///
/// Habit logs have no write timestamp of their own (only a completion
/// [HabitLog.date]), so their log date is used as an approximation of when
/// the write happened.
@riverpod
Future<bool> hasStalePendingWrites(Ref ref) async {
  final now = DateTime.now();
  const staleAfter = Duration(hours: 24);

  final journalRepository = await ref.watch(journalRepositoryProvider.future);
  final habitRepository = await ref.watch(habitRepositoryProvider.future);
  final taskRepository = await ref.watch(taskRepositoryProvider.future);

  final journalStale = journalRepository.getAll().any(
    (entry) =>
        entry.syncStatus == SyncStatus.pending &&
        now.difference(entry.updatedAt) > staleAfter,
  );
  final habitLogStale = habitRepository.getAllLogs().any(
    (log) =>
        log.syncStatus == SyncStatus.pending &&
        now.difference(log.date) > staleAfter,
  );
  final taskStale = taskRepository.getAll().any(
    (task) =>
        task.syncStatus == SyncStatus.pending &&
        now.difference(task.updatedAt) > staleAfter,
  );

  return journalStale || habitLogStale || taskStale;
}

/// Subtle banner shown on the home tab when [hasStalePendingWritesProvider]
/// is true. Renders nothing otherwise (including while loading or on
/// error — this is an advisory, not a critical state).
class UnsyncedBanner extends ConsumerWidget {
  const UnsyncedBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isStale =
        ref.watch(hasStalePendingWritesProvider).valueOrNull ?? false;
    if (!isStale) {
      return const SizedBox.shrink();
    }

    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.cloud_off_outlined,
            size: 16,
            color: colors.onSurfaceVariant,
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Text(
              context.l10n.homeUnsyncedBanner,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
