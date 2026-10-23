import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../shared/services/ai_activity.dart';
import '../../../shared/services/gemini_service.dart';
import '../../../shared/services/notification_service.dart';
import '../../../shared/widgets/glass_bottom_sheet.dart';
import '../../ai/domain/food_scan_exception.dart';
import '../../ai/presentation/food_scan_retry.dart';
import '../data/money_repository.dart';
import '../domain/money_advice.dart';
import 'money_advice_sheet.dart';
import 'money_advice_summary.dart';
import 'money_period.dart';

/// Whether a [requestMoneyAdvice] run is still going — possibly minutes
/// into its retries. A second run would fight the first over the same
/// notification id.
bool _inFlight = false;

/// Sends the money entries of the Money tab's selected period
/// ([moneyPeriodProvider] — e.g. This Month → just this month's) to Gemini
/// and offers the advice — the same
/// non-blocking flow as the food scan's: the AI activity pill at the top of the
/// screen shows it's running (and any retry), then "ready — tap to view";
/// a progress notification (id 4003) tracks it in the background, and a
/// final failure after a retry also leaves a failure notification with a
/// "Retry" action. A busy or slow Gemini is retried per [runWithRetry].
/// See SPEC.md Money Flow Feature AI Advice.
///
/// Holds on to the root [NavigatorState], [ScaffoldMessengerState] and
/// [ProviderContainer] rather than [context] itself, since the retries
/// can outlive the widget that started them (e.g. the user switches tab).
Future<void> requestMoneyAdvice(BuildContext context) async {
  final messenger = ScaffoldMessenger.of(context);
  if (_inFlight) {
    messenger.showSnackBar(
      SnackBar(content: Text(context.l10n.moneyAdviceInProgress)),
    );
    return;
  }
  _inFlight = true;
  try {
    await _run(
      container: ProviderScope.containerOf(context),
      navigator: Navigator.of(context, rootNavigator: true),
      messenger: messenger,
    );
  } finally {
    _inFlight = false;
  }
}

Future<void> _run({
  required ProviderContainer container,
  required NavigatorState navigator,
  required ScaffoldMessengerState messenger,
}) async {
  final repository = await container.read(moneyRepositoryProvider.future);
  final range = container
      .read(moneyPeriodProvider)
      .rangeEndingAt(DateTime.now());
  final entries = repository.getEntries(range: range);
  if (entries.isEmpty) {
    messenger.showSnackBar(
      SnackBar(content: Text(currentL10n.moneyAdviceNoEntries)),
    );
    return;
  }
  final summary = buildMoneyAdviceSummary(
    entries,
    await repository.getCurrency(),
    range: range,
  );
  if (!navigator.mounted) {
    return;
  }

  final activity = container.read(aiActivityProvider.notifier);
  final id = activity.start(AiActivityKind.moneyAdvice);
  final notifications = await container.read(
    notificationServiceProvider.future,
  );
  await notifications.showMoneyAdviceProgress(currentL10n.moneyAdviceLoading);

  var retried = false;
  try {
    final advice = await runWithRetry(
      attempt: () =>
          container.read(geminiServiceProvider).adviseOnMoney(summary),
      onRetry: (attemptNumber) async {
        retried = true;
        activity.retrying(id, attemptNumber, FoodScanRetryPolicy.maxAttempts);
        await notifications.showMoneyAdviceProgress(
          currentL10n.aiNotifRetryingBody(
            attemptNumber,
            FoodScanRetryPolicy.maxAttempts,
          ),
        );
      },
    );
    await notifications.cancelMoneyAdviceNotification();
    activity.ready(id, () => _showAdvice(navigator, advice));
  } on FoodScanException catch (error) {
    final message = foodScanMessage(error);
    activity.finish(id);
    await notifications.cancelMoneyAdviceNotification();
    // After a retry the user has likely moved on (or left the app) —
    // leave a notification they can act on too.
    if (retried) {
      await notifications.showMoneyAdviceFailed(message);
    }
    _showError(messenger, navigator, message);
  }
}

void _showAdvice(NavigatorState navigator, MoneyAdvice advice) {
  if (!navigator.mounted) {
    return;
  }
  unawaited(
    showGlassBottomSheet<void>(
      context: navigator.context,
      builder: (_) => MoneyAdviceSheet(advice: advice),
    ),
  );
}

void _showError(
  ScaffoldMessengerState messenger,
  NavigatorState navigator,
  String message,
) {
  final glass = navigator.mounted
      ? Theme.of(navigator.context).extension<GlassTheme>()
      : null;
  messenger.showSnackBar(
    SnackBar(content: Text(message), backgroundColor: glass?.moneySpending),
  );
}
