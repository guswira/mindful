import 'package:flutter/material.dart';

/// A small labelled number under a slide's hero value.
typedef RecapStat = ({String value, String label});

/// Everything one recap slide shows. Built from a [MonthlyRecap] by
/// [buildRecapSlides], rendered by [RecapSlide].
class RecapSlideData {
  const RecapSlideData({
    required this.accent,
    required this.icon,
    required this.title,
    required this.heroLabel,
    required this.motivation,
    this.heroValue,
    this.formatHero,
    this.heroText,
    this.stats = const [],
    this.isLast = false,
  });

  final Color accent;

  /// Flat icon on the slide's accent-tinted badge.
  final IconData icon;
  final String title;

  /// Counted up from 0 on entry and shown via [formatHero]. When null,
  /// [heroText] is shown as-is instead.
  final double? heroValue;
  final String Function(double value)? formatHero;
  final String? heroText;

  final String heroLabel;
  final List<RecapStat> stats;

  /// The encouraging line every slide ends on.
  final String motivation;

  /// Whether this slide ends the show (gets the "Done" button).
  final bool isLast;
}
