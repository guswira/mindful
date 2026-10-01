import 'package:flutter/material.dart';

/// Story-style segment bars across the top of the recap: past slides
/// full, the current one filling with [progress], later ones empty.
class RecapProgressBars extends StatelessWidget {
  const RecapProgressBars({
    required this.count,
    required this.current,
    required this.progress,
    super.key,
  });

  final int count;
  final int current;

  /// The current slide's 0.0–1.0 fill.
  final Animation<double> progress;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, _) => Row(
        children: [
          for (var i = 0; i < count; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Expanded(child: _Segment(fill: _fillFor(i))),
          ],
        ],
      ),
    );
  }

  double _fillFor(int index) => switch (index.compareTo(current)) {
    < 0 => 1,
    0 => progress.value,
    _ => 0,
  };
}

class _Segment extends StatelessWidget {
  const _Segment({required this.fill});

  final double fill;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: LinearProgressIndicator(
        value: fill,
        minHeight: 3,
        backgroundColor: Colors.white.withValues(alpha: 0.18),
        color: Colors.white.withValues(alpha: 0.9),
      ),
    );
  }
}
