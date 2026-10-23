import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../shared/services/ai_activity.dart';
import '../../../shared/services/gemini_service.dart';
import '../../../shared/services/image_compression_service.dart';
import '../../../shared/services/notification_service.dart';
import '../../../shared/widgets/glass_bottom_sheet.dart';
import '../../auth/domain/auth_state.dart';
import '../data/food_scan_repository.dart';
import '../domain/food_analysis.dart';
import '../domain/food_scan_exception.dart';
import 'food_result_sheet.dart';
import 'food_scan_retry.dart';

/// Whether a [scanFood] run is still going — a second one would fight it
/// over the same notification id (4002).
bool _inFlight = false;

/// Compresses [image], sends it to Gemini and offers the result — without
/// blocking the app: the AI activity pill at the top of the screen shows
/// it's running (and any retry), then turns into "ready — tap to view".
/// A busy or slow Gemini is retried per [runWithRetry]; a progress
/// notification (id 4002) tracks it while the app is in the background,
/// and a failure after a retry leaves a notification the user can act on.
/// See SPEC.md AI Lab Feature Food Scan Flow.
///
/// Holds the root [NavigatorState], [ScaffoldMessengerState] and
/// [ProviderContainer] rather than [context], since the scan outlives the
/// AI tab whenever the user moves on.
Future<void> scanFood(BuildContext context, Uint8List image) async {
  final messenger = ScaffoldMessenger.of(context);
  if (_inFlight) {
    messenger.showSnackBar(
      SnackBar(content: Text(context.l10n.aiScanInProgress)),
    );
    return;
  }
  _inFlight = true;
  try {
    await _run(
      image,
      container: ProviderScope.containerOf(context),
      navigator: Navigator.of(context, rootNavigator: true),
      messenger: messenger,
    );
  } finally {
    _inFlight = false;
  }
}

Future<void> _run(
  Uint8List image, {
  required ProviderContainer container,
  required NavigatorState navigator,
  required ScaffoldMessengerState messenger,
}) async {
  final activity = container.read(aiActivityProvider.notifier);
  final id = activity.start(AiActivityKind.foodScan);
  final notifications = await container.read(
    notificationServiceProvider.future,
  );
  await notifications.showFoodScanProgress(currentL10n.aiNotifAnalyzingBody);

  var retried = false;
  try {
    final compressed = await container
        .read(imageCompressionServiceProvider)
        .compress(image);
    final analysis = await runWithRetry(
      attempt: () =>
          container.read(geminiServiceProvider).analyzeFood(compressed),
      onRetry: (attemptNumber) async {
        retried = true;
        activity.retrying(id, attemptNumber, FoodScanRetryPolicy.maxAttempts);
        await notifications.showFoodScanProgress(
          currentL10n.aiNotifRetryingBody(
            attemptNumber,
            FoodScanRetryPolicy.maxAttempts,
          ),
        );
      },
    );
    await notifications.cancelFoodScanNotification();
    if (analysis == null) {
      activity.finish(id);
      _showMessage(messenger, navigator, currentL10n.aiErrorNotFood);
      return;
    }
    activity.ready(
      id,
      () => _showResult(analysis, container, navigator, messenger),
    );
  } on FoodScanException catch (error) {
    final message = foodScanMessage(error);
    activity.finish(id);
    await notifications.cancelFoodScanNotification();
    // After a retry the user has likely moved on (or left the app) —
    // leave a notification they can act on, not just a SnackBar.
    if (retried) {
      await notifications.showFoodScanFailed(message);
    }
    _showMessage(messenger, navigator, message, isError: true);
  }
}

void _showResult(
  FoodAnalysis analysis,
  ProviderContainer container,
  NavigatorState navigator,
  ScaffoldMessengerState messenger,
) {
  if (!navigator.mounted) {
    return;
  }
  unawaited(
    showGlassBottomSheet<void>(
      context: navigator.context,
      builder: (_) => FoodResultSheet(
        analysis: analysis,
        onSave: () => _saveScan(analysis, container, navigator, messenger),
      ),
    ),
  );
}

Future<void> _saveScan(
  FoodAnalysis analysis,
  ProviderContainer container,
  NavigatorState navigator,
  ScaffoldMessengerState messenger,
) async {
  await container
      .read(foodScanRepositoryProvider)
      .saveScan(
        userId: container.read(currentUserIdProvider),
        analysis: analysis,
      );
  container.invalidate(recentScansProvider);
  if (navigator.mounted) {
    navigator.pop();
  }
  messenger.showSnackBar(SnackBar(content: Text(currentL10n.aiScanSaved)));
}

void _showMessage(
  ScaffoldMessengerState messenger,
  NavigatorState navigator,
  String message, {
  bool isError = false,
}) {
  final glass = isError && navigator.mounted
      ? Theme.of(navigator.context).extension<GlassTheme>()
      : null;
  messenger.showSnackBar(
    SnackBar(content: Text(message), backgroundColor: glass?.moneySpending),
  );
}
