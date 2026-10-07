import 'package:flutter/material.dart';

import '../../../core/constants/layout.dart';
import '../../../core/constants/spacing.dart';
import '../../../shared/widgets/detail_selection.dart';
import 'detail_pane.dart';

/// A tab's scrolling list, plus — on a tablet or in landscape
/// ([AppLayout.isTwoPane]) — a [DetailPane] beside it that tapped tasks
/// and routines open in, instead of a sheet or page. Used by the Home and
/// Tasks & Routines tabs.
class ListDetailLayout extends StatefulWidget {
  const ListDetailLayout({
    required this.listBuilder,
    this.padding = defaultPadding,
    super.key,
  });

  /// The list, given the padding to use: [padding] on its own, without the
  /// right edge when the pane sits beside it.
  final Widget Function(EdgeInsets padding) listBuilder;

  /// The tab's list padding. The pane gets the same top and bottom, so its
  /// card lines up with the list's first item and clears the nav bar too.
  final EdgeInsets padding;

  /// Tasks & Routines' list padding — 88 at the bottom clears the nav bar.
  static const EdgeInsets defaultPadding = EdgeInsets.fromLTRB(20, 4, 20, 88);

  @override
  State<ListDetailLayout> createState() => _ListDetailLayoutState();
}

class _ListDetailLayoutState extends State<ListDetailLayout> {
  /// Kept while switching tabs (the shell keeps tabs alive) and while the
  /// window is narrowed or the device rotated, so going wide again brings
  /// the same item back.
  DetailSelection? _selection;

  void _select(DetailSelection selection) =>
      setState(() => _selection = selection);

  void _clear() => setState(() => _selection = null);

  @override
  Widget build(BuildContext context) {
    if (!AppLayout.isTwoPane(context)) {
      return widget.listBuilder(widget.padding);
    }
    final separator = AppLayout.verticalSeparator(context);
    return separator == null
        ? _buildSideBySide()
        : LayoutBuilder(
            builder: (context, constraints) =>
                _buildAroundSeparator(context, constraints, separator),
          );
  }

  /// The list, telling its rows to open items in the pane.
  Widget _buildList(EdgeInsets padding) => DetailSelectionScope(
    selected: _selection,
    onSelect: _select,
    child: widget.listBuilder(padding),
  );

  Widget _buildPane(EdgeInsets padding) => Padding(
    padding: padding,
    child: DetailPane(selection: _selection, onCleared: _clear),
  );

  /// One continuous screen: list ~3/5, details ~2/5.
  Widget _buildSideBySide() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: _buildList(widget.padding.copyWith(right: 0))),
        const SizedBox(width: Spacing.md),
        Expanded(flex: 2, child: _buildPane(widget.padding.copyWith(left: 0))),
      ],
    );
  }

  /// A screen split by a hinge or half-open fold: the list fills the left
  /// half and the details the right, so nothing sits under the split.
  ///
  /// [separator] is in screen coordinates; this layout spans the window
  /// (AppLayout.listDetailMaxWidth) and any safe-area inset is symmetric,
  /// so its left edge sits half the leftover width in.
  Widget _buildAroundSeparator(
    BuildContext context,
    BoxConstraints constraints,
    Rect separator,
  ) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final left = (screenWidth - constraints.maxWidth) / 2;
    final listWidth = (separator.left - left).clamp(0.0, constraints.maxWidth);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: listWidth, child: _buildList(widget.padding)),
        SizedBox(width: separator.width),
        Expanded(child: _buildPane(widget.padding)),
      ],
    );
  }
}
