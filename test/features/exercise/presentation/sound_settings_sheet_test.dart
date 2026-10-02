import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/core/theme/glass_theme.dart';
import 'package:mindful/features/exercise/data/breathing_preferences_repository.dart';
import 'package:mindful/features/exercise/domain/breathing_preferences.dart';
import 'package:mindful/features/exercise/presentation/sound_settings_sheet.dart';

import '../exercise_fakes.dart';

void main() {
  late FakePreferencesRepository preferences;

  setUp(() => preferences = FakePreferencesRepository());

  Widget buildSheet() => ProviderScope(
    overrides: [
      breathingPreferencesRepositoryProvider.overrideWithValue(preferences),
    ],
    child: MaterialApp(
      theme: ThemeData(extensions: [GlassTheme.dark()]),
      home: const Scaffold(body: SoundSettingsSheet()),
    ),
  );

  testWidgets('toggling the voice guide persists it', (tester) async {
    await tester.pumpWidget(buildSheet());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(preferences.stored.voiceEnabled, isTrue);
  });

  testWidgets('picking an ambience persists it; Off disables its volume', (
    tester,
  ) async {
    await tester.pumpWidget(buildSheet());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ocean'));
    await tester.pumpAndSettle();
    expect(preferences.stored.ambience, AmbienceTrack.ocean);

    await tester.tap(find.text('Off'));
    await tester.pumpAndSettle();
    expect(preferences.stored.ambience, AmbienceTrack.none);
    final sliders = tester.widgetList<Slider>(find.byType(Slider));
    expect(sliders.every((slider) => slider.onChanged == null), isTrue);
  });
}
