import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/core/theme/glass_style.dart';
import 'package:mindful/core/theme/glass_style_scope.dart';

void main() {
  test('reads back what was stored', () {
    for (final style in GlassStyle.values) {
      expect(GlassStyle.fromStorage(style.name), style);
    }
  });

  test('unset or unknown means liquid', () {
    expect(GlassStyle.fromStorage(null), GlassStyle.liquid);
    expect(GlassStyle.fromStorage('glossy'), GlassStyle.liquid);
  });

  testWidgets('with no scope, widgets draw liquid glass', (tester) async {
    late GlassStyle seen;
    await tester.pumpWidget(
      Builder(
        builder: (context) {
          seen = GlassStyleScope.of(context);
          return const SizedBox.shrink();
        },
      ),
    );
    expect(seen, GlassStyle.liquid);
  });

  testWidgets('the scope hands its style down', (tester) async {
    late GlassStyle seen;
    await tester.pumpWidget(
      GlassStyleScope(
        style: GlassStyle.frosted,
        child: Builder(
          builder: (context) {
            seen = GlassStyleScope.of(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    expect(seen, GlassStyle.frosted);
  });
}
