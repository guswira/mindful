import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:mindfull/app.dart';

void main() {
  // The full App now reads task/habit repositories unconditionally at
  // router-build time (see router.dart's reminder reconciliation), which
  // opens real Hive boxes — Hive.init needs a real path, not path_provider
  // (unavailable under plain flutter_test), hence a plain temp dir.
  late Directory hiveDir;

  setUp(() async {
    hiveDir = await Directory.systemTemp.createTemp('mindfull_test_hive');
    Hive.init(hiveDir.path);
  });

  tearDown(() async {
    await Hive.close();
    await hiveDir.delete(recursive: true);
  });

  testWidgets('App launches to a blank splash screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: App()));
    await tester.pumpAndSettle();

    expect(find.byType(Scaffold), findsOneWidget);
  });
}
