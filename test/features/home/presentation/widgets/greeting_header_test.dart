import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindfull/core/theme/glass_theme.dart';
import 'package:mindfull/features/home/presentation/widgets/greeting_header.dart';

void main() {
  group('greetingFor', () {
    test('is "Good morning" before noon', () {
      expect(greetingFor(const TimeOfDay(hour: 6, minute: 0)), 'Good morning');
      expect(
        greetingFor(const TimeOfDay(hour: 11, minute: 59)),
        'Good morning',
      );
    });

    test('is "Good afternoon" from noon to before 5pm', () {
      expect(
        greetingFor(const TimeOfDay(hour: 12, minute: 0)),
        'Good afternoon',
      );
      expect(
        greetingFor(const TimeOfDay(hour: 16, minute: 59)),
        'Good afternoon',
      );
    });

    test('is "Good evening" from 5pm', () {
      expect(greetingFor(const TimeOfDay(hour: 17, minute: 0)), 'Good evening');
      expect(greetingFor(const TimeOfDay(hour: 23, minute: 0)), 'Good evening');
    });
  });

  group('firstNameFrom', () {
    test('prefers full_name, taking just the first word', () {
      expect(
        firstNameFrom(
          metadata: {'full_name': 'Ada Lovelace'},
          email: 'a@b.com',
        ),
        'Ada',
      );
    });

    test('falls back to name', () {
      expect(
        firstNameFrom(metadata: {'name': 'Grace'}, email: 'a@b.com'),
        'Grace',
      );
    });

    test('falls back to the email local part with no metadata', () {
      expect(firstNameFrom(metadata: null, email: 'ada@example.com'), 'ada');
    });

    test('is null with neither metadata nor email', () {
      expect(firstNameFrom(metadata: null, email: null), isNull);
    });
  });

  testWidgets('shows a time-based greeting for a signed-out user', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: ThemeData(extensions: [GlassTheme.dark()]),
          home: const Scaffold(body: GreetingHeader()),
        ),
      ),
    );
    await tester.pump();

    final greeting = greetingFor(TimeOfDay.now());
    expect(find.textContaining(greeting), findsOneWidget);
  });
}
