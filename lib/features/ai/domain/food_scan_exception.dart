/// Why a food scan failed — used to pick the right SnackBar message on
/// [AITab]. See SPEC.md AI Lab Feature Error handling.
///
/// [busy] is the one retryable type — Gemini reporting it's temporarily
/// overloaded or rate-limited — so [AITab] auto-retries on it and treats
/// every other type as final.
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
