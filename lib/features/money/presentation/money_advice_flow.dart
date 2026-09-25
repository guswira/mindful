import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../shared/services/gemini_service.dart';
import '../../../shared/services/notification_service.dart';
import '../../../shared/widgets/glass_bottom_sheet.dart';
import '../../ai/domain/food_scan_exception.dart';
import '../../ai/presentation/food_scan_retry.dart';
import '../data/money_repository.dart';
import 'money_advice_sheet.dart';
import 'money_advice_summary.dart';

/// Whether a [requestMoneyAdvice] run is still going — possibly minutes
/// into its retries, long after its loading sheet was dismissed. A second
/// run would fight the first over the same notification id.
bool _inFlight = false;

/// Sends every money entry to Gemini and shows the advice — the same
/// flow as [AITab]'s food scan: a non-dismissible loading sheet plus a
/// progress notification (id 4003), auto-retrying a busy Gemini response
/// per [runWithRetry]. The sheet is dismissed on the first retry (the
/// notification carries progress from there); a final failure after that
/// also leaves a failure notification with a "Retry" action. See SPEC.md
/// Money Flow Feature AI Advice.
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
  final entries = repository.getEntries();
  if (entries.isEmpty) {
    messenger.showSnackBar(
      SnackBar(content: Text(currentL10n.moneyAdviceNoEntries)),
    );
    return;
  }
  final summary = buildMoneyAdviceSummary(
    entries,
    await repository.getCurrency(),
  );
  if (!navigator.mounted) {
    return;
  }

  unawaited(
    showGlassBottomSheet<void>(
      context: navigator.context,
      isDismissible: false,
      builder: (_) => const MoneyAdviceLoadingSheet(),
    ),
  );
  var sheetOpen = true;
  void closeSheet() {
    if (sheetOpen && navigator.mounted) {
      navigator.pop();
    }
    sheetOpen = false;
  }

  final notifications = await container.read(
    notificationServiceProvider.future,
  );
  await notifications.showMoneyAdviceProgress(currentL10n.moneyAdviceLoading);

  try {
    final advice = await runWithRetry(
      attempt: () =>
          container.read(geminiServiceProvider).adviseOnMoney(summary),
      onRetry: (attemptNumber) async {
        // Free up the UI once we know this will take a while — the
        // notification carries progress from here instead.
        closeSheet();
        await notifications.showMoneyAdviceProgress(
          currentL10n.aiNotifRetryingBody(
            attemptNumber,
            FoodScanRetryPolicy.maxAttempts,
          ),
        );
      },
    );
    await notifications.cancelMoneyAdviceNotification();
    closeSheet();
    if (navigator.mounted) {
      unawaited(
        showGlassBottomSheet<void>(
          context: navigator.context,
          builder: (_) => MoneyAdviceSheet(advice: advice),
        ),
      );
    }
  } on FoodScanException catch (error) {
    final message = foodScanMessage(error);
    // Once the sheet's been dismissed for a retry, the user may well not
    // be watching any more — leave a notification they can act on too.
    final wasDismissed = !sheetOpen;
    await notifications.cancelMoneyAdviceNotification();
    if (wasDismissed) {
      await notifications.showMoneyAdviceFailed(message);
    }
    closeSheet();
    _showError(messenger, navigator, message);
  }
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
