import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../shared/widgets/shake_widget.dart';
import '../domain/entry_type.dart';
import '../domain/money_entry.dart';
import 'amount_input_formatter.dart';
import 'money_labels.dart';

/// The spending/income segmented toggle at the top of [AddMoneySheet].
class TypeToggleRow extends StatelessWidget {
  const TypeToggleRow({required this.type, required this.onChanged, super.key});

  final EntryType type;
  final ValueChanged<EntryType> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        Expanded(
          child: _TypePill(
            label: l10n.moneyTypeToggleSpending,
            isSpending: true,
            active: type == EntryType.spending,
            onTap: () => onChanged(EntryType.spending),
          ),
        ),
        const SizedBox(width: Spacing.sm),
        Expanded(
          child: _TypePill(
            label: l10n.moneyTypeToggleIncome,
            isSpending: false,
            active: type == EntryType.income,
            onTap: () => onChanged(EntryType.income),
          ),
        ),
      ],
    );
  }
}

class _TypePill extends StatelessWidget {
  const _TypePill({
    required this.label,
    required this.isSpending,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool isSpending;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final color = isSpending ? glass.moneySpending : glass.moneyAccent;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? color.withValues(alpha: 0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active
                ? color.withValues(alpha: 0.25)
                : Colors.white.withValues(alpha: 0.12),
            width: 0.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? color : glass.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// The large centered amount input on [AddMoneySheet], prefixed with the
/// budget's currency code (e.g. "IDR") — falls back to 'IDR' the same as
/// [BudgetSettingsSheet] when no budget has been set yet.
class AmountField extends StatelessWidget {
  const AmountField({
    required this.shakeKey,
    required this.controller,
    this.currency = 'IDR',
    super.key,
  });

  final GlobalKey<ShakeWidgetState> shakeKey;
  final TextEditingController controller;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return ShakeWidget(
      key: shakeKey,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            currency,
            style: TextStyle(color: glass.textSecondary, fontSize: 24),
          ),
          const SizedBox(width: 4),
          IntrinsicWidth(
            child: TextField(
              controller: controller,
              autofocus: true,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: const [ThousandsInputFormatter()],
              decoration: InputDecoration(
                hintText: '0',
                hintStyle: TextStyle(color: glass.textHint, fontSize: 36),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The category chip picker on [AddMoneySheet], filtered to [categories].
class CategoryWrap extends StatelessWidget {
  const CategoryWrap({
    required this.categories,
    required this.selected,
    required this.activeColor,
    required this.onChanged,
    super.key,
  });

  final List<String> categories;
  final String selected;
  final Color activeColor;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return Wrap(
      spacing: Spacing.sm,
      runSpacing: Spacing.sm,
      children: [
        for (final category in categories)
          GestureDetector(
            onTap: () => onChanged(category),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: category == selected
                    ? activeColor.withValues(alpha: 0.18)
                    : Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: category == selected
                      ? activeColor.withValues(alpha: 0.25)
                      : Colors.white.withValues(alpha: 0.12),
                  width: 0.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    categoryEmoji[category] ?? '',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: Spacing.xs),
                  Text(
                    categoryLabel(context.l10n, category),
                    style: TextStyle(
                      color: category == selected
                          ? Colors.white
                          : glass.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// The date picker row on [AddMoneySheet].
class DateRow extends StatelessWidget {
  const DateRow({required this.date, required this.onTap, super.key});

  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(Icons.calendar_today_outlined, size: 16, color: glass.textHint),
          const SizedBox(width: Spacing.sm),
          Text(
            DateFormat.yMMMd().format(date),
            style: TextStyle(color: glass.textSecondary, fontSize: 13),
          ),
          const Spacer(),
          Text(
            context.l10n.moneyDateChange,
            style: TextStyle(color: glass.textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
