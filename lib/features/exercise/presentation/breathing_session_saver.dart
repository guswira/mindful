import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/l10n/l10n.dart';
import '../../auth/domain/auth_state.dart';
import '../data/breathing_session_repository.dart';
import '../domain/breathing_exercise.dart';
import '../domain/breathing_session.dart';
import 'breathing_labels.dart';
import 'breathing_session_controller.dart';
import 'exercise_providers.dart';

/// Saves a finished session and reports the outcome in a SnackBar.
///
/// Holds the [ProviderContainer] and [ScaffoldMessenger] rather than the
/// session screen's context, since the screen pops before the save (which
/// waits on Supabase) completes.
class BreathingSessionSaver {
  BreathingSessionSaver._({
    required ProviderContainer container,
    required ScaffoldMessengerState messenger,
    required AppLocalizations l10n,
  }) : _container = container,
       _messenger = messenger,
       _l10n = l10n;

  /// Captures what [save] needs from [context] while it's still mounted.
  factory BreathingSessionSaver.of(BuildContext context) =>
      BreathingSessionSaver._(
        container: ProviderScope.containerOf(context, listen: false),
        messenger: ScaffoldMessenger.of(context),
        l10n: context.l10n,
      );

  /// Shorter sessions (an accidental Start, say) aren't worth a calendar
  /// dot or a history row.
  static const Duration minDuration = Duration(seconds: 10);

  final ProviderContainer _container;
  final ScaffoldMessengerState _messenger;
  final AppLocalizations _l10n;

  Future<void> save(
    BreathingExercise exercise,
    BreathingSessionResult result,
  ) async {
    if (result.duration < minDuration) {
      _show(_l10n.breathingSessionTooShort);
      return;
    }
    try {
      final repository = await _container.read(
        breathingSessionRepositoryProvider.future,
      );
      await repository.saveSession(
        BreathingSession(
          id: const Uuid().v4(),
          userId: _container.read(currentUserIdProvider),
          exercise: exercise,
          startedAt: result.startedAt.toUtc(),
          durationSeconds: result.duration.inSeconds,
          cycles: result.cycles,
          bestHoldSeconds: result.bestHold?.inSeconds,
          createdAt: DateTime.now().toUtc(),
        ),
      );
      _container.invalidate(breathingSessionsProvider);
      _show(
        _l10n.breathingSessionSaved(
          _l10n.exerciseDuration(result.duration),
          result.cycles,
        ),
      );
    } catch (error) {
      debugPrint('Saving breathing session failed: $error');
      _show(_l10n.breathingSaveError('$error'));
    }
  }

  void _show(String message) =>
      _messenger.showSnackBar(SnackBar(content: Text(message)));
}
