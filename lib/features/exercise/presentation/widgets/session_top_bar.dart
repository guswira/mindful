import 'package:flutter/material.dart';

import '../../../../core/constants/spacing.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/glass_theme.dart';
import '../../../../shared/widgets/glass_icon_button.dart';

/// Back button, exercise name + pattern summary, and the sound settings
/// button above a breathing session.
class SessionTopBar extends StatelessWidget {
  const SessionTopBar({
    required this.title,
    required this.subtitle,
    required this.onBack,
    required this.onSound,
    super.key,
  });

  final String title;
  final String subtitle;
  final VoidCallback onBack;
  final VoidCallback onSound;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        GlassIconButton(
          icon: Icons.arrow_back,
          tooltip: l10n.breathingBackTooltip,
          onTap: onBack,
        ),
        const SizedBox(width: Spacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall?.copyWith(color: glass.textMuted),
              ),
            ],
          ),
        ),
        const SizedBox(width: Spacing.md),
        GlassIconButton(
          icon: Icons.music_note_outlined,
          tooltip: l10n.breathingSoundTooltip,
          onTap: onSound,
        ),
      ],
    );
  }
}
