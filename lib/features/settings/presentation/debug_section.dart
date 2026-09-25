import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/l10n/l10n.dart';
import '../../../shared/services/notification_service.dart';

/// Debug-only tools, hidden outside [kDebugMode] — currently just a way to
/// fire a real scheduled notification a few minutes out, to tell apart an
/// app bug from an OS/device-level restriction (notification permission,
/// a muted channel, OEM battery/autostart limits, ...) when a real task or
/// habit reminder doesn't show: if this one doesn't show either, the
/// cause is outside this app's control. See
/// [NotificationService.scheduleTestNotification].
class DebugSection extends ConsumerStatefulWidget {
  const DebugSection({super.key});

  @override
  ConsumerState<DebugSection> createState() => _DebugSectionState();
}

class _DebugSectionState extends ConsumerState<DebugSection> {
  bool _scheduling = false;

  Future<void> _scheduleTestNotification() async {
    setState(() => _scheduling = true);
    try {
      final service = await ref.read(notificationServiceProvider.future);
      final scheduledFor = await service.scheduleTestNotification();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.settingsDebugTestScheduled(
              DateFormat.jm().format(scheduledFor),
            ),
          ),
          duration: const Duration(seconds: 6),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.settingsDebugTestError('$error')),
        ),
      );
    } finally {
      if (mounted) setState(() => _scheduling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.settingsDebugTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: Spacing.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton(
              onPressed: _scheduling ? null : _scheduleTestNotification,
              child: Text(
                _scheduling
                    ? context.l10n.settingsDebugScheduling
                    : context.l10n.settingsDebugScheduleTest,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
