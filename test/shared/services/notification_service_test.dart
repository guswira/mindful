import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'package:mindful/features/habits/domain/habit.dart';
import 'package:mindful/features/habits/domain/habit_action.dart';
import 'package:mindful/features/tasks/domain/task.dart';
import 'package:mindful/shared/services/notification_service.dart';

class _MockPlugin extends Mock implements FlutterLocalNotificationsPlugin {}

class _MockAndroidPlugin extends Mock
    implements AndroidFlutterLocalNotificationsPlugin {}

void main() {
  setUpAll(() {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('UTC'));
    registerFallbackValue(tz.TZDateTime.now(tz.local));
    registerFallbackValue(const NotificationDetails());
    registerFallbackValue(AndroidScheduleMode.inexactAllowWhileIdle);
  });

  late _MockPlugin plugin;
  late NotificationService service;

  setUp(() {
    plugin = _MockPlugin();
    // A fresh NotificationService gets its own fresh, in-memory id
    // allocators (see NotificationService's doc comment) — so every test
    // starts from a clean slate: the first habit/task it schedules always
    // lands on the first slot in its reserved range.
    service = NotificationService(plugin: plugin);
    when(
      () => plugin.zonedSchedule(
        id: any(named: 'id'),
        scheduledDate: any(named: 'scheduledDate'),
        notificationDetails: any(named: 'notificationDetails'),
        androidScheduleMode: any(named: 'androidScheduleMode'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        payload: any(named: 'payload'),
        matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
      ),
    ).thenAnswer((_) async {});
    when(() => plugin.cancel(id: any(named: 'id'))).thenAnswer((_) async {});
  });

  test(
    'enabling the morning reminder schedules id 1001 daily at 8:00',
    () async {
      await service.setJournalMorningReminderEnabled(true);

      final captured = verify(
        () => plugin.zonedSchedule(
          id: captureAny(named: 'id'),
          scheduledDate: captureAny(named: 'scheduledDate'),
          notificationDetails: any(named: 'notificationDetails'),
          androidScheduleMode: any(named: 'androidScheduleMode'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          payload: any(named: 'payload'),
          matchDateTimeComponents: captureAny(named: 'matchDateTimeComponents'),
        ),
      ).captured;

      expect(captured[0], NotificationService.journalMorningReminderId);
      final scheduledDate = captured[1] as tz.TZDateTime;
      expect(scheduledDate.hour, 8);
      expect(scheduledDate.minute, 0);
      expect(captured[2], DateTimeComponents.time);
    },
  );

  test(
    'enabling the evening reminder schedules id 1002 daily at 22:00',
    () async {
      await service.setJournalEveningReminderEnabled(true);

      final captured = verify(
        () => plugin.zonedSchedule(
          id: captureAny(named: 'id'),
          scheduledDate: captureAny(named: 'scheduledDate'),
          notificationDetails: any(named: 'notificationDetails'),
          androidScheduleMode: any(named: 'androidScheduleMode'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          payload: any(named: 'payload'),
          matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
        ),
      ).captured;

      expect(captured[0], NotificationService.journalEveningReminderId);
      final scheduledDate = captured[1] as tz.TZDateTime;
      expect(scheduledDate.hour, 22);
      expect(scheduledDate.minute, 0);
    },
  );

  test('schedules with the journal payload so taps are attributable', () async {
    await service.setJournalMorningReminderEnabled(true);

    verify(
      () => plugin.zonedSchedule(
        id: any(named: 'id'),
        scheduledDate: any(named: 'scheduledDate'),
        notificationDetails: any(named: 'notificationDetails'),
        androidScheduleMode: any(named: 'androidScheduleMode'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        payload: NotificationService.journalPayload,
        matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
      ),
    ).called(1);
  });

  test('disabling the morning reminder cancels notification 1001', () async {
    await service.setJournalMorningReminderEnabled(false);
    verify(
      () => plugin.cancel(id: NotificationService.journalMorningReminderId),
    ).called(1);
  });

  test('disabling the evening reminder cancels notification 1002', () async {
    await service.setJournalEveningReminderEnabled(false);
    verify(
      () => plugin.cancel(id: NotificationService.journalEveningReminderId),
    ).called(1);
  });

  group('habit reminders', () {
    final habit = Habit(
      id: 'h1',
      userId: 'u1',
      name: 'Workout',
      icon: '🏋️',
      color: '#FF0000',
      createdAt: DateTime(2026, 1, 1),
      reminderDays: const [0, 2],
      reminderTime: const TimeOfDay(hour: 9, minute: 30),
      actions: const [
        HabitAction(id: 'a1', label: 'Gym'),
        HabitAction(id: 'a2', label: 'Run'),
      ],
    );

    test('schedules one reminder per day, at a stable id block derived from '
        "the habit's own id", () async {
      await service.scheduleHabitReminder(habit);

      final captured = verify(
        () => plugin.zonedSchedule(
          id: captureAny(named: 'id'),
          scheduledDate: captureAny(named: 'scheduledDate'),
          notificationDetails: any(named: 'notificationDetails'),
          androidScheduleMode: any(named: 'androidScheduleMode'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          payload: any(named: 'payload'),
          matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
        ),
      ).captured;

      // habit.reminderDays is [0, 2] (Mon, Wed); the first habit ever
      // scheduled in a fresh allocator lands on slot 0 -> block base 2000.
      final ids = [captured[0] as int, captured[2] as int];
      expect(ids, [2000, 2002]);

      final dates = [
        captured[1] as tz.TZDateTime,
        captured[3] as tz.TZDateTime,
      ];
      expect(dates[0].weekday, DateTime.monday);
      expect(dates[1].weekday, DateTime.wednesday);
      expect(dates.every((d) => d.hour == 9 && d.minute == 30), isTrue);
    });

    test('includes an action button per habit action, up to 3', () async {
      await service.scheduleHabitReminder(habit);

      final details =
          verify(
                () => plugin.zonedSchedule(
                  id: any(named: 'id'),
                  scheduledDate: any(named: 'scheduledDate'),
                  notificationDetails: captureAny(named: 'notificationDetails'),
                  androidScheduleMode: any(named: 'androidScheduleMode'),
                  title: any(named: 'title'),
                  body: any(named: 'body'),
                  payload: any(named: 'payload'),
                  matchDateTimeComponents: any(
                    named: 'matchDateTimeComponents',
                  ),
                ),
              ).captured.first
              as NotificationDetails;

      final actions = details.android!.actions!;
      expect(actions.map((a) => a.id), ['a1', 'a2']);
      expect(actions.map((a) => a.title), ['Gym', 'Run']);
      expect(actions.every((a) => !a.showsUserInterface), isTrue);
    });

    test('a habit with no actions gets a single "Done" action', () async {
      await service.scheduleHabitReminder(habit.copyWith(actions: const []));

      final details =
          verify(
                () => plugin.zonedSchedule(
                  id: any(named: 'id'),
                  scheduledDate: any(named: 'scheduledDate'),
                  notificationDetails: captureAny(named: 'notificationDetails'),
                  androidScheduleMode: any(named: 'androidScheduleMode'),
                  title: any(named: 'title'),
                  body: any(named: 'body'),
                  payload: any(named: 'payload'),
                  matchDateTimeComponents: any(
                    named: 'matchDateTimeComponents',
                  ),
                ),
              ).captured.first
              as NotificationDetails;

      expect(details.android!.actions!.single.id, '_done');
    });

    test('encodes the habit id in the payload', () async {
      await service.scheduleHabitReminder(habit);

      verify(
        () => plugin.zonedSchedule(
          id: any(named: 'id'),
          scheduledDate: any(named: 'scheduledDate'),
          notificationDetails: any(named: 'notificationDetails'),
          androidScheduleMode: any(named: 'androidScheduleMode'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          payload: '{"habitId":"h1"}',
          matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
        ),
      ).called(2); // once per reminder day
    });

    test('a habit with no reminder time schedules nothing', () async {
      await service.scheduleHabitReminder(habit.copyWith(reminderTime: null));

      verifyNever(
        () => plugin.zonedSchedule(
          id: any(named: 'id'),
          scheduledDate: any(named: 'scheduledDate'),
          notificationDetails: any(named: 'notificationDetails'),
          androidScheduleMode: any(named: 'androidScheduleMode'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          payload: any(named: 'payload'),
          matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
        ),
      );
    });

    test('cancels every id in the habit\'s reserved block', () async {
      await service.scheduleHabitReminder(habit); // allocates block 2000-2006

      await service.cancelHabitReminder(habit.id);

      for (var day = 0; day <= 6; day++) {
        verify(() => plugin.cancel(id: 2000 + day)).called(1);
      }
    });

    test('cancelling a habit that was never scheduled is a no-op', () async {
      await service.cancelHabitReminder('never-scheduled');
      verifyNever(() => plugin.cancel(id: any(named: 'id')));
    });

    test('rescheduling the same habit reuses the same id block — editing it '
        'does not drift its notification ids', () async {
      await service.scheduleHabitReminder(habit);
      final firstIds = verify(
        () => plugin.zonedSchedule(
          id: captureAny(named: 'id'),
          scheduledDate: any(named: 'scheduledDate'),
          notificationDetails: any(named: 'notificationDetails'),
          androidScheduleMode: any(named: 'androidScheduleMode'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          payload: any(named: 'payload'),
          matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
        ),
      ).captured.cast<int>();

      await service.scheduleHabitReminder(habit.copyWith(name: 'Run'));
      final secondIds = verify(
        () => plugin.zonedSchedule(
          id: captureAny(named: 'id'),
          scheduledDate: any(named: 'scheduledDate'),
          notificationDetails: any(named: 'notificationDetails'),
          androidScheduleMode: any(named: 'androidScheduleMode'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          payload: any(named: 'payload'),
          matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
        ),
      ).captured.cast<int>();

      expect(secondIds, firstIds);
    });

    test('deleting one habit never changes another still-pending habit\'s '
        'ids — the bug the old list-position-based ids caused', () async {
      final habitB = habit.copyWith(id: 'h2', reminderDays: const [1]);

      await service.scheduleHabitReminder(habit); // block 2000-2006
      await service.scheduleHabitReminder(habitB); // block 2007-2013

      // "Delete" habit — forgets it, freeing its block for reuse.
      await service.forgetHabitReminder(habit.id);

      // A third habit scheduled afterward must NOT land on habit B's
      // still-pending block (2007-2013) — only on the now-freed one.
      final habitC = habit.copyWith(id: 'h3', reminderDays: const [3]);
      await service.scheduleHabitReminder(habitC);

      final idsForC = verify(
        () => plugin.zonedSchedule(
          id: captureAny(named: 'id'),
          scheduledDate: any(named: 'scheduledDate'),
          notificationDetails: any(named: 'notificationDetails'),
          androidScheduleMode: any(named: 'androidScheduleMode'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          payload: '{"habitId":"h3"}',
          matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
        ),
      ).captured.cast<int>();

      // Reused the freed block (2000-2006) at day 3 -> 2003, not anywhere
      // in h2's still-pending block (2007-2013).
      expect(idsForC.single, 2003);
      verifyNever(() => plugin.cancel(id: 2008)); // h2's actual id untouched
    });
  });

  group('task reminders', () {
    final task = Task(
      id: 't1',
      userId: 'u1',
      name: 'Buy groceries',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
      dueDate: DateTime(2026, 3, 5),
      // UTC to match the fixed `tz.local` set in setUpAll, so the captured
      // scheduledDate's hour matches reminderAt's exactly.
      reminderAt: DateTime.utc(2026, 3, 5, 9),
    );

    test('schedules at a stable id derived from the task\'s own id', () async {
      await service.scheduleTaskReminder(task);

      final captured = verify(
        () => plugin.zonedSchedule(
          id: captureAny(named: 'id'),
          scheduledDate: captureAny(named: 'scheduledDate'),
          notificationDetails: any(named: 'notificationDetails'),
          androidScheduleMode: any(named: 'androidScheduleMode'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          payload: any(named: 'payload'),
          matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
        ),
      ).captured;

      // First task ever scheduled in a fresh allocator lands on slot 0.
      expect(captured[0], 3000);
      final scheduledDate = captured[1] as tz.TZDateTime;
      expect(scheduledDate.hour, 9);
      expect(scheduledDate.minute, 0);
    });

    test('includes a "Mark done" action', () async {
      await service.scheduleTaskReminder(task);

      final details =
          verify(
                () => plugin.zonedSchedule(
                  id: any(named: 'id'),
                  scheduledDate: any(named: 'scheduledDate'),
                  notificationDetails: captureAny(named: 'notificationDetails'),
                  androidScheduleMode: any(named: 'androidScheduleMode'),
                  title: any(named: 'title'),
                  body: any(named: 'body'),
                  payload: any(named: 'payload'),
                  matchDateTimeComponents: any(
                    named: 'matchDateTimeComponents',
                  ),
                ),
              ).captured.first
              as NotificationDetails;

      expect(details.android!.actions!.single.title, 'Mark done');
    });

    test('encodes the task id in the payload', () async {
      await service.scheduleTaskReminder(task);

      verify(
        () => plugin.zonedSchedule(
          id: any(named: 'id'),
          scheduledDate: any(named: 'scheduledDate'),
          notificationDetails: any(named: 'notificationDetails'),
          androidScheduleMode: any(named: 'androidScheduleMode'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          payload: '{"taskId":"t1"}',
          matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
        ),
      ).called(1);
    });

    test('a task with no reminder schedules nothing', () async {
      await service.scheduleTaskReminder(task.copyWith(reminderAt: null));

      verifyNever(
        () => plugin.zonedSchedule(
          id: any(named: 'id'),
          scheduledDate: any(named: 'scheduledDate'),
          notificationDetails: any(named: 'notificationDetails'),
          androidScheduleMode: any(named: 'androidScheduleMode'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          payload: any(named: 'payload'),
          matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
        ),
      );
    });

    test('cancels the id reserved for the task', () async {
      await service.scheduleTaskReminder(task); // allocates id 3000

      await service.cancelTaskReminder(task.id);

      verify(() => plugin.cancel(id: 3000)).called(1);
    });

    test('cancelling a task that was never scheduled is a no-op', () async {
      await service.cancelTaskReminder('never-scheduled');
      verifyNever(() => plugin.cancel(id: any(named: 'id')));
    });

    test('deleting one task never changes another still-pending task\'s id '
        '— the bug the old list-position-based ids caused', () async {
      final taskB = task.copyWith(id: 't2');

      await service.scheduleTaskReminder(task); // id 3000
      await service.scheduleTaskReminder(taskB); // id 3001

      // "Delete" the first task — forgets it, freeing id 3000 for reuse.
      await service.forgetTaskReminder(task.id);

      // A third task scheduled afterward must NOT land on task B's
      // still-pending id (3001) — only on the now-freed one.
      final taskC = task.copyWith(id: 't3');
      await service.scheduleTaskReminder(taskC);

      final idForC = verify(
        () => plugin.zonedSchedule(
          id: captureAny(named: 'id'),
          scheduledDate: any(named: 'scheduledDate'),
          notificationDetails: any(named: 'notificationDetails'),
          androidScheduleMode: any(named: 'androidScheduleMode'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          payload: '{"taskId":"t3"}',
          matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
        ),
      ).captured.single;

      expect(idForC, 3000); // reused the freed id, not task B's
      verifyNever(() => plugin.cancel(id: 3001)); // task B's id untouched
    });
  });

  group('exact alarm permission (shared by habit and task reminders)', () {
    final task = Task(
      id: 't1',
      userId: 'u1',
      name: 'Buy groceries',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
      dueDate: DateTime(2026, 3, 5),
      reminderAt: DateTime.utc(2026, 3, 5, 9),
    );

    Future<AndroidScheduleMode> scheduleAndCaptureMode() async {
      await service.scheduleTaskReminder(task);
      return verify(
            () => plugin.zonedSchedule(
              id: any(named: 'id'),
              scheduledDate: any(named: 'scheduledDate'),
              notificationDetails: any(named: 'notificationDetails'),
              androidScheduleMode: captureAny(named: 'androidScheduleMode'),
              title: any(named: 'title'),
              body: any(named: 'body'),
              payload: any(named: 'payload'),
              matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
            ),
          ).captured.single
          as AndroidScheduleMode;
    }

    test('schedules exactly once the user has granted it', () async {
      final androidPlugin = _MockAndroidPlugin();
      when(
        () => plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >(),
      ).thenReturn(androidPlugin);
      when(
        () => androidPlugin.canScheduleExactNotifications(),
      ).thenAnswer((_) async => true);

      expect(
        await scheduleAndCaptureMode(),
        AndroidScheduleMode.exactAllowWhileIdle,
      );
    });

    test(
      'falls back to inexact scheduling instead of throwing when exact '
      'alarms aren\'t granted — the bug that left the add sheet stuck',
      () async {
        final androidPlugin = _MockAndroidPlugin();
        when(
          () => plugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >(),
        ).thenReturn(androidPlugin);
        when(
          () => androidPlugin.canScheduleExactNotifications(),
        ).thenAnswer((_) async => false);

        expect(
          await scheduleAndCaptureMode(),
          AndroidScheduleMode.inexactAllowWhileIdle,
        );
      },
    );

    test('also falls back when the platform implementation is unavailable '
        '(e.g. iOS, or an untouched mock)', () async {
      expect(
        await scheduleAndCaptureMode(),
        AndroidScheduleMode.inexactAllowWhileIdle,
      );
    });
  });

  group('scheduleTestNotification', () {
    test('schedules id 9001 five minutes from now', () async {
      final before = tz.TZDateTime.now(tz.local);

      final scheduledFor = await service.scheduleTestNotification();

      final captured = verify(
        () => plugin.zonedSchedule(
          id: captureAny(named: 'id'),
          scheduledDate: captureAny(named: 'scheduledDate'),
          notificationDetails: any(named: 'notificationDetails'),
          androidScheduleMode: any(named: 'androidScheduleMode'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          payload: any(named: 'payload'),
          matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
        ),
      ).captured;

      expect(captured[0], NotificationService.debugTestNotificationId);
      final scheduledDate = captured[1] as tz.TZDateTime;
      final elapsed = scheduledDate.difference(before);
      expect(elapsed.inSeconds, closeTo(300, 2));
      expect(scheduledFor, scheduledDate);
    });
  });
}
