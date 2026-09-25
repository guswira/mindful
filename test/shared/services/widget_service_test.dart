import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mindful/features/habits/data/habit_repository.dart';
import 'package:mindful/features/habits/domain/habit.dart';
import 'package:mindful/features/habits/domain/habit_action.dart';
import 'package:mindful/features/habits/domain/habit_log.dart';
import 'package:mindful/features/journal/data/journal_repository.dart';
import 'package:mindful/features/journal/domain/journal_entry.dart';
import 'package:mindful/features/tasks/data/task_repository.dart';
import 'package:mindful/features/tasks/domain/task.dart';
import 'package:mindful/shared/services/widget_service.dart';

class _MockJournalRepository extends Mock implements JournalRepository {}

class _MockHabitRepository extends Mock implements HabitRepository {}

class _MockTaskRepository extends Mock implements TaskRepository {}

final _today = DateTime(2026, 3, 10);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('home_widget');
  final calls = <MethodCall>[];

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          // No small-widget mode saved yet in any of these tests — defaults
          // to 'tasks'.
          return call.method == 'getWidgetData' ? null : true;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  late _MockJournalRepository journalRepository;
  late _MockHabitRepository habitRepository;
  late _MockTaskRepository taskRepository;
  late WidgetService service;

  setUp(() {
    journalRepository = _MockJournalRepository();
    habitRepository = _MockHabitRepository();
    taskRepository = _MockTaskRepository();
    when(() => habitRepository.getTodayHabits()).thenReturn([]);
    when(() => habitRepository.getTodayLogs()).thenReturn([]);
    when(() => taskRepository.getDueToday()).thenReturn([]);
    when(() => journalRepository.getAll()).thenReturn([]);
    service = WidgetService(
      journalRepository: journalRepository,
      habitRepository: habitRepository,
      taskRepository: taskRepository,
      now: () => _today,
    );
  });

  MethodCall saveCallFor(String id) => calls.firstWhere(
    (call) =>
        call.method == 'saveWidgetData' && (call.arguments as Map)['id'] == id,
  );

  test('saves a 3-day journal streak ending today', () async {
    when(() => journalRepository.getAll()).thenReturn([
      _entry('j1', _today),
      _entry('j2', _today.subtract(const Duration(days: 1))),
      _entry('j3', _today.subtract(const Duration(days: 2))),
      _entry('j4', _today.subtract(const Duration(days: 5))),
    ]);

    await service.updateWidgetData();

    expect((saveCallFor('journalStreak').arguments as Map)['data'], 3);
  });

  test('sends today\'s habits as JSON with each one\'s completion', () async {
    final workout = Habit(
      id: 'h1',
      userId: 'u1',
      name: 'Workout',
      icon: '🏋️',
      color: '#FF0000',
      createdAt: _today,
      actions: const [HabitAction(id: 'a1', label: 'Gym')],
    );
    final meditate = Habit(
      id: 'h2',
      userId: 'u1',
      name: 'Meditate',
      icon: '🧘',
      color: '#00FF00',
      createdAt: _today,
    );
    when(
      () => habitRepository.getTodayHabits(),
    ).thenReturn([workout, meditate]);
    when(() => habitRepository.getTodayLogs()).thenReturn([
      HabitLog(
        id: 'l1',
        userId: 'u1',
        habitId: 'h1',
        date: _today,
        completedActionId: 'a1',
      ),
    ]);

    await service.updateWidgetData();

    expect((saveCallFor('habitsDone').arguments as Map)['data'], 1);
    expect((saveCallFor('habitsTotal').arguments as Map)['data'], 2);

    final habitsJson =
        jsonDecode((saveCallFor('habits').arguments as Map)['data'] as String)
            as List;
    expect(habitsJson, [
      {
        'id': 'h1',
        'name': 'Workout',
        'icon': '🏋️',
        'color': '#FF0000',
        'actions': ['Gym'],
        'isCompleted': true,
        'completedAction': 'a1',
      },
      {
        'id': 'h2',
        'name': 'Meditate',
        'icon': '🧘',
        'color': '#00FF00',
        'actions': <String>[],
        'isCompleted': false,
        'completedAction': null,
      },
    ]);
  });

  test('sends today\'s tasks as JSON, done or not', () async {
    final dueToday = _task('t1', 'Pay rent', dueDate: _today);
    final completedToday = _task(
      't2',
      'Done already',
      dueDate: _today,
      isCompleted: true,
    );
    when(
      () => taskRepository.getDueToday(),
    ).thenReturn([dueToday, completedToday]);

    await service.updateWidgetData();

    expect((saveCallFor('tasksDone').arguments as Map)['data'], 1);
    expect((saveCallFor('tasksTotal').arguments as Map)['data'], 2);

    final tasksJson =
        jsonDecode((saveCallFor('tasks').arguments as Map)['data'] as String)
            as List;
    expect(tasksJson, [
      {'id': 't1', 'name': 'Pay rent', 'isCompleted': false},
      {'id': 't2', 'name': 'Done already', 'isCompleted': true},
    ]);
  });

  test(
    'saveSmallWidgetMode saves the mode and refreshes widget data',
    () async {
      await service.saveSmallWidgetMode('habits');

      expect(
        (saveCallFor('smallWidgetMode').arguments as Map)['data'],
        'habits',
      );
      // Confirms the internal updateWidgetData() call ran too.
      expect((saveCallFor('habitsTotal').arguments as Map)['data'], 0);
    },
  );
}

JournalEntry _entry(String id, DateTime date) => JournalEntry(
  id: id,
  userId: 'u1',
  date: date,
  body: 'x',
  createdAt: date,
  updatedAt: date,
);

Task _task(
  String id,
  String name, {
  required DateTime dueDate,
  bool isCompleted = false,
}) => Task(
  id: id,
  userId: 'u1',
  name: name,
  createdAt: _today,
  updatedAt: _today,
  dueDate: dueDate,
  isCompleted: isCompleted,
);
