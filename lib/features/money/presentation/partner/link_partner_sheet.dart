import 'package:flutter/material.dart';

import '../../../../core/constants/spacing.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/glass_theme.dart';
import '../../../../shared/widgets/sheet_header.dart';
import 'link_code_view.dart';
import 'link_scan_view.dart';

/// Links two accounts' money: one phone shows a QR code ("My code"), the
/// other scans it ("Scan code"). Pops with the new [MoneyPartner] once
/// either side completes. See SPEC.md Money Flow Feature Linked partner.
class LinkPartnerSheet extends StatefulWidget {
  const LinkPartnerSheet({super.key});

  @override
  State<LinkPartnerSheet> createState() => _LinkPartnerSheetState();
}

class _LinkPartnerSheetState extends State<LinkPartnerSheet> {
  bool _scanning = false;

  void _setScanning(bool scanning) => setState(() => _scanning = scanning);

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final l10n = context.l10n;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SheetHeader(
            title: l10n.moneyLinkTitle,
            onClose: () => Navigator.pop(context),
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            l10n.moneyLinkIntro,
            style: TextStyle(
              color: glass.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: Spacing.md),
          Row(
            children: [
              Expanded(
                child: _ModeTab(
                  icon: Icons.qr_code_2_rounded,
                  label: l10n.moneyLinkShowCode,
                  active: !_scanning,
                  onTap: () => _setScanning(false),
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: _ModeTab(
                  icon: Icons.qr_code_scanner_rounded,
                  label: l10n.moneyLinkScanCode,
                  active: _scanning,
                  onTap: () => _setScanning(true),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.lg),
          // Keyed so switching back to "My code" asks for a fresh code.
          if (_scanning)
            const LinkScanView(key: ValueKey('scan'))
          else
            const LinkCodeView(key: ValueKey('code')),
        ],
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  const _ModeTab({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final color = active ? glass.moneyAccent : glass.textSecondary;
    return Semantics(
      button: true,
      selected: active,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active
                ? glass.moneyAccent.withValues(alpha: 0.18)
                : glass.cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: active
                  ? glass.moneyAccent.withValues(alpha: 0.30)
                  : glass.cardBorder,
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: Spacing.xs),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
