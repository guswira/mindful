import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/supabase_constants.dart';
import '../domain/money_entry.dart';
import '../domain/money_partner.dart';

/// The linked-partner calls: invite codes, linking, unlinking and the
/// partner's shared spending. The link tables are written only by the
/// SQL functions in SPEC.md Money Flow Feature Linked partner, never
/// directly.
class SupabaseMoneyPartnerDatasource {
  SupabaseMoneyPartnerDatasource({SupabaseClient? client})
    : _clientOverride = client;

  final SupabaseClient? _clientOverride;

  // Lazy, so constructing this doesn't need Supabase.initialize() (tests).
  SupabaseClient get _client => _clientOverride ?? Supabase.instance.client;

  /// The signed-in user's partner, or null when not linked.
  Future<MoneyPartner?> getPartner() async {
    final row = await _client
        .from(SupabaseConstants.moneyLinksTable)
        .select()
        .maybeSingle();
    return row == null ? null : MoneyPartner.fromJson(row);
  }

  /// A fresh invite code (valid 10 minutes); replaces any earlier one.
  Future<MoneyLinkInvite> createInvite() async {
    final json = await _client.rpc<dynamic>('create_money_link_invite');
    final map = json as Map<String, dynamic>;
    return MoneyLinkInvite(
      code: map['code'] as String,
      expiresAt: DateTime.parse(map['expires_at'] as String).toLocal(),
    );
  }

  /// Links with the account that showed [code].
  ///
  /// Throws [MoneyLinkException] — the SQL function raises a named error
  /// for each reason it refuses.
  Future<void> acceptInvite(String code) async {
    try {
      await _client.rpc<dynamic>(
        'accept_money_link',
        params: {'invite_code': code},
      );
    } on PostgrestException catch (error) {
      throw MoneyLinkException(switch (error.message) {
        final m when m.contains('invite_invalid') => MoneyLinkError.invalidCode,
        final m when m.contains('invite_own') => MoneyLinkError.ownCode,
        final m when m.contains('already_linked') =>
          MoneyLinkError.alreadyLinked,
        _ => MoneyLinkError.unknown,
      });
    }
  }

  /// Removes the link for both accounts.
  Future<void> unlink() => _client.rpc<dynamic>('unlink_money_partner');

  /// [partnerId]'s spending this user may see — RLS lets only their
  /// shared spending created since the link through.
  Future<List<MoneyEntry>> getPartnerEntries(String partnerId) async {
    final rows = await _client
        .from(SupabaseConstants.moneyEntriesTable)
        .select()
        .eq('user_id', partnerId)
        .order('date', ascending: false)
        .order('created_at', ascending: false);
    return [for (final row in rows) MoneyEntry.fromJson(row)];
  }
}
