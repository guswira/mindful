import 'package:freezed_annotation/freezed_annotation.dart';

part 'habit_tag.freezed.dart';
part 'habit_tag.g.dart';

/// An optional label a day's log can carry on top of its action, e.g.
/// "Heavy" or "Easy" — it applies to every action of the habit.
@freezed
abstract class HabitTag with _$HabitTag {
  const factory HabitTag({required String id, required String label}) =
      _HabitTag;

  factory HabitTag.fromJson(Map<String, dynamic> json) =>
      _$HabitTagFromJson(json);
}
