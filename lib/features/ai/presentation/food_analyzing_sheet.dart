import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/glass_theme.dart';

/// Non-dismissible loading sheet shown while a food photo is compressed
/// and sent to Gemini. See SPEC.md AI Lab Feature FoodAnalyzingSheet.
class FoodAnalyzingSheet extends StatelessWidget {
  const FoodAnalyzingSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 40),
        _AnalyzingSpinner(color: glass.aiAccent),
        const SizedBox(height: 28),
        Text(
          context.l10n.aiAnalyzingTitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: Spacing.sm),
        const _TipRotator(),
        const SizedBox(height: 40),
      ],
    );
  }
}

class _AnalyzingSpinner extends StatelessWidget {
  const _AnalyzingSpinner({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 72,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(color: color, strokeWidth: 2.5),
          const Icon(
            Icons.restaurant_outlined,
            color: Colors.white60,
            size: 30,
          ),
        ],
      ),
    );
  }
}

class _TipRotator extends StatefulWidget {
  const _TipRotator();

  @override
  State<_TipRotator> createState() => _TipRotatorState();
}

class _TipRotatorState extends State<_TipRotator> {
  static const int _tipCount = 4;

  late final Timer _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      setState(() => _index = (_index + 1) % _tipCount);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _tip(AppLocalizations l10n) => switch (_index) {
    0 => l10n.aiAnalyzingTipIngredients,
    1 => l10n.aiAnalyzingTipPortions,
    2 => l10n.aiAnalyzingTipNutrition,
    _ => l10n.aiAnalyzingTipAlmostDone,
  };

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      child: Text(
        _tip(context.l10n),
        key: ValueKey(_index),
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.45),
          fontSize: 13,
        ),
      ),
    );
  }
}
