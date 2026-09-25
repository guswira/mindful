import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_checkbox.freezed.dart';
part 'task_checkbox.g.dart';

/// A single subtask item on a [Task], e.g. "Buy ingredients".
@freezed
abstract class TaskCheckbox with _$TaskCheckbox {
  const factory TaskCheckbox({
    required String id,
    required String label,
    @Default(false) bool isChecked,
  }) = _TaskCheckbox;

  factory TaskCheckbox.fromJson(Map<String, dynamic> json) =>
      _$TaskCheckboxFromJson(json);
}
