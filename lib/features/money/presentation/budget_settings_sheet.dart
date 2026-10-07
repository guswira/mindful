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
import 'money_labels.dart';
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

/// Bottom sheet to independently set the daily, weekly, monthly and yearly
/// budget amounts, sharing one currency between them. See SPEC.md Money
/// Flow Feature Budget Settings Sheet and the bottom-sheet design rules.
///
/// Each budget already in [settings] pre-fills its section and switches
/// its save to an update.
class BudgetSettingsSheet extends ConsumerStatefulWidget {
  const BudgetSettingsSheet({this.settings = const {}, super.key});

  final Map<BudgetType, BudgetSettings> settings;

  @override
  ConsumerState<BudgetSettingsSheet> createState() =>
      _BudgetSettingsSheetState();
}

class _BudgetSettingsSheetState extends ConsumerState<BudgetSettingsSheet> {
  /// One amount field per budget, indexed by [BudgetType.index].
  final _controllers = [
    for (final _ in BudgetType.values) TextEditingController(),
  ];
  final _saving = <BudgetType>{};
  late String _currency;

  @override
  void initState() {
    super.initState();
    _currency = widget.settings.values.firstOrNull?.currency ?? 'IDR';
    for (final MapEntry(key: type, value: settings)
        in widget.settings.entries) {
      if (settings.amount > 0) {
        _controllers[type.index].text = formatAmountForInput(settings.amount);
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
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
    final text = _controllers[type.index].text.trim();
    final amount = double.tryParse(ungroupDigits(text)) ?? 0;
    // Skip saving a section left at 0/empty — another section may still
    // be mid-edit and shouldn't be blocked on this one having a value.
    if (amount <= 0) {
      return;
    }

    setState(() => _saving.add(type));

    final existing = widget.settings[type];
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
    ref.invalidate(budgetsProvider);
    ref.invalidate(budgetCurrencyProvider);
    ref.invalidate(remainingBudgetProvider);

    if (!mounted) {
      return;
    }
    setState(() => _saving.remove(type));
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
          for (final type in BudgetType.values) ...[
            if (type != BudgetType.values.first)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: Spacing.md),
                child: Divider(color: Colors.white10, height: 1),
              ),
            BudgetSection(
              label: budgetTitle(l10n, type),
              currency: _currency,
              onPickCurrency: _pickCurrency,
              controller: _controllers[type.index],
              saveLabel: budgetSaveLabel(l10n, type),
              isSaving: _saving.contains(type),
              onSave: () => _save(type),
            ),
          ],
        ],
      ),
    );
  }
}

/// Opens [BudgetSettingsSheet] as a modal over [context] — used by the
/// budget card's settings gear icon.
void showBudgetSettingsSheet(
  BuildContext context, {
  Map<BudgetType, BudgetSettings> settings = const {},
}) {
  showGlassBottomSheet(
    context: context,
    builder: (_) => BudgetSettingsSheet(settings: settings),
  );
}
