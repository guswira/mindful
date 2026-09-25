import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mindfull/features/tasks/data/task_reminders_controller.dart';
import 'package:mindfull/features/tasks/data/task_repository.dart';
import 'package:mindfull/features/tasks/domain/task.dart';
import 'package:mindfull/shared/services/notification_service.dart';

class _MockTaskRepository extends Mock implements TaskRepository {}

class _MockNotificationService extends Mock implements NotificationService {}

Task _task({
  required String id,
  DateTime? reminderAt,
  bool isCompleted = false,
}) => Task(
  id: id,
  userId: 'u1',
  name: 'Task $id',
  createdAt: DateTime(2026, 1, 1),
  updatedAt: DateTime(2026, 1, 1),
  reminderAt: reminderAt,
  isCompleted: isCompleted,
);

void main() {
  setUpAll(() {
    registerFallbackValue(_task(id: 'fallback'));
  });

  late _MockTaskRepository repository;
  late _MockNotificationService notificationService;
  late ProviderContainer container;

  setUp(() {
    repository = _MockTaskRepository();
    notificationService = _MockNotificationService();
    when(
      () => notificationService.scheduleTaskReminder(any()),
    ).thenAnswer((_) async {});

    container = ProviderContainer(
      overrides: [
        taskRepositoryProvider.overrideWith((ref) async => repository),
        notificationServiceProvider.overrideWith(
          (ref) async => notificationService,
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  test('reschedules every incomplete task with a reminder set — skips tasks '
      'with no reminder and tasks already completed (their reminder was '
      'cancelled on purpose when they were marked done)', () async {
    final withReminder = _task(id: 't1', reminderAt: DateTime(2026, 5, 1, 9));
    final withoutReminder = _task(id: 't2');
    final completedWithReminder = _task(
      id: 't3',
      reminderAt: DateTime(2026, 5, 2, 9),
      isCompleted: true,
    );
    when(
      () => repository.getAll(),
    ).thenReturn([withReminder, withoutReminder, completedWithReminder]);

    await container.read(taskRemindersProvider.future);

    verify(
      () => notificationService.scheduleTaskReminder(withReminder),
    ).called(1);
    verifyNever(
      () => notificationService.scheduleTaskReminder(withoutReminder),
    );
    verifyNever(
      () => notificationService.scheduleTaskReminder(completedWithReminder),
    );
  });

  test('does nothing when there are no tasks', () async {
    when(() => repository.getAll()).thenReturn([]);

    await container.read(taskRemindersProvider.future);

    verifyNever(() => notificationService.scheduleTaskReminder(any()));
  });
}
