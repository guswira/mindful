import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mindful/features/auth/domain/auth_state.dart';
import 'package:mindful/features/habits/data/habit_repository.dart';
import 'package:mindful/features/habits/domain/habit.dart';
import 'package:mindful/features/habits/domain/habit_action.dart';
import 'package:mindful/features/habits/domain/habit_log.dart';
import 'package:mindful/features/habits/presentation/habit_tab.dart';
import 'package:mindful/shared/services/widget_service.dart';

class _MockRepository extends Mock implements HabitRepository {}

const _push = HabitAction(id: 'a1', label: 'Push');
const _pull = HabitAction(id: 'a2', label: 'Pull');

final _habit = Habit(
  id: 'h1',
  userId: 'u1',
  name: 'Gym',
  icon: '🏋️',
  color: '#FF0000',
  createdAt: DateTime(2026),
  actions: const [_push, _pull],
);

void main() {
  late _MockRepository repository;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(
      HabitLog(id: '', userId: '', habitId: '', date: DateTime(2000)),
    );
    registerFallbackValue(DateTime(2000));
  });

  setUp(() {
    repository = _MockRepository();
    when(() => repository.refreshFromSupabase()).thenAnswer((_) async {});
    when(() => repository.getHabits()).thenReturn([_habit]);
    when(() => repository.saveLog(any())).thenAnswer((_) async {});
    container = ProviderContainer(
      overrides: [
        habitRepositoryProvider.overrideWith((ref) async => repository),
        currentUserIdProvider.overrideWith((ref) => 'u1'),
        widgetServiceProvider.overrideWith(
          (ref) async => throw UnimplementedError(),
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  test('switching action keeps the day\'s log id, note and tags', () async {
    final existing = HabitLog(
      id: 'log1',
      userId: 'u1',
      habitId: 'h1',
      date: DateTime(2026, 3, 15),
      completedActionId: 'a1',
      note: 'felt great',
      tags: const {'heavy': 1, 'easy': 3},
    );
    when(() => repository.getLog('h1', any())).thenReturn(existing);

    await container
        .read(habitTabControllerProvider.notifier)
        .logAction(_habit, _pull, on: DateTime(2026, 3, 15));

    final saved =
        verify(() => repository.saveLog(captureAny())).captured.single
            as HabitLog;
    expect(saved.id, 'log1');
    expect(saved.completedActionId, 'a2');
    expect(saved.note, 'felt great');
    expect(saved.tags, {'heavy': 1, 'easy': 3});
  });

  test('a first log starts untagged', () async {
    when(() => repository.getLog('h1', any())).thenReturn(null);

    await container
        .read(habitTabControllerProvider.notifier)
        .logAction(_habit, _push);

    final saved =
        verify(() => repository.saveLog(captureAny())).captured.single
            as HabitLog;
    expect(saved.completedActionId, 'a1');
    expect(saved.tags, isNull);
  });
}
