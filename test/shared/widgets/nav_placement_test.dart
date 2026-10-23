import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/shared/widgets/nav_placement.dart';

void main() {
  NavPlacement resolve(
    TargetPlatform platform,
    Size size, {
    bool hasVerticalBar = false,
    bool splitByHinge = false,
  }) => resolveNavPlacement(
    platform: platform,
    size: size,
    hasVerticalBar: hasVerticalBar,
    splitByHinge: splitByHinge,
  );

  test('iPhone keeps the bar at the bottom, either orientation', () {
    expect(
      resolve(TargetPlatform.iOS, const Size(402, 874)),
      NavPlacement.bottom,
    );
    expect(
      resolve(TargetPlatform.iOS, const Size(874, 402)),
      NavPlacement.bottom,
    );
  });

  test('iPad at regular width moves the bar to the top', () {
    expect(
      resolve(TargetPlatform.iOS, const Size(1032, 1376)),
      NavPlacement.top,
    );
    expect(
      resolve(TargetPlatform.iOS, const Size(1376, 1032)),
      NavPlacement.top,
    );
  });

  test('a narrow iPad Split View column keeps the bottom bar', () {
    expect(
      resolve(TargetPlatform.iOS, const Size(375, 1032)),
      NavPlacement.bottom,
    );
  });

  test('iPhone Duo goes into the vertical bar strip', () {
    expect(
      resolve(TargetPlatform.iOS, const Size(402, 874), hasVerticalBar: true),
      NavPlacement.verticalStrip,
    );
  });

  test('Android tablets and foldables keep the bottom bar', () {
    expect(
      resolve(TargetPlatform.android, const Size(1280, 800)),
      NavPlacement.bottom,
    );
    expect(
      resolve(
        TargetPlatform.android,
        const Size(1100, 720),
        splitByHinge: true,
      ),
      NavPlacement.bottom,
    );
  });

  test('Mac keeps the bottom bar', () {
    expect(
      resolve(TargetPlatform.macOS, const Size(1200, 900)),
      NavPlacement.bottom,
    );
  });
}
