import 'package:flutter/material.dart';

import '../../../core/constants/layout.dart';
import '../../../core/l10n/l10n.dart';
import '../../../shared/widgets/blob_background.dart';
import 'list_detail_layout.dart';
import 'plan_list.dart';

/// Tasks and routines (habits) on one page: today's routines first, since
/// they repeat every day, then the grouped task list. Home and the home
/// screen widgets still show them separately; adding goes through the nav
/// bar's write button. See SPEC.md Tasks & Routines.
///
/// On a tablet or in landscape a tapped task or routine opens in a detail
/// pane beside the list — see [ListDetailLayout].
class PlanTab extends StatelessWidget {
  const PlanTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RepaintBoundary(
        child: BlobBackground(
          maxContentWidth: AppLayout.listDetailMaxWidth(context),
          child: SafeArea(
            child: Column(
              children: [
                const _PlanHeader(),
                Expanded(
                  child: ListDetailLayout(
                    listBuilder: (padding) => PlanList(padding: padding),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlanHeader extends StatelessWidget {
  const _PlanHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          context.l10n.planTabTitle,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
