import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/constants/spacing.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/platform/platform_features.dart';
import '../../../../core/theme/glass_theme.dart';
import '../../../../shared/widgets/tinted_pill.dart';
import '../../data/money_partner_repository.dart';
import '../../domain/money_partner.dart';
import '../money_partner_providers.dart';

/// "Scan code": the camera (phones and the web) reads the partner's QR
/// code, or the code is typed. Pops the sheet with the partner once linked.
class LinkScanView extends ConsumerStatefulWidget {
  const LinkScanView({super.key});

  @override
  ConsumerState<LinkScanView> createState() => _LinkScanViewState();
}

class _LinkScanViewState extends ConsumerState<LinkScanView> {
  final _codeController = TextEditingController();
  MobileScannerController? _scanner;
  bool _linking = false;
  MoneyLinkError? _error;

  @override
  void initState() {
    super.initState();
    // Phones and browsers (webcam or phone browser) scan; the desktop
    // apps type the code. In a browser the camera needs HTTPS (or
    // localhost) and the user's permission.
    if (isPhonePlatform || isWebPlatform) {
      _scanner = MobileScannerController(formats: const [BarcodeFormat.qrCode]);
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _scanner?.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    for (final barcode in capture.barcodes) {
      final code = MoneyLinkInvite.parseCode(barcode.rawValue ?? '');
      if (code != null) {
        _link(code);
        return;
      }
    }
  }

  void _linkTyped() {
    final code = MoneyLinkInvite.parseCode(_codeController.text);
    if (code == null) {
      setState(() => _error = MoneyLinkError.invalidCode);
      return;
    }
    _link(code);
  }

  Future<void> _link(String code) async {
    if (_linking) return;
    setState(() {
      _linking = true;
      _error = null;
    });
    final container = ProviderScope.containerOf(context, listen: false);
    try {
      final repository = await container.read(
        moneyPartnerRepositoryProvider.future,
      );
      await repository.acceptInvite(code);
      invalidateMoneyPartner(container);
      if (!mounted) return;
      Navigator.pop(context, repository.getPartner());
    } on MoneyLinkException catch (error) {
      if (mounted) setState(() => _error = error.error);
    } catch (error) {
      debugPrint('Money link failed: $error');
      if (mounted) setState(() => _error = MoneyLinkError.unknown);
    } finally {
      if (mounted) setState(() => _linking = false);
    }
  }

  static String _errorText(AppLocalizations l10n, MoneyLinkError error) =>
      switch (error) {
        MoneyLinkError.invalidCode => l10n.moneyLinkErrorInvalid,
        MoneyLinkError.ownCode => l10n.moneyLinkErrorOwn,
        MoneyLinkError.alreadyLinked => l10n.moneyLinkErrorAlreadyLinked,
        MoneyLinkError.unknown => l10n.moneyLinkErrorUnknown,
      };

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final l10n = context.l10n;
    final scanner = _scanner;
    final error = _error;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (scanner != null) ...[
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox.square(
                dimension: 240,
                child: MobileScanner(
                  controller: scanner,
                  onDetect: _onDetect,
                  errorBuilder: (context, _) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(Spacing.md),
                      child: Text(
                        l10n.moneyLinkCameraError,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: glass.textSecondary),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            l10n.moneyLinkScanHint,
            textAlign: TextAlign.center,
            style: TextStyle(color: glass.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: Spacing.md),
        ],
        TextField(
          controller: _codeController,
          textAlign: TextAlign.center,
          textCapitalization: TextCapitalization.characters,
          textInputAction: TextInputAction.go,
          onSubmitted: (_) => _linkTyped(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            letterSpacing: 2,
          ),
          decoration: InputDecoration(
            hintText: l10n.moneyLinkTypeHint,
            hintStyle: TextStyle(
              color: glass.textHint,
              fontSize: 14,
              letterSpacing: 0,
            ),
            border: InputBorder.none,
          ),
        ),
        if (error != null) ...[
          Text(
            _errorText(l10n, error),
            textAlign: TextAlign.center,
            style: TextStyle(color: glass.moneySpending, fontSize: 13),
          ),
          const SizedBox(height: Spacing.sm),
        ],
        const SizedBox(height: Spacing.sm),
        if (_linking)
          const Center(child: CircularProgressIndicator())
        else
          TintedPill(
            label: l10n.moneyLinkButton,
            icon: Icons.link_rounded,
            color: glass.moneyAccent,
            onTap: _linkTyped,
          ),
      ],
    );
  }
}
