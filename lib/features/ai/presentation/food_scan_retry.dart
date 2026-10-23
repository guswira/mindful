import '../../../core/l10n/l10n.dart';
import '../domain/food_scan_exception.dart';

/// How long and how often [runWithRetry] retries a busy or timed-out
/// Gemini response before giving up automatically — shared by the food
/// scan and money advice requests.
class FoodScanRetryPolicy {
  const FoodScanRetryPolicy._();

  /// Waits before attempts 2, 3, 4 and 5. A 503 often clears within
  /// seconds, so the first retry comes quickly; the waits then grow so a
  /// genuinely overloaded model isn't hammered. (A flat minute made every
  /// busy scan take at least a minute and a half.)
  static const List<Duration> _delays = [
    Duration(seconds: 5),
    Duration(seconds: 15),
    Duration(seconds: 30),
    Duration(minutes: 1),
  ];

  static const int maxAttempts = 5;

  /// The wait before [attemptNumber] (2–[maxAttempts]).
  static Duration delayBefore(int attemptNumber) =>
      _delays[(attemptNumber - 2).clamp(0, _delays.length - 1)];
}

/// Runs [attempt] once, then keeps retrying it — waiting
/// [delayBefore] the next attempt number between tries, calling [onRetry] before each wait — as long as it keeps failing
/// with [FoodScanErrorType.busy] or [FoodScanErrorType.timeout] (a slow
/// reply is usually Gemini under load too) and fewer than [maxAttempts]
/// have run in total. Any other failure, or running out of attempts, rethrows that
/// [FoodScanException] instead of retrying it.
///
/// [delayBefore] and [maxAttempts] default to [FoodScanRetryPolicy]'s —
/// overridable so tests can exercise the "gives up" path without a real
/// multi-minute wait.
Future<T> runWithRetry<T>({
  required Future<T> Function() attempt,
  required Future<void> Function(int attemptNumber) onRetry,
  Duration Function(int attemptNumber) delayBefore =
      FoodScanRetryPolicy.delayBefore,
  int maxAttempts = FoodScanRetryPolicy.maxAttempts,
}) async {
  var attemptNumber = 1;
  while (true) {
    try {
      return await attempt();
    } on FoodScanException catch (error) {
      final retryable = switch (error.type) {
        FoodScanErrorType.busy || FoodScanErrorType.timeout => true,
        _ => false,
      };
      final canRetry = retryable && attemptNumber < maxAttempts;
      if (!canRetry) {
        rethrow;
      }
      attemptNumber++;
      await onRetry(attemptNumber);
      await Future<void>.delayed(delayBefore(attemptNumber));
    }
  }
}

// apiError, busy and unknown carry a message GeminiService already
// tailored to the actual failure (busy model, bad key, retired model,
// ...) — the other types are always the same fixed condition, so a
// canned message reads better than repeating the raw exception text.
/// The message worth showing the user for [error] — shared by [AITab]'s
/// SnackBar and the failure notification.
String foodScanMessage(FoodScanException error) => switch (error.type) {
  FoodScanErrorType.notFood => currentL10n.aiErrorNotFood,
  FoodScanErrorType.networkError => currentL10n.aiErrorNoConnection,
  FoodScanErrorType.apiError => error.message,
  FoodScanErrorType.busy => error.message,
  FoodScanErrorType.timeout => currentL10n.aiErrorTimeout,
  FoodScanErrorType.unknown => error.message,
};
