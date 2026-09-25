import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../shared/services/widget_service.dart';
import '../../../shared/widgets/shake_widget.dart';
import '../../../shared/widgets/sheet_header.dart';
import '../../../shared/widgets/tinted_pill.dart';
import '../../auth/domain/auth_state.dart';
import '../data/money_repository.dart';
import '../domain/entry_type.dart';
import '../domain/money_entry.dart';
import 'add_money_sheet_widgets.dart';
import 'amount_input_formatter.dart';
import 'money_providers.dart';

/// Bottom sheet to create or edit a money entry: type, amount, category,
/// note and date. See SPEC.md Money Flow Feature Add Money Sheet and the
/// bottom-sheet design rules.
///
/// Passing [entry] pre-fills the form and switches saving to an update;
/// [defaultType] picks the initial spending/income toggle for a new entry.
class AddMoneySheet extends ConsumerStatefulWidget {
  const AddMoneySheet({
    this.defaultType = EntryType.spending,
    this.entry,
    super.key,
  });

  final EntryType defaultType;
  final MoneyEntry? entry;

  @override
  ConsumerState<AddMoneySheet> createState() => _AddMoneySheetState();
}

class _AddMoneySheetState extends ConsumerState<AddMoneySheet> {
  late EntryType _type;
  final _amountController = TextEditingController();
  final _amountShake = GlobalKey<ShakeWidgetState>();
  final _noteController = TextEditingController();
  late String _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final entry = widget.entry;
    _type = entry?.type ?? widget.defaultType;
    _selectedCategory = entry?.category ?? _categoriesFor(_type).first;
    if (entry != null) {
      _amountController.text = formatAmountForInput(entry.amount);
      _noteController.text = entry.note ?? '';
      _selectedDate = entry.date;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  static List<String> _categoriesFor(EntryType type) =>
      type == EntryType.spending ? spendingCategories : incomeCategories;

  void _setType(EntryType type) {
    setState(() {
      _type = type;
      _selectedCategory = _categoriesFor(type).first;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(_selectedDate.year - 5),
      lastDate: DateTime.now(),
    );
    if (!mounted || picked == null) {
      return;
    }
    setState(() => _selectedDate = picked);
  }

  Future<void> _save() async {
    final amount = double.tryParse(
      ungroupDigits(_amountController.text.trim()),
    );
    if (amount == null || amount <= 0) {
      _amountShake.currentState?.shake();
      return;
    }

    setState(() => _isSaving = true);
    final now = DateTime.now();
    final note = _noteController.text.trim();
    // Period filters (EntryList, budget spending totals) compare against
    // a range ending at midnight, so a date left with the current
    // time-of-day (the default before the user ever opens the date
    // picker) would read as "after" that boundary and silently drop out
    // of every "today"/"this period" view.
    final date = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );
    final existing = widget.entry;
    final entry = existing == null
        ? MoneyEntry(
            id: const Uuid().v4(),
            userId: ref.read(currentUserIdProvider),
            type: _type,
            amount: amount,
            category: _selectedCategory,
            note: note.isEmpty ? null : note,
            date: date,
            createdAt: now,
            updatedAt: now,
          )
        : existing.copyWith(
            type: _type,
            amount: amount,
            category: _selectedCategory,
            note: note.isEmpty ? null : note,
            date: date,
            updatedAt: now,
          );

    final repository = await ref.read(moneyRepositoryProvider.future);
    await (existing == null
        ? repository.createEntry(entry)
        : repository.updateEntry(entry));
    await refreshWidgetsBestEffort(
      () => ref.read(widgetServiceProvider.future),
    );
    ref.invalidate(moneyEntriesProvider);
    ref.invalidate(remainingBudgetProvider);

    if (!mounted) {
      return;
    }
    setState(() => _isSaving = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final activeColor = _type == EntryType.spending
        ? glass.moneySpending
        : glass.moneyAccent;
    final currency = ref.watch(budgetCurrencyProvider).valueOrNull ?? 'IDR';
    final l10n = context.l10n;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SheetHeader(
            title: widget.entry == null
                ? l10n.moneyAddEntryTitle
                : l10n.moneyEditEntryTitle,
            onClose: () => Navigator.pop(context),
          ),
          const SizedBox(height: Spacing.md),
          TypeToggleRow(type: _type, onChanged: _setType),
          const SizedBox(height: Spacing.lg),
          AmountField(
            shakeKey: _amountShake,
            controller: _amountController,
            currency: currency,
          ),
          const SizedBox(height: Spacing.md),
          Text(
            l10n.moneyCategoryHeading,
            style: TextStyle(color: glass.textHint, fontSize: 12),
          ),
          const SizedBox(height: Spacing.sm),
          CategoryWrap(
            categories: _categoriesFor(_type),
            selected: _selectedCategory,
            activeColor: activeColor,
            onChanged: (category) =>
                setState(() => _selectedCategory = category),
          ),
          const SizedBox(height: Spacing.sm),
          TextField(
            controller: _noteController,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
            decoration: InputDecoration(
              hintText: l10n.moneyNoteHint,
              hintStyle: TextStyle(color: glass.textHint, fontSize: 14),
              border: InputBorder.none,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          DateRow(date: _selectedDate, onTap: _pickDate),
          const SizedBox(height: Spacing.lg),
          SizedBox(
            width: double.infinity,
            child: _isSaving
                ? const Center(child: CircularProgressIndicator())
                : TintedPill(
                    label: widget.entry != null
                        ? l10n.moneySaveChanges
                        : l10n.commonSave,
                    color: activeColor,
                    onTap: _save,
                  ),
          ),
        ],
      ),
    );
  }
}
