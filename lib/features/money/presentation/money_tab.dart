import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../shared/widgets/blob_background.dart';
import '../../../shared/widgets/glass_icon_button.dart';
import 'money_partner_providers.dart';
import 'partner/money_partner_flow.dart';
import 'widgets/budget_card.dart';
import 'widgets/entry_list.dart';
import 'widgets/partner_spending_card.dart';
import 'widgets/recap_section.dart';

/// Budget gauge, filtered entry list and a spending recap — adding goes
/// through the nav bar's write button. While linked, a card with the
/// partner's spending too. See SPEC.md Money Flow Feature Money Flow Tab.
///
/// Opening the tab (and pulling down) reloads the partner's spending,
/// which app-open sync only refreshes every 5 minutes.
class MoneyTab extends ConsumerStatefulWidget {
  const MoneyTab({super.key});

  @override
  ConsumerState<MoneyTab> createState() => _MoneyTabState();
}

class _MoneyTabState extends ConsumerState<MoneyTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshPartner());
  }

  Future<void> _refreshPartner() async {
    if (!mounted) return;
    try {
      await refreshMoneyPartner(ProviderScope.containerOf(context));
    } catch (error) {
      // Offline — the cached partner spending stays on screen.
      debugPrint('Partner spending refresh failed: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return Scaffold(
      backgroundColor: glass.background,
      body: RepaintBoundary(
        child: BlobBackground(
          child: SafeArea(
            bottom: false,
            child: RefreshIndicator(
              onRefresh: _refreshPartner,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(const [
                        _MoneyTabHeader(),
                        SizedBox(height: 16),
                        BudgetCard(),
                        SizedBox(height: 16),
                        PartnerSpendingCard(),
                        RecapSection(),
                        SizedBox(height: 16),
                        EntryList(),
                        SizedBox(height: 88),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Title + the linked-partner button (link when not linked).
class _MoneyTabHeader extends ConsumerWidget {
  const _MoneyTabHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final partner = ref.watch(moneyPartnerProvider).valueOrNull;
    final l10n = context.l10n;
    return Row(
      children: [
        Expanded(
          child: Text(
            l10n.moneyTabTitle,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        GlassIconButton(
          icon: partner == null
              ? Icons.group_add_outlined
              : Icons.people_alt_outlined,
          iconColor: partner == null ? Colors.white60 : glass.moneyAccent,
          tooltip: partner == null
              ? l10n.moneyLinkTitle
              : l10n.moneyPartnerButton,
          onTap: () => openMoneyPartner(context, partner),
        ),
      ],
    );
  }
}
