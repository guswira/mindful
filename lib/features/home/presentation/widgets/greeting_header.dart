import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/glass_theme.dart';
import '../../../../shared/widgets/glass_icon_button.dart';
import '../../../auth/domain/auth_state.dart';
import 'quote_widget.dart';

/// Date, time-based greeting with first name, the quote of the day, and
/// the settings gear — the only way into /settings. See SPEC.md Home
/// Screen.
class GreetingHeader extends ConsumerWidget {
  const GreetingHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final authState = ref.watch(authNotifierProvider);
    final firstName = switch (authState) {
      AuthAuthenticated(:final user) => firstNameFrom(
        metadata: user.userMetadata,
        email: user.email,
      ),
      _ => null,
    };
    final greeting = greetingFor(
      TimeOfDay.now(),
      firstName: firstName,
      l10n: context.l10n,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('EEEE, MMMM d').format(DateTime.now()),
                style: TextStyle(
                  fontSize: 13,
                  color: glass.textSecondary,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                greeting,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 24),
              const QuoteWidget(),
              const SizedBox(height: 24),
            ],
          ),
        ),
        GlassIconButton(
          icon: Icons.settings_outlined,
          tooltip: context.l10n.homeSettingsTooltip,
          onTap: () => context.push('/settings'),
        ),
      ],
    );
  }
}

/// The whole greeting for [time] — morning before noon, evening from 5pm —
/// addressed to [firstName] when known.
///
/// Returned as one message (not prefix + name) so translations can place
/// the name wherever their grammar needs it. [l10n] defaults to
/// [currentL10n].
String greetingFor(
  TimeOfDay time, {
  String? firstName,
  AppLocalizations? l10n,
}) {
  final copy = l10n ?? currentL10n;
  return switch ((time.hour, firstName)) {
    (< 12, null) => copy.homeGreetingMorning,
    (< 12, final String name) => copy.homeGreetingMorningName(name),
    (< 17, null) => copy.homeGreetingAfternoon,
    (< 17, final String name) => copy.homeGreetingAfternoonName(name),
    (_, null) => copy.homeGreetingEvening,
    (_, final String name) => copy.homeGreetingEveningName(name),
  };
}

/// The user's first name from their Google profile [metadata]
/// (`full_name`/`name`), falling back to the local part of [email], or
/// null if neither is available.
String? firstNameFrom({Map<String, dynamic>? metadata, String? email}) {
  final fullName =
      metadata?['full_name'] as String? ?? metadata?['name'] as String?;
  if (fullName != null && fullName.trim().isNotEmpty) {
    return fullName.trim().split(' ').first;
  }
  final localPart = email?.split('@').first;
  return (localPart == null || localPart.isEmpty) ? null : localPart;
}
