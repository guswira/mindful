import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/spacing.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/glass_theme.dart';
import '../../../../shared/widgets/sheet_header.dart';
import '../../../../shared/widgets/tinted_pill.dart';
import '../../data/money_partner_repository.dart';
import '../../domain/money_partner.dart';
import '../money_partner_providers.dart';

/// Who this account is linked with, what that means, and Unlink (behind
/// a confirm dialog). See SPEC.md Money Flow Feature Linked partner.
class PartnerSheet extends StatefulWidget {
  const PartnerSheet({required this.partner, super.key});

  final MoneyPartner partner;

  @override
  State<PartnerSheet> createState() => _PartnerSheetState();
}

class _PartnerSheetState extends State<PartnerSheet> {
  bool _unlinking = false;

  Future<void> _unlink() async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.moneyPartnerUnlinkTitle(widget.partner.firstName)),
        content: Text(l10n.moneyPartnerUnlinkBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.moneyPartnerUnlink),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _unlinking = true);
    final container = ProviderScope.containerOf(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final repository = await container.read(
        moneyPartnerRepositoryProvider.future,
      );
      await repository.unlink();
      invalidateMoneyPartner(container);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.moneyPartnerUnlinked)),
      );
      if (mounted) Navigator.pop(context);
    } catch (error) {
      debugPrint('Money unlink failed: $error');
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.moneyPartnerUnlinkError)),
      );
      if (mounted) setState(() => _unlinking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final l10n = context.l10n;
    final partner = widget.partner;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SheetHeader(
          title: l10n.moneyPartnerButton,
          onClose: () => Navigator.pop(context),
        ),
        const SizedBox(height: Spacing.md),
        Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: glass.moneyAccent.withValues(alpha: 0.18),
              child: Text(
                partner.firstName.characters.first.toUpperCase(),
                style: TextStyle(
                  color: glass.moneyAccent,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    partner.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (partner.email != partner.name)
                    Text(
                      partner.email,
                      style: TextStyle(color: glass.textMuted, fontSize: 13),
                    ),
                  Text(
                    l10n.moneyPartnerSince(
                      DateFormat.yMMMd().format(partner.linkedAt.toLocal()),
                    ),
                    style: TextStyle(color: glass.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.md),
        Text(
          l10n.moneyPartnerExplain,
          style: TextStyle(
            color: glass.textSecondary,
            fontSize: 13,
            height: 1.5,
          ),
        ),
        const SizedBox(height: Spacing.lg),
        SizedBox(
          width: double.infinity,
          child: _unlinking
              ? const Center(child: CircularProgressIndicator())
              : TintedPill(
                  label: l10n.moneyPartnerUnlink,
                  icon: Icons.link_off_rounded,
                  color: glass.moneySpending,
                  onTap: _unlink,
                ),
        ),
      ],
    );
  }
}
