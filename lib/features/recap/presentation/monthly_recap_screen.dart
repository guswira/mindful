import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../shared/widgets/blob_background.dart';
import '../domain/monthly_recap.dart';
import '../domain/recap_window.dart';
import 'monthly_recap_providers.dart';
import 'recap_slides.dart';
import 'widgets/recap_slideshow.dart';

/// Opens [month]'s recap slideshow as a full page.
Future<void> openMonthlyRecap(BuildContext context, DateTime month) =>
    context.push('/recap/${recapMonthKey(month)}');

/// Full-screen, story-style recap of [month]'s routines, tasks, cashflow
/// and AI usage (route `/recap/:month`). See SPEC.md Monthly Recap.
class MonthlyRecapScreen extends ConsumerWidget {
  const MonthlyRecapScreen({required this.month, super.key});

  /// The 1st of the recapped month.
  final DateTime month;

  void _close(BuildContext context) =>
      context.canPop() ? context.pop() : context.go('/home/today');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return Scaffold(
      backgroundColor: glass.background,
      body: RepaintBoundary(
        child: BlobBackground(
          child: switch (ref.watch(monthlyRecapProvider(month))) {
            AsyncData(:final value) => _Loaded(
              recap: value,
              onClose: () => _close(context),
            ),
            AsyncError() => _Message(
              text: context.l10n.recapLoadError,
              onClose: () => _close(context),
            ),
            _ => Center(
              child: CircularProgressIndicator(color: glass.writeAccent),
            ),
          },
        ),
      ),
    );
  }
}

class _Loaded extends StatelessWidget {
  const _Loaded({required this.recap, required this.onClose});

  final MonthlyRecap recap;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return RecapSlideshow(
      slides: buildRecapSlides(recap, context.l10n, glass),
      onClose: onClose,
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text, required this.onClose});

  final String text;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return SafeArea(
      child: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(Spacing.lg),
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(color: glass.textSecondary, fontSize: 15),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              tooltip: context.l10n.recapClose,
              onPressed: onClose,
              icon: const Icon(Icons.close, color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}
