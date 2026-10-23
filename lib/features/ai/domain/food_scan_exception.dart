/// Why a food scan failed — used to pick the right SnackBar message on
/// [AITab]. See SPEC.md AI Lab Feature Error handling.
///
/// [busy] (Gemini reporting it's temporarily overloaded or rate-limited)
/// and [timeout] are the retryable types — [AITab] auto-retries on them
/// and treats every other type as final.
enum FoodScanErrorType {
  notFood,
  networkError,
  apiError,
  busy,
  timeout,
  unknown,
}

/// Thrown by [GeminiService.analyzeFood] and
/// [ImageCompressionService.compress] when a scan can't complete.
class FoodScanException implements Exception {
  const FoodScanException(this.message, this.type);

  final String message;
  final FoodScanErrorType type;

  @override
  String toString() => message;
}
