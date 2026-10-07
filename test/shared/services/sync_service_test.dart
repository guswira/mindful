import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/shared/services/sync_service.dart';

void main() {
  late DateTime now;
  late List<String> calls;

  setUp(() {
    now = DateTime(2026, 1, 1, 8);
    calls = <String>[];
  });

  SyncService buildService() {
    return SyncService(
      pull: [() async => calls.add('pull')],
      retryPending: [() async => calls.add('retry')],
      updateWidgetData: () async => calls.add('widget'),
      now: () => now,
    );
  }

  test(
    'retries pending writes, pulls fresh data, then refreshes widgets',
    () async {
      await buildService().syncOnOpen();

      expect(calls, ['retry', 'pull', 'widget']);
    },
  );

  test('skips a second sync started under 5 minutes later', () async {
    final service = buildService();
    await service.syncOnOpen();
    calls.clear();

    now = now.add(const Duration(minutes: 4));
    await service.syncOnOpen();

    expect(calls, isEmpty);
  });

  test('syncs again once 5 minutes have passed', () async {
    final service = buildService();
    await service.syncOnOpen();
    calls.clear();

    now = now.add(const Duration(minutes: 5, seconds: 1));
    await service.syncOnOpen();

    expect(calls, ['retry', 'pull', 'widget']);
  });

  test(
    'still refreshes widgets from the local cache when a pull fails',
    () async {
      final service = SyncService(
        pull: [() async => throw Exception('no network')],
        retryPending: [() async => calls.add('retry')],
        updateWidgetData: () async => calls.add('widget'),
        now: () => now,
      );

      await service.syncOnOpen();

      expect(calls, ['retry', 'widget']);
    },
  );

  test(
    'one failing table never keeps the tables after it from syncing',
    () async {
      final service = SyncService(
        pull: [
          () async => calls.add('journal'),
          () async => throw Exception('habits failed'),
          () async => calls.add('money'),
        ],
        retryPending: [
          () async => throw Exception('retry failed'),
          () async => calls.add('retry tasks'),
        ],
        updateWidgetData: () async => calls.add('widget'),
        now: () => now,
      );

      await service.syncOnOpen();

      expect(calls, ['retry tasks', 'journal', 'money', 'widget']);
    },
  );
}
