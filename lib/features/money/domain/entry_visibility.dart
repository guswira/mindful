import 'package:json_annotation/json_annotation.dart';

/// Whether a linked partner sees a spending entry. See SPEC.md Money Flow
/// Feature Linked partner.
///
/// Shared spending shows on the partner's Money tab and counts toward both
/// people's budgets; private spending stays with its owner. Income is
/// always private.
enum EntryVisibility {
  @JsonValue('shared')
  shared,
  @JsonValue('private')
  private,
}
