import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../shared/services/notification_service.dart';
import '../domain/food_scan_exception.dart';

/// How long and how often [runWithRetry] retries a busy Gemini response
/// before giving up automatically — shared by the food scan and money
/// advice requests.
class FoodScanRetryPolicy {
  const FoodScanRetryPolicy._();

  static const Duration delay = Duration(minutes: 1);
  static const int maxAttempts = 5;
}

/// Runs [attempt] once, then keeps retrying it — waiting [delay] between
/// tries, calling [onRetry] before each wait — as long as it keeps failing
/// with [FoodScanErrorType.busy] and fewer than [maxAttempts] have run in
/// total. Any other failure, or running out of attempts, rethrows that
/// [FoodScanException] instead of retrying it.
///
/// [delay] and [maxAttempts] default to [FoodScanRetryPolicy]'s —
/// overridable so tests can exercise the "gives up" path without a real
/// multi-minute wait.
Future<T> runWithRetry<T>({
  required Future<T> Function() attempt,
  required Future<void> Function(int attemptNumber) onRetry,
  Duration delay = FoodScanRetryPolicy.delay,
  int maxAttempts = FoodScanRetryPolicy.maxAttempts,
}) async {
  var attemptNumber = 1;
  while (true) {
    try {
      return await attempt();
    } on FoodScanException catch (error) {
      final canRetry =
          error.type == FoodScanErrorType.busy && attemptNumber < maxAttempts;
      if (!canRetry) {
        rethrow;
      }
      attemptNumber++;
      await onRetry(attemptNumber);
      await Future.delayed(delay);
    }
  }
}

/// Shows (or updates) the ongoing "analyzing" notification with [body].
Future<void> showFoodScanProgressNotification(
  WidgetRef ref,
  String body,
) async {
  final service = await ref.read(notificationServiceProvider.future);
  await service.showFoodScanProgress(body);
}

/// Clears the progress notification — or, if [failureMessage] is given,
/// replaces it with a final failure the user can retry from instead.
/// Called once a scan either succeeds or gives up retrying.
Future<void> resolveFoodScanNotification(
  WidgetRef ref, {
  String? failureMessage,
}) async {
  final service = await ref.read(notificationServiceProvider.future);
  await service.cancelFoodScanNotification();
  if (failureMessage != null) {
    await service.showFoodScanFailed(failureMessage);
  }
}

// apiError, busy and unknown carry a message GeminiService already
// tailored to the actual failure (busy model, bad key, retired model,
// ...) — the other types are always the same fixed condition, so a
// canned message reads better than repeating the raw exception text.
/// The message worth showing the user for [error] — shared by [AITab]'s
/// SnackBar and [resolveFoodScanNotification]'s failure notification.
String foodScanMessage(FoodScanException error) => switch (error.type) {
  FoodScanErrorType.notFood => currentL10n.aiErrorNotFood,
  FoodScanErrorType.networkError => currentL10n.aiErrorNoConnection,
  FoodScanErrorType.apiError => error.message,
  FoodScanErrorType.busy => error.message,
  FoodScanErrorType.timeout => currentL10n.aiErrorTimeout,
  FoodScanErrorType.unknown => error.message,
};
