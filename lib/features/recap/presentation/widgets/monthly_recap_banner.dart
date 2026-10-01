import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/spacing.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/glass_theme.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../monthly_recap_providers.dart';
import '../monthly_recap_screen.dart';

/// Home screen invite to the month's recap, shown every day from the last
/// days of a month through the first days of the next (see
/// [monthlyRecapBannerMonthProvider]). Tapping opens the slideshow.
class MonthlyRecapHomeBanner extends ConsumerWidget {
  const MonthlyRecapHomeBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(monthlyRecapBannerMonthProvider);
    if (month == null) return const SizedBox.shrink();
    return _BannerCard(
      month: month,
      onOpen: () => openMonthlyRecap(context, month),
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({required this.month, required this.onOpen});

  final DateTime month;
  final VoidCallback onOpen;

  String _title(AppLocalizations l10n) {
    final now = DateTime.now();
    final name = DateFormat.MMMM().format(month);
    final inProgress = month.year == now.year && month.month == now.month;
    return inProgress
        ? l10n.recapBannerTitleSoFar(name)
        : l10n.recapBannerTitle(name);
  }

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.md),
      child: GestureDetector(
        onTap: onOpen,
        child: GlassCard(
          strong: true,
          borderRadius: 16,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              const _BannerIcon(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _title(l10n),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.recapBannerSubtitle,
                      style: TextStyle(color: glass.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: glass.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class _BannerIcon extends StatelessWidget {
  const _BannerIcon();

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            glass.writeAccent.withValues(alpha: 0.25),
            glass.aiAccent.withValues(alpha: 0.25),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.auto_graph_rounded, color: glass.writeAccent, size: 20),
    );
  }
}
