// Analyzer false-positive: @JsonKey on a freezed abstract-class factory
// parameter is valid (json_serializable/freezed both handle it), but the
// analyzer doesn't yet recognize the target as a field.
// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

import 'budget_type.dart';

part 'budget_settings.freezed.dart';
part 'budget_settings.g.dart';

/// A user's spending budget for the current period. See SPEC.md Money Flow
/// Feature Data models.
///
/// Serializes to/from `snake_case` to match the `budget_settings` Supabase
/// table directly.
@freezed
abstract class BudgetSettings with _$BudgetSettings {
  const factory BudgetSettings({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'budget_type')
    @Default(BudgetType.monthly)
    BudgetType budgetType,
    @Default(0) double amount,
    @Default('IDR') String currency,
  }) = _BudgetSettings;

  factory BudgetSettings.fromJson(Map<String, dynamic> json) =>
      _$BudgetSettingsFromJson(json);
}
