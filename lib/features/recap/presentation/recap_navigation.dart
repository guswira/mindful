import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../domain/recap_window.dart';

/// Opens [month]'s recap slideshow as a full page.
///
/// Kept apart from MonthlyRecapScreen so the home banner and Settings can
/// open it without importing the screen — the router loads that one on
/// demand (a separate download on web).
Future<void> openMonthlyRecap(BuildContext context, DateTime month) =>
    context.push('/recap/${recapMonthKey(month)}');
