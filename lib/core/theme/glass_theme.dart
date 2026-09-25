import 'package:flutter/material.dart';

/// Frosted-glass design tokens for the dark theme — card surfaces, accent
/// colors, and muted text colors shared across every glass card and blob
/// background in the app.
class GlassTheme extends ThemeExtension<GlassTheme> {
  const GlassTheme({
    required this.background,
    required this.cardColor,
    required this.cardBorder,
    required this.strongCardColor,
    required this.strongCardBorder,
    required this.accentTeal,
    required this.accentPurple,
    required this.accentAmber,
    required this.accentBlue,
    required this.homeAccent,
    required this.taskAccent,
    required this.habitAccent,
    required this.journalAccent,
    required this.writeAccent,
    required this.moneyAccent,
    required this.moneySpending,
    required this.aiAccent,
    required this.textSecondary,
    required this.textMuted,
    required this.textHint,
  });

  /// The single set of tokens used by the app's frosted glass dark theme.
  factory GlassTheme.dark() => GlassTheme(
    background: const Color(0xFF121312),
    cardColor: Colors.white.withValues(alpha: 0.06),
    cardBorder: Colors.white.withValues(alpha: 0.12),
    strongCardColor: Colors.white.withValues(alpha: 0.08),
    strongCardBorder: Colors.white.withValues(alpha: 0.15),
    accentTeal: const Color(0xFF14E6AA),
    accentPurple: const Color(0xFF7C6AF7),
    accentAmber: const Color(0xFFF7C46A),
    accentBlue: const Color(0xFF6BB8F0),
    homeAccent: const Color(0xFFFFFFFF),
    taskAccent: const Color(0xFF60A5FA),
    habitAccent: const Color(0xFFA78BFA),
    journalAccent: const Color(0xFFFCD34D),
    writeAccent: const Color(0xFF14E6AA),
    moneyAccent: const Color(0xFF34D399),
    moneySpending: const Color(0xFFFC8181),
    aiAccent: const Color(0xFF818CF8),
    textSecondary: Colors.white.withValues(alpha: 0.55),
    textMuted: Colors.white.withValues(alpha: 0.35),
    textHint: Colors.white.withValues(alpha: 0.25),
  );

  final Color background;
  final Color cardColor;
  final Color cardBorder;
  final Color strongCardColor;
  final Color strongCardBorder;
  final Color accentTeal;
  final Color accentPurple;
  final Color accentAmber;
  final Color accentBlue;
  final Color homeAccent;
  final Color taskAccent;
  final Color habitAccent;
  final Color journalAccent;
  final Color writeAccent;
  final Color moneyAccent;
  final Color moneySpending;
  final Color aiAccent;
  final Color textSecondary;
  final Color textMuted;
  final Color textHint;

  @override
  GlassTheme copyWith({
    Color? cardColor,
    Color? cardBorder,
    Color? strongCardColor,
    Color? strongCardBorder,
    Color? accentTeal,
    Color? accentPurple,
    Color? accentAmber,
    Color? accentBlue,
    Color? homeAccent,
    Color? taskAccent,
    Color? habitAccent,
    Color? journalAccent,
    Color? writeAccent,
    Color? moneyAccent,
    Color? moneySpending,
    Color? aiAccent,
    Color? textSecondary,
    Color? textMuted,
    Color? textHint,
  }) {
    return GlassTheme(
      background: background,
      cardColor: cardColor ?? this.cardColor,
      cardBorder: cardBorder ?? this.cardBorder,
      strongCardColor: strongCardColor ?? this.strongCardColor,
      strongCardBorder: strongCardBorder ?? this.strongCardBorder,
      accentTeal: accentTeal ?? this.accentTeal,
      accentPurple: accentPurple ?? this.accentPurple,
      accentAmber: accentAmber ?? this.accentAmber,
      accentBlue: accentBlue ?? this.accentBlue,
      homeAccent: homeAccent ?? this.homeAccent,
      taskAccent: taskAccent ?? this.taskAccent,
      habitAccent: habitAccent ?? this.habitAccent,
      journalAccent: journalAccent ?? this.journalAccent,
      writeAccent: writeAccent ?? this.writeAccent,
      moneyAccent: moneyAccent ?? this.moneyAccent,
      moneySpending: moneySpending ?? this.moneySpending,
      aiAccent: aiAccent ?? this.aiAccent,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      textHint: textHint ?? this.textHint,
    );
  }

  @override
  GlassTheme lerp(ThemeExtension<GlassTheme>? other, double t) {
    if (other is! GlassTheme) return this;
    return GlassTheme(
      background: Color.lerp(background, other.background, t)!,
      cardColor: Color.lerp(cardColor, other.cardColor, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      strongCardColor: Color.lerp(strongCardColor, other.strongCardColor, t)!,
      strongCardBorder: Color.lerp(
        strongCardBorder,
        other.strongCardBorder,
        t,
      )!,
      accentTeal: Color.lerp(accentTeal, other.accentTeal, t)!,
      accentPurple: Color.lerp(accentPurple, other.accentPurple, t)!,
      accentAmber: Color.lerp(accentAmber, other.accentAmber, t)!,
      accentBlue: Color.lerp(accentBlue, other.accentBlue, t)!,
      homeAccent: Color.lerp(homeAccent, other.homeAccent, t)!,
      taskAccent: Color.lerp(taskAccent, other.taskAccent, t)!,
      habitAccent: Color.lerp(habitAccent, other.habitAccent, t)!,
      journalAccent: Color.lerp(journalAccent, other.journalAccent, t)!,
      writeAccent: Color.lerp(writeAccent, other.writeAccent, t)!,
      moneyAccent: Color.lerp(moneyAccent, other.moneyAccent, t)!,
      moneySpending: Color.lerp(moneySpending, other.moneySpending, t)!,
      aiAccent: Color.lerp(aiAccent, other.aiAccent, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textHint: Color.lerp(textHint, other.textHint, t)!,
    );
  }
}
