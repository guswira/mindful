import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/shared/services/ai_activity.dart';

void main() {
  late ProviderContainer container;
  late AiActivityController controller;

  setUp(() {
    container = ProviderContainer();
    controller = container.read(aiActivityProvider.notifier);
  });

  tearDown(() => container.dispose());

  List<AiActivity> state() => container.read(aiActivityProvider);

  test('start tracks a running request on its first attempt', () {
    final id = controller.start(AiActivityKind.foodScan);

    final activity = state().single;
    expect(activity.id, id);
    expect(activity.attempt, 1);
    expect(activity.isReady, isFalse);
  });

  test('retrying updates the attempt count', () {
    final id = controller.start(AiActivityKind.moneyAdvice);
    controller.retrying(id, 3, 5);

    expect(state().single.attempt, 3);
    expect(state().single.maxAttempts, 5);
  });

  test('opening a ready result removes it, then runs it', () {
    final id = controller.start(AiActivityKind.foodScan);
    var opened = 0;
    controller.ready(id, () => opened++);

    expect(state().single.isReady, isTrue);
    state().single.open!();

    expect(opened, 1);
    expect(state(), isEmpty);
  });

  test('a new request replaces an unopened one of the same kind only', () {
    final oldScan = controller.start(AiActivityKind.foodScan);
    controller.ready(oldScan, () {});
    controller.start(AiActivityKind.moneyAdvice);
    final newScan = controller.start(AiActivityKind.foodScan);

    expect(state().map((a) => a.kind), [
      AiActivityKind.moneyAdvice,
      AiActivityKind.foodScan,
    ]);
    expect(state().last.id, newScan);
  });

  test('finish stops showing a request', () {
    final id = controller.start(AiActivityKind.foodScan);
    controller.finish(id);

    expect(state(), isEmpty);
  });
}
