import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/glass_theme.dart';
import '../../../../shared/models/quote.dart';
import '../../../../shared/services/quote_service.dart';
import '../../../../shared/widgets/glass_card.dart';

/// The quote of the day below the greeting — tap to expand the full quote
/// in a bottom sheet. See SPEC.md Quotes.
class QuoteWidget extends ConsumerWidget {
  const QuoteWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quoteAsync = ref.watch(dailyQuoteProvider);
    final glass = Theme.of(context).extension<GlassTheme>()!;

    return switch (quoteAsync) {
      AsyncData(:final value) => GestureDetector(
        onTap: () => _showQuoteSheet(context, value),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value.quote,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: glass.textMuted,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '— ${value.author}',
              style: TextStyle(fontSize: 12, color: glass.textHint),
            ),
          ],
        ),
      ),
      AsyncError() => const SizedBox.shrink(),
      _ => const SizedBox(height: 40),
    };
  }

  void _showQuoteSheet(BuildContext context, Quote quote) {
    final accentTeal = Theme.of(context).extension<GlassTheme>()!.accentTeal;
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(16),
        child: GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                quote.quote,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  fontStyle: FontStyle.italic,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '— ${quote.author}',
                style: TextStyle(fontSize: 14, color: accentTeal),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
