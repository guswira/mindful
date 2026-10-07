import 'package:flutter/widgets.dart';

/// What the wide-screen detail pane is showing.
sealed class DetailSelection {
  const DetailSelection(this.id);

  final String id;

  @override
  bool operator ==(Object other) =>
      other.runtimeType == runtimeType && other is DetailSelection
      ? other.id == id
      : false;

  @override
  int get hashCode => Object.hash(runtimeType, id);
}

/// A task, by id.
final class TaskDetailSelection extends DetailSelection {
  const TaskDetailSelection(super.id);
}

/// A routine (habit), by id.
final class RoutineDetailSelection extends DetailSelection {
  const RoutineDetailSelection(super.id);
}

/// Lets rows show their item in an on-screen detail pane instead of a
/// sheet or page. Provided only by `ListDetailLayout` when it shows the
/// pane (tablet / landscape) — elsewhere there's none, and rows open
/// their sheet or page as usual.
class DetailSelectionScope extends InheritedWidget {
  const DetailSelectionScope({
    required this.selected,
    required this.onSelect,
    required super.child,
    super.key,
  });

  /// What the pane is showing, highlighted in the list.
  final DetailSelection? selected;

  final ValueChanged<DetailSelection> onSelect;

  static DetailSelectionScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<DetailSelectionScope>();

  /// Whether [selection] is what the pane around [context] is showing.
  static bool isSelected(BuildContext context, DetailSelection selection) =>
      maybeOf(context)?.selected == selection;

  /// Shows [selection] in the pane and returns true, or returns false when
  /// [context] has no pane — the caller opens its sheet or page instead.
  static bool trySelect(BuildContext context, DetailSelection selection) {
    final scope = maybeOf(context);
    if (scope == null) {
      return false;
    }
    scope.onSelect(selection);
    return true;
  }

  @override
  bool updateShouldNotify(DetailSelectionScope oldWidget) =>
      selected != oldWidget.selected || onSelect != oldWidget.onSelect;
}
