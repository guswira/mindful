import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/glass_theme.dart';
import 'floating_nav_write_button.dart';

/// Island nav bar (4 tabs) + write button, replacing the standard bottom
/// nav bar entirely. See SPEC.md Floating Island Nav Bar.
class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({
    required this.currentIndex,
    required this.onTabChanged,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        child: Row(
          children: [
            Expanded(
              child: _NavIsland(
                currentIndex: currentIndex,
                onTabChanged: onTabChanged,
              ),
            ),
            const SizedBox(width: 10),
            const WriteButton(),
          ],
        ),
      ),
    );
  }
}

class _NavIsland extends StatelessWidget {
  const _NavIsland({required this.currentIndex, required this.onTabChanged});

  final int currentIndex;
  final ValueChanged<int> onTabChanged;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final l10n = context.l10n;
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.18),
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: _NavItem(
                  icon: Icons.home_outlined,
                  label: l10n.navHome,
                  active: currentIndex == 0,
                  activeColor: glass.homeAccent,
                  onTap: () => onTabChanged(0),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.checklist_outlined,
                  label: l10n.navTasks,
                  active: currentIndex == 1,
                  activeColor: glass.taskAccent,
                  onTap: () => onTabChanged(1),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.calendar_month_outlined,
                  label: l10n.navHabits,
                  active: currentIndex == 2,
                  activeColor: glass.habitAccent,
                  onTap: () => onTabChanged(2),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.menu_book_outlined,
                  label: l10n.navJournal,
                  active: currentIndex == 3,
                  activeColor: glass.journalAccent,
                  onTap: () => onTabChanged(3),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.account_balance_wallet_outlined,
                  label: l10n.navMoney,
                  active: currentIndex == 4,
                  activeColor: glass.moneyAccent,
                  onTap: () => onTabChanged(4),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.auto_awesome_outlined,
                  label: l10n.navAi,
                  active: currentIndex == 5,
                  activeColor: glass.aiAccent,
                  onTap: () => onTabChanged(5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.activeColor,
    required this.onTap,
  });

  final IconData icon;

  /// Screen-reader name for the tab — the island shows icons only.
  final String label;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? activeColor : Colors.white.withValues(alpha: 0.28);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color, semanticLabel: label),
          const SizedBox(height: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: active ? 16 : 4,
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: active ? activeColor : Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }
}
