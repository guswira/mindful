import 'package:flutter/material.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/glass_theme.dart';
import '../domain/money_advice.dart';
import 'money_advice_sheet_widgets.dart';

/// Non-dismissible loading sheet shown while the advice request runs —
/// dismissed by [requestMoneyAdvice] as soon as a busy retry starts, the
/// same way [FoodAnalyzingSheet] is. See SPEC.md Money Flow Feature AI
/// Advice.
class MoneyAdviceLoadingSheet extends StatelessWidget {
  const MoneyAdviceLoadingSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AdviceTitle(),
        SizedBox(height: Spacing.md),
        AdviceLoading(),
      ],
    );
  }
}

/// Gemini's spending advice: where the money mostly goes and how to save.
/// See SPEC.md Money Flow Feature AI Advice.
class MoneyAdviceSheet extends StatelessWidget {
  const MoneyAdviceSheet({required this.advice, super.key});

  final MoneyAdvice advice;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const AdviceTitle(),
          const SizedBox(height: Spacing.md),
          AdviceContent(advice: advice),
          const SizedBox(height: Spacing.md),
          Text(
            context.l10n.moneyAdviceDisclaimer,
            style: TextStyle(color: glass.textMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
