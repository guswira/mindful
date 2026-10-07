import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/core/theme/app_theme.dart';
import 'package:mindful/features/habits/domain/habit.dart';
import 'package:mindful/features/habits/domain/habit_log.dart';
import 'package:mindful/features/habits/presentation/add_habit_sheet.dart';
import 'package:mindful/features/habits/presentation/habit_detail_screen.dart';
import 'package:mindful/features/habits/presentation/habit_detail_view.dart';
import 'package:mindful/features/habits/presentation/habit_providers.dart';
import 'package:mindful/features/habits/presentation/habit_tab.dart';
import 'package:mindful/features/plan/presentation/plan_tab.dart';
import 'package:mindful/features/plan/presentation/detail_pane.dart';
import 'package:mindful/features/tasks/domain/task.dart';
import 'package:mindful/features/tasks/presentation/task_detail_sheet.dart';
import 'package:mindful/features/tasks/presentation/task_providers.dart';
import 'package:mindful/features/tasks/presentation/task_tab.dart';

final _habit = Habit(
  id: 'h1',
  userId: 'u1',
  name: 'Meditate',
  icon: '🧘',
  color: '#00FF00',
  createdAt: DateTime(2026, 1, 1),
);

final _task = Task(
  id: 't1',
  userId: 'u1',
  name: 'Read a book',
  createdAt: DateTime(2026, 1, 1),
  updatedAt: DateTime(2026, 1, 1),
);

class _FakeHabitTabController extends HabitTabController {
  _FakeHabitTabController(this._items);

  final List<HabitTabItem> _items;

  @override
  Future<List<HabitTabItem>> build() async => _items;
}

class _FakeHabitDetailController extends HabitDetailController {
  @override
  Future<HabitDetailState> build(String habitId) async =>
      (month: DateTime(2026, 1), logsByDate: const <DateTime, HabitLog>{});
}

class _FakeTaskTabController extends TaskTabController {
  _FakeTaskTabController(this._tasks);

  final List<Task> _tasks;

  @override
  Future<List<Task>> build() async => _tasks;
}

Widget _buildTab({
  List<HabitTabItem> habits = const [],
  List<Task> tasks = const [],
}) => ProviderScope(
  overrides: [
    archivedHabitsProvider.overrideWith((ref) async => const []),
    habitTabControllerProvider.overrideWith(
      () => _FakeHabitTabController(habits),
    ),
    taskTabControllerProvider.overrideWith(() => _FakeTaskTabController(tasks)),
    taskByIdProvider(_task.id).overrideWith((ref) async => _task),
    habitByIdProvider(_habit.id).overrideWith((ref) async => _habit),
    habitDetailControllerProvider(
      _habit.id,
    ).overrideWith(_FakeHabitDetailController.new),
  ],
  child: MaterialApp(theme: AppTheme.dark, home: const PlanTab()),
);

void main() {
  testWidgets('shows routines and tasks on the same page', (tester) async {
    await tester.pumpWidget(
      _buildTab(habits: [(habit: _habit, todayLog: null)], tasks: [_task]),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tasks & Routines'), findsOneWidget);
    expect(find.text('Routines'), findsOneWidget);
    expect(find.text('Meditate'), findsOneWidget);
    expect(find.text('No date'), findsOneWidget);
    expect(find.text('Read a book'), findsOneWidget);
  });

  testWidgets('introduces routines and tasks when there is nothing yet', (
    tester,
  ) async {
    await tester.pumpWidget(_buildTab());
    await tester.pumpAndSettle();

    expect(find.text('Routines repeat every day'), findsOneWidget);
    expect(find.text('Add routine'), findsOneWidget);
    expect(find.text('Clear your head, one task at a time'), findsOneWidget);
    expect(find.text('Add task'), findsOneWidget);
  });

  testWidgets('the routines intro opens the add habit sheet', (tester) async {
    await tester.pumpWidget(_buildTab());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add routine'));
    await tester.pumpAndSettle();

    expect(find.byType(AddHabitSheet), findsOneWidget);
  });

  testWidgets('long-pressing a task offers converting it to a routine', (
    tester,
  ) async {
    await tester.pumpWidget(_buildTab(tasks: [_task]));
    await tester.pumpAndSettle();

    await tester.longPress(find.text('Read a book'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Convert to routine'));
    await tester.pumpAndSettle();

    expect(find.text('Save routine'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller?.text,
      'Read a book',
    );
  });

  group('wide screen', () {
    void setScreen(WidgetTester tester, Size size) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
    }

    testWidgets('a tapped task opens in the pane beside the list', (
      tester,
    ) async {
      setScreen(tester, const Size(1280, 800));
      await tester.pumpWidget(_buildTab(tasks: [_task]));
      await tester.pumpAndSettle();

      expect(find.byType(DetailPane), findsOneWidget);
      expect(find.byType(TaskDetailView), findsNothing);

      await tester.tap(find.text('Read a book'));
      await tester.pumpAndSettle();

      expect(find.byType(TaskDetailView), findsOneWidget);
      expect(find.byType(TaskDetailSheet), findsNothing);
      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets('a tapped routine opens its calendar in the pane', (
      tester,
    ) async {
      setScreen(tester, const Size(1280, 800));
      await tester.pumpWidget(
        _buildTab(habits: [(habit: _habit, todayLog: null)]),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Meditate'));
      await tester.pumpAndSettle();

      expect(find.byType(HabitDetailView), findsOneWidget);
      expect(find.byType(HabitDetailScreen), findsNothing);
    });

    testWidgets('a phone in landscape gets the pane too', (tester) async {
      setScreen(tester, const Size(844, 390));
      await tester.pumpWidget(_buildTab(tasks: [_task]));
      await tester.pumpAndSettle();

      expect(find.byType(DetailPane), findsOneWidget);
    });

    testWidgets('a phone in portrait keeps opening the detail sheet', (
      tester,
    ) async {
      setScreen(tester, const Size(390, 844));
      await tester.pumpWidget(_buildTab(tasks: [_task]));
      await tester.pumpAndSettle();

      expect(find.byType(DetailPane), findsNothing);

      await tester.tap(find.text('Read a book'));
      await tester.pumpAndSettle();

      expect(find.byType(TaskDetailSheet), findsOneWidget);
    });
  });

  group('foldables and dual screens', () {
    // A two-screen phone opened like a book: 540 + 20 hinge + 540.
    const screen = Size(1100, 720);
    const split = Rect.fromLTWH(540, 0, 20, 720);

    void setDevice(
      WidgetTester tester,
      DisplayFeatureType type,
      DisplayFeatureState state,
    ) {
      tester.view.physicalSize = screen;
      tester.view.devicePixelRatio = 1;
      tester.view.displayFeatures = [
        DisplayFeature(bounds: split, type: type, state: state),
      ];
      addTearDown(tester.view.reset);
    }

    double paneLeft(WidgetTester tester) =>
        tester.getTopLeft(find.byType(DetailPane)).dx;

    testWidgets('a hinge puts the list on the left screen, details right', (
      tester,
    ) async {
      setDevice(tester, DisplayFeatureType.hinge, DisplayFeatureState.unknown);
      await tester.pumpWidget(_buildTab(tasks: [_task]));
      await tester.pumpAndSettle();

      expect(
        tester.getTopRight(find.text('Read a book')).dx,
        lessThanOrEqualTo(split.left),
      );
      expect(paneLeft(tester), greaterThanOrEqualTo(split.right));
    });

    testWidgets('a half-open fold splits the same way', (tester) async {
      setDevice(
        tester,
        DisplayFeatureType.fold,
        DisplayFeatureState.postureHalfOpened,
      );
      await tester.pumpWidget(_buildTab(tasks: [_task]));
      await tester.pumpAndSettle();

      expect(paneLeft(tester), greaterThanOrEqualTo(split.right));
    });

    testWidgets('fully unfolded (flat) is one screen: the usual 3/5 split', (
      tester,
    ) async {
      setDevice(
        tester,
        DisplayFeatureType.fold,
        DisplayFeatureState.postureFlat,
      );
      await tester.pumpWidget(_buildTab(tasks: [_task]));
      await tester.pumpAndSettle();

      // The list's ~3/5 runs past the middle of a continuous screen.
      expect(paneLeft(tester), greaterThan(split.right));
      expect(paneLeft(tester), closeTo(screen.width * 3 / 5, 40));
    });
  });
}
