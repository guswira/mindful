import 'package:flutter/material.dart';

import '../../core/constants/spacing.dart';
import '../../core/l10n/l10n.dart';
import '../models/sync_status.dart';

/// A small subtle dot shown on a record's card or row when it hasn't
/// synced to Supabase yet. Renders nothing once [syncStatus] is synced.
class UnsyncedBadge extends StatelessWidget {
  const UnsyncedBadge({required this.syncStatus, super.key});

  final SyncStatus syncStatus;

  @override
  Widget build(BuildContext context) {
    if (syncStatus == SyncStatus.synced) {
      return const SizedBox.shrink();
    }
    return Semantics(
      label: context.l10n.sharedUnsyncedLabel,
      child: Container(
        width: Spacing.xs,
        height: Spacing.xs,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.outline,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
