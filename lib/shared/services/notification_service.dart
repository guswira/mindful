import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../core/l10n/l10n.dart';
import '../../features/habits/domain/habit.dart';
import '../../features/tasks/domain/task.dart';
import 'notification_id_allocator.dart';

part 'notification_service.g.dart';

/// Action id used for a habit with no custom actions — see
/// [NotificationService.scheduleHabitReminder].
const String _doneActionId = '_done';

/// Action id for a task reminder's "Mark done" button — see
/// [NotificationService.scheduleTaskReminder].
const String _taskMarkDoneActionId = '_task_mark_done';

/// Action id for the food scan failure notification's "Retry" button — see
/// [NotificationService.showFoodScanFailed].
const String _foodScanRetryActionId = '_food_scan_retry';

/// Action id for the money advice failure notification's "Retry" button —
/// see [NotificationService.showMoneyAdviceFailed].
const String _moneyAdviceRetryActionId = '_money_advice_retry';

/// Monochrome app-icon silhouette (res/drawable-*/ic_stat_notification.png).
const String _smallIcon = 'ic_stat_notification';

/// The full-colour app icon, shown inside the expanded notification.
const AndroidBitmap<Object> _largeIcon = DrawableResourceAndroidBitmap(
  'ic_notification_large',
);

/// Schedules and cancels the app's local notifications, and reports taps.
///
/// Notification IDs are reserved per SPEC.md: 1001/1002 for the journal's
/// morning/evening reminders, 2000-2999 for habit reminders (7 ids per
/// habit, one per weekday), 3000-3999 for task reminders, 4001 for the
/// monthly budget reset reminder, 4002 for a food scan's progress/failure
/// (see [showFoodScanProgress]), 4003 for a money advice request's
/// progress/failure (see [showMoneyAdviceProgress]), 9001 for the Settings debug screen's test
/// notification (see [scheduleTestNotification]). Habit/task ids are
/// assigned per-item, via [_habitIdAllocator]/[_taskIdAllocator] — see
/// [NotificationIdAllocator]'s doc comment for why an item's position in
/// its list isn't safe to derive an id from.
class NotificationService {
  NotificationService({
    FlutterLocalNotificationsPlugin? plugin,
    NotificationIdAllocator? taskIdAllocator,
    NotificationIdAllocator? habitIdAllocator,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin(),
       _taskIdAllocator = taskIdAllocator ?? _defaultTaskIdAllocator(),
       _habitIdAllocator = habitIdAllocator ?? _defaultHabitIdAllocator();

  final FlutterLocalNotificationsPlugin _plugin;
  final NotificationIdAllocator _taskIdAllocator;
  final NotificationIdAllocator _habitIdAllocator;
  final StreamController<String?> _tapController =
      StreamController<String?>.broadcast();

  static const int journalMorningReminderId = 1001;
  static const int journalEveningReminderId = 1002;
  static const int budgetResetReminderId = 4001;
  static const int foodScanNotificationId = 4002;
  static const int moneyAdviceNotificationId = 4003;
  static const int debugTestNotificationId = 9001;

  /// Reserved ranges for the per-item allocators — see class doc.
  static const int taskIdBase = 3000;
  static const int taskIdSlotCount = 1000;
  static const int habitIdBase = 2000;
  static const int habitIdSlotCount = 142;
  static const int habitIdBlockSize = 7;

  /// Falls back to an unpersisted, in-memory allocator when the caller
  /// (e.g. a test) doesn't wire up a real one — see
  /// [InMemoryNotificationIdStore]. The real [notificationServiceProvider]
  /// always passes a [HiveNotificationIdStore]-backed one instead, so ids
  /// persist across app restarts.
  static NotificationIdAllocator _defaultTaskIdAllocator() =>
      NotificationIdAllocator(
        InMemoryNotificationIdStore(),
        base: taskIdBase,
        slotCount: taskIdSlotCount,
      );

  static NotificationIdAllocator _defaultHabitIdAllocator() =>
      NotificationIdAllocator(
        InMemoryNotificationIdStore(),
        base: habitIdBase,
        slotCount: habitIdSlotCount,
        blockSize: habitIdBlockSize,
      );

  /// Payload attached to both journal reminder notifications.
  static const String journalPayload = 'journal';

  /// Payload attached to the food scan failure notification, and its
  /// "Retry" action — both just reopen the AI tab, per
  /// [showFoodScanFailed].
  static const String foodScanPayload = 'food_scan';

  /// Payload attached to the money advice failure notification, and its
  /// "Retry" action — both reopen the Money tab, per
  /// [showMoneyAdviceFailed].
  static const String moneyAdvicePayload = 'money_advice';

  bool _initialized = false;

  /// Payloads of tapped notifications — including the one that launched a
  /// previously-terminated app.
  Stream<String?> get onNotificationTap => _tapController.stream;

  /// Sets up the plugin and time zone data, and requests permission to show
  /// notifications. Safe to call more than once.
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    _initialized = true;

    tz_data.initializeTimeZones();
    final localTimezone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localTimezone.identifier));

    await _plugin.initialize(
      settings: const InitializationSettings(
        // Status-bar icons are drawn from alpha only, so the full-colour
        // launcher icon would render as a solid white blob — this is its
        // white-on-transparent silhouette. Default for every notification.
        android: AndroidInitializationSettings(_smallIcon),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (response) =>
          _tapController.add(response.payload),
      onDidReceiveBackgroundNotificationResponse:
          _handleBackgroundNotificationResponse,
    );

    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      _tapController.add(launchDetails!.notificationResponse?.payload);
    }

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    // If this is false (denied, or the system dialog was dismissed),
    // every notification silently fails to display from here on — the
    // scheduling/AlarmManager side (below) still succeeds regardless,
    // logging as if everything's fine, which makes a denied permission
    // easy to mistake for a scheduling bug. Log it so that's visible.
    final notificationsGranted = await androidPlugin
        ?.requestNotificationsPermission();
    debugPrint(
      'NotificationService: requestNotificationsPermission=$notificationsGranted, '
      'areNotificationsEnabled=${await androidPlugin?.areNotificationsEnabled()}',
    );
    // A channel's importance/sound/vibration are locked in at whatever they
    // were the first time it was created on this device — a later
    // AndroidNotificationDetails with different settings for the same
    // channel id is silently ignored by Android. If 'task_reminders' (or
    // 'habit_reminders') got created with low importance by an older
    // build, or the user muted it from the system notification settings,
    // reminders would stop showing with no error anywhere in this app —
    // this is the only way to see that from here.
    final channels = await androidPlugin?.getNotificationChannels();
    debugPrint(
      'NotificationService: existing channels: '
      '${channels?.map((c) => '${c.id}=${c.importance}').join(', ')}',
    );
    // Habit/task reminders schedule exactly (AndroidScheduleMode
    // .exactAllowWhileIdle) — this needs the user's separate, explicit
    // consent on Android 12+. _exactAlarmScheduleMode falls back to inexact
    // if it's declined, so reminders still fire either way.
    await androidPlugin?.requestExactAlarmsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    // Unconditional and not user-toggleable, unlike the journal reminders
    // above — see SPEC.md Money Flow Feature Notification IDs addition.
    await scheduleBudgetResetReminder();
  }

  /// Schedules the "New month, new budget" reminder for the 1st of every
  /// month. See SPEC.md Money Flow Feature Notification IDs addition.
  ///
  /// Also re-run whenever the app language changes — a scheduled
  /// notification's text is fixed when it's scheduled, so rescheduling is
  /// the only way to have it show up in the new language.
  Future<void> scheduleBudgetResetReminder() {
    final l10n = currentL10n;
    return _plugin.zonedSchedule(
      id: budgetResetReminderId,
      title: l10n.notifBudgetResetTitle,
      body: l10n.notifBudgetResetBody,
      scheduledDate: _nextInstanceOfMonthDay(1, hour: 9, minute: 0),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'budget_reminders',
          l10n.notifBudgetChannelName,
          largeIcon: _largeIcon,
          channelDescription: l10n.notifBudgetChannelDescription,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      // Inexact timing is fine for this nudge, same reasoning as the
      // journal reminders — avoids requiring SCHEDULE_EXACT_ALARM.
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
    );
  }

  /// Schedules a one-off notification 5 minutes from now, in the same
  /// exact/inexact mode a real task reminder would use. Wired to a button
  /// in Settings' debug section, for telling apart an app bug from an
  /// OS/device-level restriction (permission denied, a muted notification
  /// channel, OEM battery/autostart limits, Do Not Disturb, ...): if this
  /// one doesn't show either, the cause is outside this app entirely.
  ///
  /// Returns the time it's scheduled for, so the caller can tell the user
  /// exactly when to expect it.
  Future<DateTime> scheduleTestNotification() async {
    final scheduleMode = await _exactAlarmScheduleMode();
    final scheduledDate = tz.TZDateTime.now(
      tz.local,
    ).add(const Duration(minutes: 5));
    debugPrint(
      'NotificationService: scheduling test notification at '
      '$scheduledDate mode=$scheduleMode (now=${tz.TZDateTime.now(tz.local)})',
    );
    final l10n = currentL10n;
    await _plugin.zonedSchedule(
      id: debugTestNotificationId,
      title: l10n.notifTestTitle,
      body: l10n.notifTestBody,
      scheduledDate: scheduledDate,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'debug_test',
          l10n.notifDebugChannelName,
          largeIcon: _largeIcon,
          channelDescription: l10n.notifDebugChannelDescription,
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: scheduleMode,
    );
    return scheduledDate;
  }

  /// [AndroidScheduleMode.exactAllowWhileIdle] if the user has granted
  /// exact-alarm scheduling (requested in [initialize]), else
  /// [AndroidScheduleMode.inexactAllowWhileIdle] — better a reminder fires
  /// a little late than not at all, which is what happens if a reminder is
  /// scheduled exactly without this permission: `AlarmManager` throws, and
  /// since nothing else catches it, the sheet that triggered it never
  /// finishes saving.
  Future<AndroidScheduleMode> _exactAlarmScheduleMode() async {
    final canScheduleExact = await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.canScheduleExactNotifications();
    // Falling back to inexact is silent by design (see doc comment above),
    // but that silence is exactly what makes "reminders don't fire" hard to
    // diagnose — requestExactAlarmsPermission() only *opens* the system
    // settings screen, it doesn't grant anything, so this is false on every
    // device that hasn't had the "Alarms & reminders" toggle flipped by
    // hand. Log it so that's visible instead of guessed at.
    debugPrint(
      'NotificationService: canScheduleExactNotifications=$canScheduleExact',
    );
    return canScheduleExact ?? false
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;
  }

  /// Enables or disables the 8:00 AM "write in your journal" reminder.
  Future<void> setJournalMorningReminderEnabled(bool enabled) {
    return enabled
        ? _scheduleDaily(
            id: journalMorningReminderId,
            hour: 8,
            minute: 0,
            title: currentL10n.notifJournalMorningTitle,
            body: currentL10n.notifJournalMorningBody,
          )
        : _plugin.cancel(id: journalMorningReminderId);
  }

  /// Enables or disables the 10:00 PM "how was your day" reminder.
  Future<void> setJournalEveningReminderEnabled(bool enabled) {
    return enabled
        ? _scheduleDaily(
            id: journalEveningReminderId,
            hour: 22,
            minute: 0,
            title: currentL10n.notifJournalEveningTitle,
            body: currentL10n.notifJournalEveningBody,
          )
        : _plugin.cancel(id: journalEveningReminderId);
  }

  Future<void> _scheduleDaily({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) {
    return _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: _nextInstanceOf(hour, minute),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'journal_reminders',
          currentL10n.notifJournalChannelName,
          largeIcon: _largeIcon,
          channelDescription: currentL10n.notifJournalChannelDescription,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      // Inexact timing is fine for a journaling nudge and avoids requiring
      // the SCHEDULE_EXACT_ALARM permission on Android 12+.
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: journalPayload,
    );
  }

  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  /// The next occurrence of [day] of the month at [hour]:[minute] — rolls
  /// forward a month at a time, same as [_nextInstanceOf] rolls forward a
  /// day at a time.
  tz.TZDateTime _nextInstanceOfMonthDay(
    int day, {
    required int hour,
    required int minute,
  }) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = tz.TZDateTime(
        tz.local,
        now.year,
        now.month + 1,
        day,
        hour,
        minute,
      );
    }
    return scheduled;
  }

  /// Schedules a weekly reminder for [habit] on each of its
  /// [Habit.reminderDays], with an action button per [Habit.actions] (up to
  /// 3, per SPEC.md) — or a plain "Done" action if it has none. Tapping an
  /// action logs the completion directly, without opening the app; tapping
  /// the notification body opens the app (see [onNotificationTap]).
  ///
  /// Replaces any previously scheduled reminder for [habit]. No-ops (after
  /// clearing the old schedule) if it has no reminder time or days set.
  /// [habit]'s notification ids come from [_habitIdAllocator], keyed by
  /// [Habit.id] — stable across reschedules and app restarts, unlike its
  /// position in the habit list.
  Future<void> scheduleHabitReminder(Habit habit) async {
    await cancelHabitReminder(habit.id);

    final time = habit.reminderTime;
    if (time == null || habit.reminderDays.isEmpty) {
      return;
    }

    final details = _habitNotificationDetails(habit);
    final payload = jsonEncode({'habitId': habit.id});
    // Habit reminders are opt-in and time-sensitive enough to warrant exact
    // timing, unlike the journal nudges above — but only if the user's
    // granted it; see _exactAlarmScheduleMode.
    final scheduleMode = await _exactAlarmScheduleMode();
    final blockBase = _habitIdAllocator.idFor(habit.id);
    for (final specWeekday in habit.reminderDays) {
      final scheduledDate = _nextInstanceOfWeekday(specWeekday, time);
      debugPrint(
        'NotificationService: scheduling habit "${habit.name}" '
        'day=$specWeekday at $scheduledDate mode=$scheduleMode',
      );
      await _plugin.zonedSchedule(
        id: blockBase + specWeekday,
        title: habit.name,
        body: currentL10n.notifHabitBody(habit.name),
        scheduledDate: scheduledDate,
        notificationDetails: details,
        androidScheduleMode: scheduleMode,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        payload: payload,
      );
    }
  }

  /// Cancels every reminder scheduled for [habitId] — a no-op if it never
  /// had one. Keeps its reserved notification id block (the habit itself
  /// isn't gone) — use [forgetHabitReminder] when it is.
  Future<void> cancelHabitReminder(String habitId) async {
    final blockBase = _habitIdAllocator.existingIdFor(habitId);
    if (blockBase == null) {
      return;
    }
    for (var specWeekday = 0; specWeekday <= 6; specWeekday++) {
      await _plugin.cancel(id: blockBase + specWeekday);
    }
  }

  /// Cancels [habitId]'s reminder and frees its notification id block for
  /// reuse — call only once the habit itself is permanently deleted, not
  /// merely archived or edited (those should keep the same id if given a
  /// reminder again later; use [cancelHabitReminder] for those).
  Future<void> forgetHabitReminder(String habitId) async {
    await cancelHabitReminder(habitId);
    await _habitIdAllocator.release(habitId);
  }

  NotificationDetails _habitNotificationDetails(Habit habit) {
    final actions = habit.actions.isEmpty
        ? [AndroidNotificationAction(_doneActionId, currentL10n.commonDone)]
        : [
            for (final action in habit.actions.take(3))
              AndroidNotificationAction(action.id, action.label),
          ];
    return NotificationDetails(
      android: AndroidNotificationDetails(
        'habit_reminders',
        currentL10n.notifHabitChannelName,
        largeIcon: _largeIcon,
        channelDescription: currentL10n.notifHabitChannelDescription,
        importance: Importance.max,
        priority: Priority.high,
        actions: actions,
      ),
      // iOS registers a notification's actions through a fixed category set
      // up at `initialize` time, not per-notification — it can't show these
      // per-habit custom labels. iOS reminders fall back to a plain
      // notification; tapping it still opens the app to the habit.
      iOS: const DarwinNotificationDetails(),
    );
  }

  tz.TZDateTime _nextInstanceOfWeekday(int specWeekday, TimeOfDay time) {
    final dartWeekday = specWeekday + 1; // SPEC: 0=Mon..6=Sun; DateTime: 1-7
    var scheduled = _nextInstanceOf(time.hour, time.minute);
    while (scheduled.weekday != dartWeekday) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  /// Schedules [task]'s reminder at [Task.reminderAt], with a "Mark done"
  /// action that completes it directly, without opening the app; tapping
  /// the notification body opens the app to its detail screen (see
  /// [onNotificationTap]).
  ///
  /// Replaces any previously scheduled reminder for [task]. No-ops (after
  /// clearing the old schedule) if it has no reminder set. [task]'s
  /// notification id comes from [_taskIdAllocator], keyed by [Task.id] —
  /// stable across reschedules and app restarts, unlike its position in
  /// the task list.
  Future<void> scheduleTaskReminder(Task task) async {
    await cancelTaskReminder(task.id);

    final reminderAt = task.reminderAt;
    if (reminderAt == null) {
      return;
    }

    final scheduledDate = tz.TZDateTime.from(reminderAt, tz.local);
    final scheduleMode = await _exactAlarmScheduleMode();
    debugPrint(
      'NotificationService: scheduling task "${task.name}" at '
      '$scheduledDate mode=$scheduleMode '
      '(now=${tz.TZDateTime.now(tz.local)})',
    );
    await _plugin.zonedSchedule(
      id: _taskIdAllocator.idFor(task.id),
      title: task.name,
      body: task.name,
      scheduledDate: scheduledDate,
      notificationDetails: _taskNotificationDetails(),
      // Task reminders are opt-in and time-sensitive enough to warrant
      // exact timing, unlike the journal nudges above — but only if the
      // user's granted it; see _exactAlarmScheduleMode.
      androidScheduleMode: scheduleMode,
      payload: jsonEncode({'taskId': task.id}),
    );
  }

  /// Cancels the reminder scheduled for [taskId] — a no-op if it never had
  /// one. Keeps its reserved notification id (the task itself isn't gone)
  /// — use [forgetTaskReminder] when it is.
  Future<void> cancelTaskReminder(String taskId) async {
    final id = _taskIdAllocator.existingIdFor(taskId);
    if (id == null) {
      return;
    }
    await _plugin.cancel(id: id);
  }

  /// Cancels [taskId]'s reminder and frees its notification id for reuse —
  /// call only once the task itself is permanently deleted, not merely
  /// completed or edited (those should keep the same id if given a
  /// reminder again later; use [cancelTaskReminder] for those).
  Future<void> forgetTaskReminder(String taskId) async {
    await cancelTaskReminder(taskId);
    await _taskIdAllocator.release(taskId);
  }

  NotificationDetails _taskNotificationDetails() => NotificationDetails(
    android: AndroidNotificationDetails(
      'task_reminders',
      currentL10n.notifTaskChannelName,
      largeIcon: _largeIcon,
      channelDescription: currentL10n.notifTaskChannelDescription,
      importance: Importance.max,
      priority: Priority.high,
      actions: [
        AndroidNotificationAction(
          _taskMarkDoneActionId,
          currentL10n.notifTaskMarkDone,
        ),
      ],
    ),
    // See _habitNotificationDetails — iOS can't show per-notification
    // custom action labels, so the reminder falls back to a plain
    // notification; tapping it still opens the app to the task.
    iOS: const DarwinNotificationDetails(),
  );

  /// Shows (or updates) a silent, non-dismissible "analyzing" notification
  /// for a food scan in progress — [body] carries retry status once
  /// [AITab] starts auto-retrying a busy Gemini response. Reuses
  /// [foodScanNotificationId], so this replaces any food scan notification
  /// already showing rather than stacking a new one.
  Future<void> showFoodScanProgress(String body) => _showAiProgress(
    id: foodScanNotificationId,
    title: currentL10n.notifFoodScanProgressTitle,
    body: body,
    channelId: 'food_scan_progress',
    channelName: currentL10n.notifFoodScanProgressChannelName,
    channelDescription: currentL10n.notifFoodScanProgressChannelDescription,
  );

  /// Replaces the progress notification with a final failure, offering a
  /// "Retry" action — both it and tapping the notification body reopen the
  /// AI tab (see [foodScanPayload]); there's no way to safely resume the
  /// exact same photo across a killed-and-relaunched app, so retrying just
  /// means letting the user scan again.
  Future<void> showFoodScanFailed(String message) => _showAiFailed(
    id: foodScanNotificationId,
    title: currentL10n.notifFoodScanFailedTitle,
    body: message,
    channelId: 'food_scan_result',
    channelName: currentL10n.notifFoodScanResultChannelName,
    channelDescription: currentL10n.notifFoodScanResultChannelDescription,
    retryActionId: _foodScanRetryActionId,
    payload: foodScanPayload,
  );

  /// Clears the food scan notification — called once a scan finally
  /// succeeds or the caller is about to show its own failure UI instead.
  Future<void> cancelFoodScanNotification() =>
      _plugin.cancel(id: foodScanNotificationId);

  /// Same as [showFoodScanProgress], for a money advice request — its own
  /// id and channel, so it never replaces a food scan's notification.
  Future<void> showMoneyAdviceProgress(String body) => _showAiProgress(
    id: moneyAdviceNotificationId,
    title: currentL10n.notifMoneyAdviceProgressTitle,
    body: body,
    channelId: 'money_advice_progress',
    channelName: currentL10n.notifMoneyAdviceProgressChannelName,
    channelDescription: currentL10n.notifMoneyAdviceProgressChannelDescription,
  );

  /// Same as [showFoodScanFailed], for a money advice request — both the
  /// body and "Retry" reopen the Money tab (see [moneyAdvicePayload]).
  Future<void> showMoneyAdviceFailed(String message) => _showAiFailed(
    id: moneyAdviceNotificationId,
    title: currentL10n.notifMoneyAdviceFailedTitle,
    body: message,
    channelId: 'money_advice_result',
    channelName: currentL10n.notifMoneyAdviceResultChannelName,
    channelDescription: currentL10n.notifMoneyAdviceResultChannelDescription,
    retryActionId: _moneyAdviceRetryActionId,
    payload: moneyAdvicePayload,
  );

  /// Clears the money advice notification.
  Future<void> cancelMoneyAdviceNotification() =>
      _plugin.cancel(id: moneyAdviceNotificationId);

  Future<void> _showAiProgress({
    required int id,
    required String title,
    required String body,
    required String channelId,
    required String channelName,
    required String channelDescription,
  }) => _plugin.show(
    id: id,
    title: title,
    body: body,
    notificationDetails: NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        largeIcon: _largeIcon,
        channelDescription: channelDescription,
        ongoing: true,
        autoCancel: false,
        showProgress: true,
        indeterminate: true,
        importance: Importance.low,
        priority: Priority.low,
        playSound: false,
      ),
      iOS: const DarwinNotificationDetails(presentSound: false),
    ),
  );

  Future<void> _showAiFailed({
    required int id,
    required String title,
    required String body,
    required String channelId,
    required String channelName,
    required String channelDescription,
    required String retryActionId,
    required String payload,
  }) => _plugin.show(
    id: id,
    title: title,
    body: body,
    notificationDetails: NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        largeIcon: _largeIcon,
        channelDescription: channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        actions: [
          AndroidNotificationAction(
            retryActionId,
            currentL10n.commonRetry,
            showsUserInterface: true,
          ),
        ],
      ),
      iOS: const DarwinNotificationDetails(),
    ),
    payload: payload,
  );

  void dispose() {
    _tapController.close();
  }
}

/// Handles a habit or task notification action button tap. Runs on a
/// background isolate with no access to the app's Riverpod container, so it
/// can't reuse [HabitRepository]/[TaskRepository] — it duplicates just
/// enough of their cache formats to write an update the app picks up next
/// time it reads the cache.
@pragma('vm:entry-point')
void _handleBackgroundNotificationResponse(NotificationResponse response) {
  final actionId = response.actionId;
  final payload = response.payload;
  if (actionId == null || payload == null) {
    return;
  }
  final decoded = jsonDecode(payload) as Map<String, dynamic>;
  if (decoded['taskId'] case final String taskId) {
    unawaited(_markTaskComplete(taskId));
  } else if (decoded['habitId'] case final String _) {
    unawaited(_logHabitCompletion(actionId: actionId, payload: payload));
  }
}

/// Marks the cached task [taskId] complete, preserving its other fields.
/// A no-op if it isn't cached. Doesn't touch its sync status, the same way
/// [_logHabitCompletion] leaves its writes — background completions sync
/// to Supabase on the app's next open, best-effort.
Future<void> _markTaskComplete(String taskId) async {
  await Hive.initFlutter();
  final box = await Hive.openBox<dynamic>('tasks');
  final cached = box.get(taskId);
  if (cached != null) {
    final task = Map<String, dynamic>.from(
      jsonDecode(jsonEncode(cached)) as Map,
    );
    task['is_completed'] = true;
    await box.put(taskId, task);
  }
  await box.close();
}

Future<void> _logHabitCompletion({
  required String actionId,
  required String payload,
}) async {
  final habitId =
      (jsonDecode(payload) as Map<String, dynamic>)['habitId'] as String;
  final completedActionId = actionId == _doneActionId ? null : actionId;

  await Hive.initFlutter();
  final box = await Hive.openBox<dynamic>('habit_logs');
  final today = DateTime.now();
  final day = DateTime(today.year, today.month, today.day);
  await box.put('${habitId}_${day.toIso8601String()}', {
    'habitId': habitId,
    'date': day.toIso8601String(),
    'completedActionId': completedActionId,
    'note': null,
  });
  await box.close();
}

@Riverpod(keepAlive: true)
Future<NotificationService> notificationService(Ref ref) async {
  final service = NotificationService(
    taskIdAllocator: await _openIdAllocator(
      boxName: 'task_notification_ids',
      base: NotificationService.taskIdBase,
      slotCount: NotificationService.taskIdSlotCount,
    ),
    habitIdAllocator: await _openIdAllocator(
      boxName: 'habit_notification_ids',
      base: NotificationService.habitIdBase,
      slotCount: NotificationService.habitIdSlotCount,
      blockSize: NotificationService.habitIdBlockSize,
    ),
  );
  await service.initialize();
  ref.onDispose(service.dispose);
  return service;
}

/// A [NotificationIdAllocator] backed by the Hive box named [boxName], so
/// its ids persist across app restarts — or, if that box can't be opened
/// (e.g. Hive itself was never initialized, as in a bare widget test), an
/// in-memory one instead of failing [notificationServiceProvider]
/// altogether. Reminders scheduled under the fallback just won't keep
/// their ids past this session — still better than not scheduling at all.
Future<NotificationIdAllocator> _openIdAllocator({
  required String boxName,
  required int base,
  required int slotCount,
  int blockSize = 1,
}) async {
  try {
    final box = await Hive.openBox<int>(boxName);
    return NotificationIdAllocator(
      HiveNotificationIdStore(box),
      base: base,
      slotCount: slotCount,
      blockSize: blockSize,
    );
  } catch (error) {
    debugPrint(
      'NotificationService: could not open Hive box "$boxName" — '
      'notification ids will not persist across restarts this session: '
      '$error',
    );
    return NotificationIdAllocator(
      InMemoryNotificationIdStore(),
      base: base,
      slotCount: slotCount,
      blockSize: blockSize,
    );
  }
}

/// Payloads of tapped notifications, forwarded from [notificationServiceProvider].
@riverpod
Stream<String?> notificationTap(Ref ref) async* {
  final service = await ref.watch(notificationServiceProvider.future);
  yield* service.onNotificationTap;
}
