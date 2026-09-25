import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../shared/services/widget_service.dart';
import '../../../shared/widgets/glass_bottom_sheet.dart';
import '../data/money_repository.dart';
import '../domain/entry_type.dart';
import '../domain/money_entry.dart';
import 'add_money_sheet.dart';
import 'money_labels.dart';
import 'money_providers.dart';

enum _MoreAction { edit, delete }

/// Read-only bottom sheet showing a money entry's type, amount, category,
/// note and date, with edit/delete via the overflow menu. See SPEC.md
/// Money Flow Feature Money Entry Detail Sheet and the bottom-sheet
/// design rules.
class MoneyDetailSheet extends ConsumerWidget {
  const MoneyDetailSheet({required this.entry, super.key});

  final MoneyEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final isSpending = entry.type == EntryType.spending;
    final color = isSpending ? glass.moneySpending : glass.moneyAccent;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _TypeBadge(isSpending: isSpending, color: color),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showMoreActions(context),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            '${isSpending ? '-' : '+'}${NumberFormat('#,##0.00').format(entry.amount)}',
            style: TextStyle(
              color: color,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: Spacing.xs),
          Row(
            children: [
              Text(
                categoryEmoji[entry.category] ?? '',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: Spacing.xs),
              Text(
                categoryLabel(context.l10n, entry.category),
                style: TextStyle(color: glass.textSecondary, fontSize: 16),
              ),
            ],
          ),
          if (entry.note case final note? when note.isNotEmpty) ...[
            const SizedBox(height: Spacing.sm),
            Text(
              note,
              style: TextStyle(
                color: glass.textSecondary,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: Spacing.sm),
          Text(
            DateFormat.yMMMd().format(entry.date),
            style: TextStyle(color: glass.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Future<void> _showMoreActions(BuildContext context) async {
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
        Navigator.pop(context);
        showGlassBottomSheet(
          context: context,
          builder: (_) => AddMoneySheet(entry: entry),
        );
      case _MoreAction.delete:
        await _confirmDelete(context);
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.moneyDeleteEntryTitle),
        content: Text(
          context.l10n.moneyDeleteEntryBody(
            categoryLabel(context.l10n, entry.category),
          ),
        ),
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

    final container = ProviderScope.containerOf(context);
    final repository = await container.read(moneyRepositoryProvider.future);
    await repository.deleteEntry(entry.id);
    await refreshWidgetsBestEffort(
      () => container.read(widgetServiceProvider.future),
    );
    container.invalidate(moneyEntriesProvider);
    container.invalidate(remainingBudgetProvider);
    if (context.mounted) {
      Navigator.pop(context);
    }
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.isSpending, required this.color});

  final bool isSpending;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 0.5),
      ),
      child: Text(
        entryTypeLabel(
          context.l10n,
          isSpending ? EntryType.spending : EntryType.income,
        ),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
