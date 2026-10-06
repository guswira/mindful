import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/spacing.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/glass_theme.dart';
import '../../../../shared/widgets/language_picker.dart';

/// Glass pill naming the language the screen is in; tap → the same
/// language sheet as Settings. On the login screen so someone whose device
/// language isn't what they read best can switch before signing in.
class LoginLanguageButton extends ConsumerWidget {
  const LoginLanguageButton({super.key});

  /// The language actually on screen — for "system" that's what the
  /// device resolved to, which is more useful here than "System default".
  String _currentName(BuildContext context) =>
      switch (Localizations.localeOf(context).languageCode) {
        'id' => context.l10n.languageNameBahasa,
        _ => context.l10n.languageNameEnglish,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return Semantics(
      button: true,
      label: context.l10n.settingsLanguageTitle,
      child: GestureDetector(
        onTap: () => pickAppLanguage(context, ref),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter.grouped(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: glass.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: glass.cardBorder, width: 0.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.language, size: 16, color: glass.textSecondary),
                  const SizedBox(width: Spacing.xs + 2),
                  Text(
                    _currentName(context),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: glass.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
