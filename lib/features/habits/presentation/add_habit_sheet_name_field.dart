import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../shared/widgets/shake_widget.dart';

/// The habit name field inside [AddHabitSheet], shaking via [shakeKey]
/// when saved empty.
class HabitNameField extends StatelessWidget {
  const HabitNameField({
    required this.shakeKey,
    required this.controller,
    super.key,
  });

  final GlobalKey<ShakeWidgetState> shakeKey;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return ShakeWidget(
      key: shakeKey,
      child: TextField(
        controller: controller,
        autofocus: true,
        cursorColor: glass.habitAccent,
        textInputAction: TextInputAction.next,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          hintText: context.l10n.habitNameHint,
          hintStyle: TextStyle(color: glass.textHint),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
