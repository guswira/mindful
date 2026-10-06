import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../shared/widgets/blob_background.dart';
import '../../exercise/presentation/widgets/breathing_section.dart';
import '../data/journal_repository.dart';
import 'journal_today_section.dart';

part 'journal_tab.g.dart';

/// A signed URL for the private Supabase Storage photo at [path], valid for
/// an hour — cheap enough to re-fetch per widget build via [ref.watch].
@riverpod
Future<String> journalPhotoUrl(Ref ref, String path) async {
  final repository = await ref.watch(journalRepositoryProvider.future);
  return repository.signedPhotoUrl(path);
}

/// The Mindfulness tab (`/home/journal`): today's journal entries, then
/// the breathing exercises, each headed by a link to its full by-date
/// view. See SPEC.md Mindfulness Tab.
class JournalTab extends StatelessWidget {
  const JournalTab({super.key});

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return Scaffold(
      backgroundColor: glass.background,
      body: RepaintBoundary(
        child: BlobBackground(
          child: SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.only(top: 20, bottom: 88),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, Spacing.md),
                  child: Text(
                    context.l10n.mindfulnessTabTitle,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const JournalTodaySection(),
                const SizedBox(height: Spacing.lg),
                const BreathingSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
