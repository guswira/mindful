import 'package:freezed_annotation/freezed_annotation.dart';

part 'money_advice.freezed.dart';
part 'money_advice.g.dart';

/// Gemini's spending advice for the user's money entries — transient,
/// never persisted. Field names match Gemini's JSON response verbatim;
/// every string is already in the app language, since the prompt itself
/// is localized. See SPEC.md Money Flow Feature AI Advice and
/// [GeminiService.adviseOnMoney].
@freezed
abstract class MoneyAdvice with _$MoneyAdvice {
  const factory MoneyAdvice({
    required String summary,
    @Default([]) List<String> spendingInsights,
    @Default([]) List<String> savingTips,
  }) = _MoneyAdvice;

  factory MoneyAdvice.fromJson(Map<String, dynamic> json) =>
      _$MoneyAdviceFromJson(json);
}
