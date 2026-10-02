import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import 'custom_background_controller.dart';

enum _BackgroundAction { pick, reset }

/// Settings row for the app background: shows the current photo (or the
/// default) and opens a sheet to pick a gallery photo or reset.
class BackgroundSection extends ConsumerWidget {
  const BackgroundSection({super.key});

  Future<void> _chooseAction(
    BuildContext context,
    WidgetRef ref,
    bool hasCustom,
  ) async {
    final l10n = context.l10n;
    final action = await showModalBottomSheet<_BackgroundAction>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.settingsBackgroundChoose),
              onTap: () => Navigator.pop(context, _BackgroundAction.pick),
            ),
            if (hasCustom)
              ListTile(
                leading: const Icon(Icons.restart_alt),
                title: Text(l10n.settingsBackgroundReset),
                onTap: () => Navigator.pop(context, _BackgroundAction.reset),
              ),
          ],
        ),
      ),
    );
    if (action == null || !context.mounted) return;
    await _apply(context, ref, action);
  }

  Future<void> _apply(
    BuildContext context,
    WidgetRef ref,
    _BackgroundAction action,
  ) async {
    final controller = ref.read(customBackgroundControllerProvider.notifier);
    try {
      final changed = switch (action) {
        _BackgroundAction.pick => await controller.pickFromGallery(),
        _BackgroundAction.reset => await controller.reset().then((_) => true),
      };
      if (!changed || !context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.settingsBackgroundUpdated)),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.settingsBackgroundError('$error'))),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final path = ref.watch(customBackgroundControllerProvider).valueOrNull;
    return ListTile(
      leading: _Thumbnail(path: path),
      title: Text(l10n.settingsBackgroundTitle),
      subtitle: Text(
        path == null
            ? l10n.settingsBackgroundDefault
            : l10n.settingsBackgroundCustom,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _chooseAction(context, ref, path != null),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.path});

  final String? path;

  static const double _size = 40;

  @override
  Widget build(BuildContext context) {
    final path = this.path;
    if (path == null) return const Icon(Icons.wallpaper_outlined);
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.file(
        File(path),
        width: _size,
        height: _size,
        fit: BoxFit.cover,
        // Thumbnail-sized decode instead of the full photo.
        cacheWidth: (_size * MediaQuery.devicePixelRatioOf(context)).round(),
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.wallpaper_outlined),
      ),
    );
  }
}
