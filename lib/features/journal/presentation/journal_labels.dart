import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../domain/journal_entry.dart';

/// Display copy for [JournalType] values.
extension JournalLabels on AppLocalizations {
  String journalTypeName(JournalType type) => switch (type) {
    JournalType.review => journalTypeReview,
    JournalType.plan => journalTypePlan,
    JournalType.gratitude => journalTypeGratitude,
  };

  /// The body field's hint for an entry of [type].
  String journalTypeHint(JournalType type) => switch (type) {
    JournalType.review => journalTypeReviewHint,
    JournalType.plan => journalTypePlanHint,
    JournalType.gratitude => journalTypeGratitudeHint,
  };

  /// Spoken name of [mood] — its icon's semantics label.
  String moodName(Mood mood) => switch (mood) {
    Mood.happy => moodHappy,
    Mood.neutral => moodNeutral,
    Mood.sad => moodSad,
    Mood.anxious => moodAnxious,
    Mood.excited => moodExcited,
  };
}

/// Flat icon for [mood] in pickers and entry cards.
IconData moodIcon(Mood mood) => switch (mood) {
  Mood.happy => Icons.sentiment_satisfied_alt_rounded,
  Mood.neutral => Icons.sentiment_neutral_rounded,
  Mood.sad => Icons.sentiment_dissatisfied_rounded,
  Mood.anxious => Icons.mood_bad_rounded,
  Mood.excited => Icons.sentiment_very_satisfied_rounded,
};

/// Flat icon shown next to [type]'s label on chips and cards.
IconData journalTypeIcon(JournalType type) => switch (type) {
  JournalType.review => Icons.nightlight_outlined,
  JournalType.plan => Icons.edit_note_rounded,
  JournalType.gratitude => Icons.volunteer_activism_outlined,
};
