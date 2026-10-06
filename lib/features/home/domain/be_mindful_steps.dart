/// One feature the home "Be mindful" section walks a new user through, in
/// the order they're offered.
enum BeMindfulStep {
  routine,
  spending,
  task,
  foodScan,
  breathing,
  journal,
  budget,
}

/// Whether the user has tried a [BeMindfulStep] yet.
enum BeMindfulStepStatus {
  /// Tried — never shown again.
  done,

  /// Not tried yet — offered when its turn comes.
  todo,

  /// Its data is still loading.
  loading,

  /// Its data couldn't load (e.g. food scans offline) — skipped rather
  /// than blocking the steps after it.
  unknown,
}

/// What the section shows: the next [BeMindfulStep]s to offer and how many
/// steps are done out of [BeMindfulStep.values].
typedef BeMindfulProgress = ({List<BeMindfulStep> shown, int done});

/// The first [max] not-yet-tried steps, in order. A step still loading
/// holds back every step after it, so rows don't appear and then get
/// pushed aside once the earlier step's data arrives.
BeMindfulProgress beMindfulProgress(
  Map<BeMindfulStep, BeMindfulStepStatus> statuses, {
  int max = 2,
}) {
  final shown = <BeMindfulStep>[];
  var done = 0;
  var held = false;
  for (final step in BeMindfulStep.values) {
    switch (statuses[step] ?? BeMindfulStepStatus.loading) {
      case BeMindfulStepStatus.done:
        done++;
      case BeMindfulStepStatus.todo:
        if (!held && shown.length < max) shown.add(step);
      case BeMindfulStepStatus.loading:
        held = true;
      case BeMindfulStepStatus.unknown:
        break;
    }
  }
  return (shown: shown, done: done);
}
