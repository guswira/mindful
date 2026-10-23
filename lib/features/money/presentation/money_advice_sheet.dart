import 'package:flutter/material.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/glass_theme.dart';
import '../domain/money_advice.dart';
import 'money_advice_sheet_widgets.dart';

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 13,
                color: glass.textMuted,
              ),
              const SizedBox(width: Spacing.xs),
              Expanded(
                child: Text(
                  context.l10n.moneyAdviceDisclaimer,
                  style: TextStyle(color: glass.textMuted, fontSize: 11),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
