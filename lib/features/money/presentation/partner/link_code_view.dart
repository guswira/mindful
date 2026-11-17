import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/constants/spacing.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/glass_theme.dart';
import '../../../../shared/widgets/tinted_pill.dart';
import '../../data/money_partner_repository.dart';
import '../../domain/money_partner.dart';
import '../money_partner_providers.dart';

/// "My code": this account's invite as a QR code + typed code. Checks
/// every few seconds whether the other phone has scanned it, and pops the
/// sheet with the partner once it has.
class LinkCodeView extends ConsumerStatefulWidget {
  const LinkCodeView({super.key});

  /// How often to look for the partner while the code is up.
  static const Duration pollInterval = Duration(seconds: 3);

  @override
  ConsumerState<LinkCodeView> createState() => _LinkCodeViewState();
}

class _LinkCodeViewState extends ConsumerState<LinkCodeView> {
  MoneyLinkInvite? _invite;
  bool _failed = false;
  bool _expired = false;
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    _createInvite();
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  Future<void> _createInvite() async {
    _poll?.cancel();
    setState(() {
      _invite = null;
      _failed = false;
      _expired = false;
    });
    try {
      final repository = await ref.read(moneyPartnerRepositoryProvider.future);
      final invite = await repository.createInvite();
      if (!mounted) return;
      setState(() => _invite = invite);
      _poll = Timer.periodic(LinkCodeView.pollInterval, (_) => _check());
    } catch (error) {
      debugPrint('Could not create a money link code: $error');
      if (mounted) setState(() => _failed = true);
    }
  }

  /// Looks for the partner; stops once linked or the code expires.
  Future<void> _check() async {
    final invite = _invite;
    if (invite == null) return;
    if (DateTime.now().isAfter(invite.expiresAt)) {
      _poll?.cancel();
      setState(() => _expired = true);
      return;
    }
    final container = ProviderScope.containerOf(context, listen: false);
    try {
      await refreshMoneyPartner(container);
    } catch (error) {
      // Offline for a moment — the next tick tries again.
      debugPrint('Money link check failed: $error');
      return;
    }
    final repository = await container.read(
      moneyPartnerRepositoryProvider.future,
    );
    final partner = repository.getPartner();
    if (partner != null && mounted) {
      _poll?.cancel();
      Navigator.pop(context, partner);
    }
  }

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final l10n = context.l10n;
    final invite = _invite;
    if (_failed || _expired) {
      return Center(
        child: Column(
          children: [
            Text(
              _failed ? l10n.moneyLinkCodeError : l10n.moneyLinkExpired,
              textAlign: TextAlign.center,
              style: TextStyle(color: glass.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: Spacing.md),
            TintedPill(
              label: l10n.moneyLinkNewCode,
              icon: Icons.refresh_rounded,
              color: glass.moneyAccent,
              onTap: _createInvite,
            ),
          ],
        ),
      );
    }
    if (invite == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(Spacing.lg),
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Center(
      child: Column(
        children: [
          // QR codes need a light quiet zone to scan reliably.
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: QrImageView(
                data: invite.qrData,
                size: 200,
                padding: EdgeInsets.zero,
                semanticsLabel: invite.displayCode,
              ),
            ),
          ),
          const SizedBox(height: Spacing.md),
          SelectableText(
            invite.displayCode,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          Text(
            l10n.moneyLinkValidFor,
            style: TextStyle(color: glass.textMuted, fontSize: 12),
          ),
          const SizedBox(height: Spacing.md),
          Text(
            l10n.moneyLinkShowHint,
            textAlign: TextAlign.center,
            style: TextStyle(color: glass.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: Spacing.md),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox.square(
                dimension: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: glass.moneyAccent,
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Text(
                l10n.moneyLinkWaiting,
                style: TextStyle(color: glass.textMuted, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
