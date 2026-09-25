import 'package:flutter/material.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../shared/widgets/tinted_pill.dart';
import 'amount_input_formatter.dart';

/// One budget-type section on [BudgetSettingsSheet] — a label, the shared
/// currency + amount row, and its own independent save pill. Monthly and
/// daily each get one of these.
class BudgetSection extends StatelessWidget {
  const BudgetSection({
    required this.label,
    required this.currency,
    required this.onPickCurrency,
    required this.controller,
    required this.saveLabel,
    required this.isSaving,
    required this.onSave,
    super.key,
  });

  final String label;
  final String currency;
  final VoidCallback onPickCurrency;
  final TextEditingController controller;
  final String saveLabel;
  final bool isSaving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: glass.textSecondary, fontSize: 13)),
        const SizedBox(height: Spacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: onPickCurrency,
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              child: Text(
                currency,
                style: TextStyle(color: glass.moneyAccent, fontSize: 20),
              ),
            ),
            const SizedBox(width: Spacing.sm),
            IntrinsicWidth(
              child: TextField(
                controller: controller,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: const [ThousandsInputFormatter()],
                decoration: InputDecoration(
                  hintText: '0',
                  hintStyle: TextStyle(color: glass.textHint, fontSize: 28),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.md),
        SizedBox(
          width: double.infinity,
          child: isSaving
              ? const Center(child: CircularProgressIndicator())
              : TintedPill(
                  label: saveLabel,
                  color: glass.moneyAccent,
                  onTap: onSave,
                ),
        ),
      ],
    );
  }
}
