import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/l10n/l10n.dart';
import '../../../shared/widgets/glass_bottom_sheet.dart';
import '../../../shared/widgets/sheet_header.dart';
import '../../auth/domain/auth_state.dart';
import '../data/money_repository.dart';
import '../domain/budget_settings.dart';
import '../domain/budget_type.dart';
import 'amount_input_formatter.dart';
import 'budget_settings_sheet_widgets.dart';
import 'money_providers.dart';

/// USD/EUR/GBP/etc currency codes offered by [BudgetSettingsSheet]'s
/// currency picker. See SPEC.md Money Flow Feature Budget Settings Sheet.
const List<String> availableCurrencies = [
  'USD',
  'EUR',
  'GBP',
  'SGD',
  'IDR',
  'MYR',
  'THB',
  'JPY',
  'AUD',
  'CAD',
];

/// Bottom sheet to independently set the monthly and daily budget amounts,
/// sharing one currency between them. See SPEC.md Money Flow Feature
/// Budget Settings Sheet and the bottom-sheet design rules.
///
/// Passing [monthlySettings]/[dailySettings] pre-fills each section and
/// switches its save to an update.
class BudgetSettingsSheet extends ConsumerStatefulWidget {
  const BudgetSettingsSheet({
    this.monthlySettings,
    this.dailySettings,
    super.key,
  });

  final BudgetSettings? monthlySettings;
  final BudgetSettings? dailySettings;

  @override
  ConsumerState<BudgetSettingsSheet> createState() =>
      _BudgetSettingsSheetState();
}

class _BudgetSettingsSheetState extends ConsumerState<BudgetSettingsSheet> {
  final _monthlyAmountController = TextEditingController();
  final _dailyAmountController = TextEditingController();
  late String _currency;
  bool _isSavingMonthly = false;
  bool _isSavingDaily = false;

  @override
  void initState() {
    super.initState();
    _currency =
        widget.monthlySettings?.currency ??
        widget.dailySettings?.currency ??
        'IDR';
    if (widget.monthlySettings case final settings? when settings.amount > 0) {
      _monthlyAmountController.text = formatAmountForInput(settings.amount);
    }
    if (widget.dailySettings case final settings? when settings.amount > 0) {
      _dailyAmountController.text = formatAmountForInput(settings.amount);
    }
  }

  @override
  void dispose() {
    _monthlyAmountController.dispose();
    _dailyAmountController.dispose();
    super.dispose();
  }

  Future<void> _pickCurrency() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final currency in availableCurrencies)
              ListTile(
                title: Text(currency),
                trailing: currency == _currency
                    ? const Icon(Icons.check, color: Colors.white)
                    : null,
                onTap: () => Navigator.pop(context, currency),
              ),
          ],
        ),
      ),
    );
    if (!mounted || picked == null) {
      return;
    }
    setState(() => _currency = picked);
  }

  Future<void> _save(BudgetType type) async {
    final controller = type == BudgetType.monthly
        ? _monthlyAmountController
        : _dailyAmountController;
    final amount = double.tryParse(ungroupDigits(controller.text.trim())) ?? 0;
    // Skip saving a section left at 0/empty — the other section may still
    // be mid-edit and shouldn't be blocked on this one having a value.
    if (amount <= 0) {
      return;
    }

    setState(() {
      if (type == BudgetType.monthly) {
        _isSavingMonthly = true;
      } else {
        _isSavingDaily = true;
      }
    });

    final existing = type == BudgetType.monthly
        ? widget.monthlySettings
        : widget.dailySettings;
    final settings = existing == null
        ? BudgetSettings(
            id: const Uuid().v4(),
            userId: ref.read(currentUserIdProvider),
            updatedAt: DateTime.now(),
            budgetType: type,
            amount: amount,
            currency: _currency,
          )
        : existing.copyWith(
            amount: amount,
            currency: _currency,
            updatedAt: DateTime.now(),
          );

    final repository = await ref.read(moneyRepositoryProvider.future);
    await repository.setCurrency(_currency);
    await repository.saveBudgetSettings(settings);
    ref.invalidate(monthlyBudgetProvider);
    ref.invalidate(dailyBudgetProvider);
    ref.invalidate(budgetCurrencyProvider);
    ref.invalidate(remainingBudgetProvider);

    if (!mounted) {
      return;
    }
    setState(() {
      if (type == BudgetType.monthly) {
        _isSavingMonthly = false;
      } else {
        _isSavingDaily = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SheetHeader(
            title: l10n.moneyBudgetSettingsTitle,
            onClose: () => Navigator.pop(context),
          ),
          const SizedBox(height: Spacing.md),
          BudgetSection(
            label: l10n.moneyMonthlyBudget,
            currency: _currency,
            onPickCurrency: _pickCurrency,
            controller: _monthlyAmountController,
            saveLabel: l10n.moneySaveMonthly,
            isSaving: _isSavingMonthly,
            onSave: () => _save(BudgetType.monthly),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Colors.white10, height: 1),
          ),
          BudgetSection(
            label: l10n.moneyDailyBudget,
            currency: _currency,
            onPickCurrency: _pickCurrency,
            controller: _dailyAmountController,
            saveLabel: l10n.moneySaveDaily,
            isSaving: _isSavingDaily,
            onSave: () => _save(BudgetType.daily),
          ),
        ],
      ),
    );
  }
}

/// Opens [BudgetSettingsSheet] as a modal over [context] — used by the
/// budget card's settings gear icon.
void showBudgetSettingsSheet(
  BuildContext context, {
  BudgetSettings? monthlySettings,
  BudgetSettings? dailySettings,
}) {
  showGlassBottomSheet(
    context: context,
    builder: (_) => BudgetSettingsSheet(
      monthlySettings: monthlySettings,
      dailySettings: dailySettings,
    ),
  );
}
