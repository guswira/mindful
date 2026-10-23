import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/glass_style.dart';
import '../../../core/theme/glass_style_controller.dart';

/// The name of [style] in the app language.
String glassStyleLabel(AppLocalizations l10n, GlassStyle style) =>
    switch (style) {
      GlassStyle.liquid => l10n.settingsGlassStyleLiquid,
      GlassStyle.frosted => l10n.settingsGlassStyleFrosted,
    };

String _glassStyleBody(AppLocalizations l10n, GlassStyle style) =>
    switch (style) {
      GlassStyle.liquid => l10n.settingsGlassStyleLiquidBody,
      GlassStyle.frosted => l10n.settingsGlassStyleFrostedBody,
    };

/// Settings row for the glass style; tap → a sheet with both styles, and
/// picking one restyles the whole app at once (and persists it).
class GlassStyleSection extends ConsumerWidget {
  const GlassStyleSection({super.key});

  Future<void> _pick(BuildContext context, WidgetRef ref) async {
    final current = ref.read(glassStyleControllerProvider);
    final picked = await showModalBottomSheet<GlassStyle>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final style in GlassStyle.values)
              _GlassStyleOption(
                style: style,
                selected: style == current,
                onTap: () => Navigator.pop(context, style),
              ),
          ],
        ),
      ),
    );
    if (picked == null || picked == current) return;
    await ref.read(glassStyleControllerProvider.notifier).select(picked);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final style = ref.watch(glassStyleControllerProvider);
    return ListTile(
      leading: const Icon(Icons.blur_on_rounded),
      title: Text(context.l10n.settingsGlassStyleTitle),
      subtitle: Text(glassStyleLabel(context.l10n, style)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _pick(context, ref),
    );
  }
}

class _GlassStyleOption extends StatelessWidget {
  const _GlassStyleOption({
    required this.style,
    required this.selected,
    required this.onTap,
  });

  final GlassStyle style;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListTile(
      leading: Icon(switch (style) {
        GlassStyle.liquid => Icons.water_drop_outlined,
        GlassStyle.frosted => Icons.blur_on_rounded,
      }),
      title: Text(glassStyleLabel(l10n, style)),
      subtitle: Text(_glassStyleBody(l10n, style)),
      trailing: selected ? const Icon(Icons.check) : null,
      selected: selected,
      onTap: onTap,
    );
  }
}
