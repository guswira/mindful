import 'package:flutter/material.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/glass_theme.dart';
import '../domain/money_advice.dart';

/// Spinner shown while Gemini is working on the advice.
class AdviceLoading extends StatelessWidget {
  const AdviceLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Spacing.lg),
        child: Column(
          children: [
            CircularProgressIndicator(color: glass.aiAccent, strokeWidth: 2),
            const SizedBox(height: Spacing.md),
            Text(
              context.l10n.moneyAdviceLoading,
              style: TextStyle(color: glass.textSecondary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

/// The sparkle icon + "AI spending advice" title shared by the loading and
/// result sheets.
class AdviceTitle extends StatelessWidget {
  const AdviceTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return Row(
      children: [
        Icon(Icons.auto_awesome_outlined, color: glass.aiAccent),
        const SizedBox(width: Spacing.sm),
        Text(
          context.l10n.moneyAdviceTitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// The summary, spending insights and saving tips.
class AdviceContent extends StatelessWidget {
  const AdviceContent({required this.advice, super.key});

  final MoneyAdvice advice;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(label: l10n.moneyAdviceSummary),
        Text(
          advice.summary,
          style: TextStyle(color: glass.textSecondary, fontSize: 14),
        ),
        if (advice.spendingInsights.isNotEmpty) ...[
          const SizedBox(height: Spacing.md),
          _SectionTitle(label: l10n.moneyAdviceInsights),
          for (final insight in advice.spendingInsights)
            _Bullet(text: insight, color: glass.moneySpending),
        ],
        if (advice.savingTips.isNotEmpty) ...[
          const SizedBox(height: Spacing.md),
          _SectionTitle(label: l10n.moneyAdviceTips),
          for (final tip in advice.savingTips)
            _Bullet(text: tip, color: glass.moneyAccent),
        ],
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.xs),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('•  ', style: TextStyle(color: color, fontSize: 14)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: glass.textSecondary, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
