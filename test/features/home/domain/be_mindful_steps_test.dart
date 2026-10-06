import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/features/home/domain/be_mindful_steps.dart';

Map<BeMindfulStep, BeMindfulStepStatus> _all(BeMindfulStepStatus status) => {
  for (final step in BeMindfulStep.values) step: status,
};

void main() {
  test('a new user is offered the first two steps', () {
    final progress = beMindfulProgress(_all(BeMindfulStepStatus.todo));

    expect(progress.shown, [BeMindfulStep.routine, BeMindfulStep.spending]);
    expect(progress.done, 0);
  });

  test('a done step makes room for the next one', () {
    final progress = beMindfulProgress({
      ..._all(BeMindfulStepStatus.todo),
      BeMindfulStep.routine: BeMindfulStepStatus.done,
      BeMindfulStep.spending: BeMindfulStepStatus.done,
      BeMindfulStep.task: BeMindfulStepStatus.done,
    });

    expect(progress.shown, [BeMindfulStep.foodScan, BeMindfulStep.breathing]);
    expect(progress.done, 3);
  });

  test('a loading step holds back the steps after it', () {
    final progress = beMindfulProgress({
      ..._all(BeMindfulStepStatus.todo),
      BeMindfulStep.spending: BeMindfulStepStatus.loading,
    });

    expect(progress.shown, [BeMindfulStep.routine]);
  });

  test('a step that failed to load is skipped', () {
    final progress = beMindfulProgress({
      ..._all(BeMindfulStepStatus.done),
      BeMindfulStep.foodScan: BeMindfulStepStatus.unknown,
      BeMindfulStep.budget: BeMindfulStepStatus.todo,
    });

    expect(progress.shown, [BeMindfulStep.budget]);
    expect(progress.done, 5);
  });

  test('nothing is shown once every step is done', () {
    final progress = beMindfulProgress(_all(BeMindfulStepStatus.done));

    expect(progress.shown, isEmpty);
    expect(progress.done, BeMindfulStep.values.length);
  });
}
