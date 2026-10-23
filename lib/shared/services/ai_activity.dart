import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Which AI request an [AiActivity] tracks.
enum AiActivityKind { foodScan, moneyAdvice }

/// One AI request the app-wide indicator (AiActivityIndicator) is showing —
/// running (possibly retrying), or finished and waiting for the user to
/// open its result.
class AiActivity {
  const AiActivity({
    required this.id,
    required this.kind,
    this.attempt = 1,
    this.maxAttempts = 1,
    this.open,
  });

  final int id;
  final AiActivityKind kind;

  /// 1 on the first try; higher once Gemini was busy or slow and it's
  /// retrying.
  final int attempt;

  /// How many tries the request gets in total.
  final int maxAttempts;

  /// Shows the result. Non-null once the request has finished — the
  /// indicator then turns into a "ready, tap to view" pill instead of
  /// popping a sheet over whatever the user is doing.
  final void Function()? open;

  /// Whether the result is waiting for the user.
  bool get isReady => open != null;

  AiActivity _copyWith({
    int? attempt,
    int? maxAttempts,
    void Function()? open,
  }) => AiActivity(
    id: id,
    kind: kind,
    attempt: attempt ?? this.attempt,
    maxAttempts: maxAttempts ?? this.maxAttempts,
    open: open ?? this.open,
  );
}

/// The AI requests in flight or waiting to be opened, oldest first, so
/// they can be shown without blocking the app — see SPEC.md AI activity
/// indicator.
///
/// Hand-written rather than @Riverpod: riverpod_generator's analyzer 7
/// crashes on the current SDK's syntax (see SPEC.md Stack decisions).
class AiActivityController extends Notifier<List<AiActivity>> {
  var _nextId = 0;

  @override
  List<AiActivity> build() => const [];

  /// Tracks a new request of [kind] and returns its id. Replaces any
  /// unopened result of the same kind — the new request supersedes it.
  int start(AiActivityKind kind) {
    final id = _nextId++;
    state = [
      for (final activity in state)
        if (activity.kind != kind) activity,
      AiActivity(id: id, kind: kind),
    ];
    return id;
  }

  /// Marks request [id] as on its [attempt]th try of [maxAttempts].
  void retrying(int id, int attempt, int maxAttempts) => _update(
    id,
    (activity) =>
        activity._copyWith(attempt: attempt, maxAttempts: maxAttempts),
  );

  /// Marks request [id] finished; tapping it calls [open] (once — the
  /// activity is removed first).
  void ready(int id, void Function() open) => _update(
    id,
    (activity) => activity._copyWith(
      open: () {
        finish(id);
        open();
      },
    ),
  );

  /// Stops showing request [id] — it failed, or its result was opened or
  /// dismissed.
  void finish(int id) => state = [
    for (final activity in state)
      if (activity.id != id) activity,
  ];

  void _update(int id, AiActivity Function(AiActivity) change) => state = [
    for (final activity in state)
      if (activity.id == id) change(activity) else activity,
  ];
}

/// The app-wide [AiActivityController].
final aiActivityProvider =
    NotifierProvider<AiActivityController, List<AiActivity>>(
      AiActivityController.new,
    );
