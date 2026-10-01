import 'package:flutter/material.dart';

import '../../../../core/theme/glass_theme.dart';
import '../recap_slide_data.dart';

/// A slide's big headline number, counting up from 0 when the slide is
/// first built — or [RecapSlideData.heroText] as plain text.
class RecapHero extends StatelessWidget {
  const RecapHero({required this.data, super.key});

  final RecapSlideData data;

  static const Duration _countUpDuration = Duration(milliseconds: 1200);

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return Column(
      children: [
        _heroValue(context),
        if (data.heroLabel.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            data.heroLabel,
            textAlign: TextAlign.center,
            style: TextStyle(color: glass.textSecondary, fontSize: 16),
          ),
        ],
      ],
    );
  }

  Widget _heroValue(BuildContext context) {
    final value = data.heroValue;
    final format = data.formatHero;
    if (value == null || format == null) {
      return _HeroText(text: data.heroText ?? '');
    }
    final animate = !MediaQuery.disableAnimationsOf(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: animate ? 0 : value, end: value),
      duration: animate ? _countUpDuration : Duration.zero,
      curve: Curves.easeOutCubic,
      builder: (context, current, _) => _HeroText(text: format(current)),
    );
  }
}

class _HeroText extends StatelessWidget {
  const _HeroText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 48,
          fontWeight: FontWeight.bold,
          letterSpacing: -1,
        ),
      ),
    );
  }
}
