import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/features/exercise/data/breathing_session_repository.dart';
import 'package:mindful/shared/models/sync_status.dart';

import '../exercise_fakes.dart';

void main() {
  late FakeBox box;
  late FakeBreathingDatasource datasource;
  late BreathingSessionRepository repository;

  setUp(() {
    box = FakeBox();
    datasource = FakeBreathingDatasource();
    repository = BreathingSessionRepository(box: box, datasource: datasource);
  });

  test('getSessions is newest first', () async {
    await repository.saveSession(
      testSession(id: 'old', startedAt: DateTime.utc(2026, 1, 1)),
    );
    await repository.saveSession(
      testSession(id: 'new', startedAt: DateTime.utc(2026, 2, 1)),
    );

    expect(repository.getSessions().map((s) => s.id), ['new', 'old']);
  });

  test('a failed sync stays cached as pending and is retried', () async {
    datasource.failing = true;
    await repository.saveSession(
      testSession(id: 'a', startedAt: DateTime.utc(2026, 1, 1)),
    );

    expect(repository.getSessions().single.syncStatus, SyncStatus.pending);

    datasource.failing = false;
    await repository.retryPendingSessions();

    expect(repository.getSessions().single.syncStatus, SyncStatus.synced);
    expect(datasource.saved.single.id, 'a');
  });

  test('refresh replaces the cache but keeps unsynced sessions', () async {
    datasource.failing = true;
    await repository.saveSession(
      testSession(id: 'local', startedAt: DateTime.utc(2026, 1, 2)),
    );
    datasource
      ..failing = false
      ..remote = [testSession(id: 'remote', startedAt: DateTime.utc(2026))];

    await repository.refresh();

    expect(repository.getSessions().map((s) => s.id), ['local', 'remote']);
  });
}
