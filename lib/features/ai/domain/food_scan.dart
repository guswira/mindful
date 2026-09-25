// Analyzer false-positive: @JsonKey on a freezed abstract-class factory
// parameter is valid (json_serializable/freezed both handle it), but the
// analyzer doesn't yet recognize the target as a field.
// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'food_scan.freezed.dart';
part 'food_scan.g.dart';

/// A saved food scan result. See SPEC.md AI Lab Feature Data models.
///
/// Serializes to/from `snake_case` to match the `food_scans` Supabase table
/// directly. Every nutrition field is nullable — a scan is saved from a
/// [FoodAnalysis] the caller already has, but this model needs to also
/// round-trip rows the analysis step never touched.
@freezed
abstract class FoodScan with _$FoodScan {
  const factory FoodScan({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'scanned_at') required DateTime scannedAt,
    @JsonKey(name: 'food_name') String? foodName,
    int? calories,
    double? protein,
    double? carbs,
    double? fat,
    double? fiber,
    String? confidence,
    String? note,
  }) = _FoodScan;

  factory FoodScan.fromJson(Map<String, dynamic> json) =>
      _$FoodScanFromJson(json);
}
