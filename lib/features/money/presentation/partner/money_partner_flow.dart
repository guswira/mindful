import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../shared/widgets/glass_bottom_sheet.dart';
import '../../domain/money_partner.dart';
import 'link_partner_sheet.dart';
import 'partner_sheet.dart';

/// Opens [PartnerSheet] while linked, else [LinkPartnerSheet] — and
/// confirms a new link with a SnackBar.
Future<void> openMoneyPartner(
  BuildContext context,
  MoneyPartner? partner,
) async {
  if (partner != null) {
    await showGlassBottomSheet<void>(
      context: context,
      builder: (_) => PartnerSheet(partner: partner),
    );
    return;
  }
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  final linked = await showGlassBottomSheet<MoneyPartner>(
    context: context,
    builder: (_) => const LinkPartnerSheet(),
  );
  if (linked != null) {
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.moneyLinkLinked(linked.name))),
    );
  }
}
