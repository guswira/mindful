import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../shared/widgets/blob_background.dart';
import '../../../shared/widgets/glass_bottom_sheet.dart';
import '../data/ambience_player.dart';
import '../data/breathing_voice.dart';
import '../data/keep_screen_on.dart';
import '../domain/breathing_exercise.dart';
import '../domain/breathing_pattern.dart';
import '../domain/breathing_preferences.dart';
import 'breathing_labels.dart';
import 'breathing_session_controller.dart';
import 'breathing_session_saver.dart';
import 'exercise_providers.dart';
import 'sound_settings_sheet.dart';
import 'widgets/breathing_circle.dart';
import 'widgets/session_controls.dart';
import 'widgets/session_stats_row.dart';
import 'widgets/session_top_bar.dart';

/// Full-page breathing session (`/exercise/breathing/:exercise`): the
/// breathing circle, elapsed time + cycles, and Start/Pause/Finish. See
/// SPEC.md Exercise.
///
/// Leaving by any route (back button, system back, Finish) ends the
/// session and saves it; hiding the app pauses it.
class BreathingSessionScreen extends ConsumerStatefulWidget {
  const BreathingSessionScreen({required this.exercise, super.key});

  final BreathingExercise exercise;

  @override
  ConsumerState<BreathingSessionScreen> createState() =>
      _BreathingSessionScreenState();
}

class _BreathingSessionScreenState extends ConsumerState<BreathingSessionScreen>
    with SingleTickerProviderStateMixin {
  BreathingSessionController? _controller;
  late final AppLifecycleListener _lifecycle;
  bool _finishing = false;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onHide: () => _controller?.pause());
    // The Customize pattern comes from the saved preferences, so the
    // controller can't be built until they've loaded.
    ref.read(breathingPreferencesControllerProvider.future).then((prefs) {
      if (mounted) setState(() => _controller = _createController(prefs));
    });
    ref.listenManual(breathingPreferencesControllerProvider, (_, next) {
      if (next.valueOrNull case final prefs?) {
        _controller?.applyPreferences(prefs);
      }
    });
  }

  BreathingSessionController _createController(BreathingPreferences prefs) {
    final l10n = context.l10n;
    return BreathingSessionController(
      vsync: this,
      pattern: BreathingPattern.forExercise(widget.exercise, prefs.custom),
      preferences: prefs,
      phaseWord: (type) => l10n.phaseWord(type),
      voice: ref.read(breathingVoiceProvider),
      ambience: ref.read(ambiencePlayerProvider),
      keepScreenOn: ref.read(keepScreenOnProvider),
    );
  }

  Future<void> _finish() async {
    if (_finishing) return;
    _finishing = true;
    final result = _controller?.finish();
    final saver = BreathingSessionSaver.of(context);
    Navigator.of(context).pop();
    if (result != null) {
      await saver.save(widget.exercise, result);
    }
  }

  void _openSoundSettings() => showGlassBottomSheet<void>(
    context: context,
    builder: (_) => const SoundSettingsSheet(),
  );

  @override
  void dispose() {
    _lifecycle.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final l10n = context.l10n;
    final controller = _controller;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _finish();
      },
      child: Scaffold(
        backgroundColor: glass.background,
        body: RepaintBoundary(
          child: BlobBackground(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, Spacing.md),
                child: Column(
                  children: [
                    SessionTopBar(
                      title: l10n.exerciseName(widget.exercise),
                      subtitle: controller == null
                          ? ''
                          : l10n.patternSummary(controller.engine.pattern),
                      onBack: _finish,
                      onSound: _openSoundSettings,
                    ),
                    Expanded(
                      child: controller == null
                          ? const Center(child: CircularProgressIndicator())
                          : BreathingCircle(controller: controller),
                    ),
                    if (controller != null) ...[
                      SessionStatsRow(controller: controller),
                      const SizedBox(height: Spacing.md),
                      SessionControls(
                        controller: controller,
                        onFinish: _finish,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
