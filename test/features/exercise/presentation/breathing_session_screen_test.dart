import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/core/theme/glass_theme.dart';
import 'package:mindful/features/auth/domain/auth_state.dart';
import 'package:mindful/features/exercise/data/ambience_player.dart';
import 'package:mindful/features/exercise/data/breathing_preferences_repository.dart';
import 'package:mindful/features/exercise/data/breathing_session_repository.dart';
import 'package:mindful/features/exercise/data/breathing_voice.dart';
import 'package:mindful/features/exercise/data/keep_screen_on.dart';
import 'package:mindful/features/exercise/domain/breathing_exercise.dart';
import 'package:mindful/features/exercise/domain/breathing_preferences.dart';
import 'package:mindful/features/exercise/presentation/breathing_session_screen.dart';
import 'package:mindful/features/exercise/presentation/widgets/session_stats_row.dart';

import '../exercise_fakes.dart';

void main() {
  late FakeVoice voice;
  late FakeAmbience ambience;
  late FakeKeepScreenOn keepScreenOn;
  late FakeBox box;

  setUp(() {
    voice = FakeVoice();
    ambience = FakeAmbience();
    keepScreenOn = FakeKeepScreenOn();
    box = FakeBox();
  });

  /// A home page with an "open" button that pushes the session screen, so
  /// Finish has somewhere to pop back to.
  Widget buildApp(BreathingExercise exercise) => ProviderScope(
    overrides: [
      breathingPreferencesRepositoryProvider.overrideWithValue(
        FakePreferencesRepository(const BreathingPreferences()),
      ),
      breathingVoiceProvider.overrideWithValue(voice),
      ambiencePlayerProvider.overrideWithValue(ambience),
      keepScreenOnProvider.overrideWithValue(keepScreenOn),
      breathingSessionRepositoryProvider.overrideWith(
        (ref) async => BreathingSessionRepository(
          box: box,
          datasource: FakeBreathingDatasource(),
        ),
      ),
      currentUserIdProvider.overrideWithValue('u1'),
    ],
    child: MaterialApp(
      theme: ThemeData(extensions: [GlassTheme.dark()]),
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => BreathingSessionScreen(exercise: exercise),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );

  Future<void> openSession(WidgetTester tester, BreathingExercise e) async {
    await tester.pumpWidget(buildApp(e));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Finder statValue(String value) => find.descendant(
    of: find.byType(SessionStatsRow),
    matching: find.text(value),
  );

  testWidgets('Start runs the pattern, speaking each step', (tester) async {
    await openSession(tester, BreathingExercise.equal);
    expect(find.text("Tap Start when you're ready"), findsOneWidget);

    await tester.tap(find.text('Start'));
    await tester.pump();
    expect(find.text('Inhale'), findsOneWidget);
    expect(voice.spoken, ['Inhale']);
    expect(ambience.playing, AmbienceTrack.rain);
    expect(keepScreenOn.enabled, isTrue);

    await tester.pump(const Duration(seconds: 4));
    expect(find.text('Release'), findsOneWidget);
    expect(voice.spoken.last, 'Release');

    await tester.pump(const Duration(seconds: 4));
    expect(statValue('00:08'), findsOneWidget);
    expect(statValue('1'), findsOneWidget);
  });

  testWidgets('Pause stops the clock and the ambience', (tester) async {
    await openSession(tester, BreathingExercise.box);
    await tester.tap(find.text('Start'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    await tester.tap(find.text('Pause'));
    await tester.pump(const Duration(seconds: 30));

    expect(find.text('Paused'), findsOneWidget);
    expect(find.text('Resume'), findsOneWidget);
    expect(statValue('00:02'), findsOneWidget);
    expect(keepScreenOn.enabled, isFalse);
  });

  testWidgets('the hold test waits for Release and tracks the best hold', (
    tester,
  ) async {
    await openSession(tester, BreathingExercise.holdTest);
    await tester.tap(find.text('Start'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(seconds: 42));

    expect(find.text('Hold'), findsOneWidget);
    await tester.tap(find.text('Release'));
    await tester.pump();

    expect(voice.spoken.last, 'Release');
    expect(statValue('00:42'), findsOneWidget);
  });

  testWidgets('Finish saves the session and returns with a SnackBar', (
    tester,
  ) async {
    await openSession(tester, BreathingExercise.equal);
    await tester.tap(find.text('Start'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 16));

    await tester.tap(find.text('Finish'));
    await tester.pumpAndSettle();

    expect(find.byType(BreathingSessionScreen), findsNothing);
    expect(find.text('Session saved · 16s · 2 cycles'), findsOneWidget);
    expect(box.data, hasLength(1));
    expect(ambience.playing, isNull);
  });

  testWidgets('a session under 10 seconds is not saved', (tester) async {
    await openSession(tester, BreathingExercise.equal);
    await tester.tap(find.text('Start'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));

    await tester.tap(find.text('Finish'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Too short to save'), findsOneWidget);
    expect(box.data, isEmpty);
  });
}
