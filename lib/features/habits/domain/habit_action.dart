import 'package:freezed_annotation/freezed_annotation.dart';

part 'habit_action.freezed.dart';
part 'habit_action.g.dart';

/// A customizable completion button on a [Habit], e.g. "Gym" or "Run".
@freezed
abstract class HabitAction with _$HabitAction {
  const factory HabitAction({
    required String id,
    required String label,
    @Default(false) bool isDefault,
  }) = _HabitAction;

  factory HabitAction.fromJson(Map<String, dynamic> json) =>
      _$HabitActionFromJson(json);
}
