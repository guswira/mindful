import 'package:flutter/material.dart';

import '../../core/l10n/l10n.dart';

/// The title row shared by every add/edit bottom sheet: bold white title
/// text, a spacer, and a close (X) button. See the bottom-sheet design
/// rules.
class SheetHeader extends StatelessWidget {
  const SheetHeader({required this.title, required this.onClose, super.key});

  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.close),
          tooltip: context.l10n.commonClose,
          onPressed: onClose,
        ),
      ],
    );
  }
}
