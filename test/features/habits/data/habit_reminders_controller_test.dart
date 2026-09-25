import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mindful/features/habits/data/habit_reminders_controller.dart';
import 'package:mindful/features/habits/data/habit_repository.dart';
import 'package:mindful/features/habits/domain/habit.dart';
import 'package:mindful/shared/services/notification_service.dart';

class _MockHabitRepository extends Mock implements HabitRepository {}

class _MockNotificationService extends Mock implements NotificationService {}

Habit _habit({
  required String id,
  bool archived = false,
  List<int> reminderDays = const [],
  TimeOfDay? reminderTime,
}) => Habit(
  id: id,
  userId: 'u1',
  name: 'Habit $id',
  icon: '🏋️',
  color: '#FF0000',
  createdAt: DateTime(2026, 1, 1),
  archived: archived,
  reminderDays: reminderDays,
  reminderTime: reminderTime,
);

void main() {
  setUpAll(() {
    registerFallbackValue(_habit(id: 'fallback'));
  });

  late _MockHabitRepository repository;
  late _MockNotificationService notificationService;
  late ProviderContainer container;

  setUp(() {
    repository = _MockHabitRepository();
    notificationService = _MockNotificationService();
    when(
      () => notificationService.scheduleHabitReminder(any()),
    ).thenAnswer((_) async {});

    container = ProviderContainer(
      overrides: [
        habitRepositoryProvider.overrideWith((ref) async => repository),
        notificationServiceProvider.overrideWith(
          (ref) async => notificationService,
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  const reminderTime = TimeOfDay(hour: 8, minute: 0);

  test('reschedules every active habit with a reminder set — skips habits '
      'with no reminder and archived habits (their reminder was cancelled '
      'on purpose when they were archived)', () async {
    final active = _habit(
      id: 'h1',
      reminderDays: const [0],
      reminderTime: reminderTime,
    );
    final noReminder = _habit(id: 'h2');
    final archivedWithReminder = _habit(
      id: 'h3',
      archived: true,
      reminderDays: const [1],
      reminderTime: reminderTime,
    );
    when(
      () => repository.getHabits(),
    ).thenReturn([active, noReminder, archivedWithReminder]);

    await container.read(habitRemindersProvider.future);

    verify(() => notificationService.scheduleHabitReminder(active)).called(1);
    verifyNever(() => notificationService.scheduleHabitReminder(noReminder));
    verifyNever(
      () => notificationService.scheduleHabitReminder(archivedWithReminder),
    );
  });

  test('does nothing when there are no habits', () async {
    when(() => repository.getHabits()).thenReturn([]);

    await container.read(habitRemindersProvider.future);

    verifyNever(() => notificationService.scheduleHabitReminder(any()));
  });
}
