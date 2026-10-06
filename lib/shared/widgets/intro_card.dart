import 'package:flutter/material.dart';

import '../../core/constants/spacing.dart';
import '../../core/theme/glass_theme.dart';
import 'glass_card.dart';
import 'tinted_pill.dart';

/// Empty-state card that explains a feature before the user has used it —
/// icon badge, title, a short "why", then the action that gets them
/// started. Stands in for bare "No X yet" text.
class IntroCard extends StatelessWidget {
  const IntroCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onAction,
    super.key,
  });

  /// Flat icon drawn in [color] on the tinted badge.
  final IconData icon;

  /// Feature accent — tints the badge and the action pill.
  final Color color;
  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: Spacing.xs),
                    Text(
                      body,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: glass.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TintedPill(
              label: actionLabel,
              color: color,
              onTap: onAction,
            ),
          ),
        ],
      ),
    );
  }
}
