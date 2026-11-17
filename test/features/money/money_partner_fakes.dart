import 'dart:io';

import 'package:hive_ce/hive.dart';

import 'package:mindful/features/money/data/money_partner_repository.dart';
import 'package:mindful/features/money/data/supabase_money_partner_datasource.dart';
import 'package:mindful/features/money/domain/entry_type.dart';
import 'package:mindful/features/money/domain/entry_visibility.dart';
import 'package:mindful/features/money/domain/money_entry.dart';
import 'package:mindful/features/money/domain/money_partner.dart';

/// In-memory stand-in for Supabase's link tables and the partner's rows.
class FakeMoneyPartnerDatasource extends SupabaseMoneyPartnerDatasource {
  MoneyPartner? partner;
  List<MoneyEntry> partnerEntries = [];

  /// The partner [acceptInvite] links with; null → it throws [acceptError].
  MoneyPartner? partnerForInvite;
  MoneyLinkError acceptError = MoneyLinkError.invalidCode;
  final acceptedCodes = <String>[];
  var unlinked = false;

  @override
  Future<MoneyPartner?> getPartner() async => partner;

  @override
  Future<MoneyLinkInvite> createInvite() async => MoneyLinkInvite(
    code: 'A1B2C3D4',
    expiresAt: DateTime.now().add(const Duration(minutes: 10)),
  );

  @override
  Future<void> acceptInvite(String code) async {
    acceptedCodes.add(code);
    final linked = partnerForInvite;
    if (linked == null) throw MoneyLinkException(acceptError);
    partner = linked;
  }

  @override
  Future<void> unlink() async {
    unlinked = true;
    partner = null;
  }

  @override
  Future<List<MoneyEntry>> getPartnerEntries(String partnerId) async =>
      partnerEntries;
}

final testPartner = MoneyPartner(
  id: 'p1',
  name: 'Ayu Lestari',
  email: 'ayu@example.com',
  linkedAt: DateTime(2026, 11),
);

/// A spending entry (by default the partner's, shared) dated [date].
MoneyEntry partnerEntry(
  String id,
  double amount,
  DateTime date, {
  String userId = 'p1',
  EntryType type = EntryType.spending,
  EntryVisibility visibility = EntryVisibility.shared,
}) => MoneyEntry(
  id: id,
  userId: userId,
  type: type,
  amount: amount,
  category: 'Food',
  date: date,
  createdAt: date,
  updatedAt: date,
  visibility: visibility,
);

/// Real Hive boxes in a temp dir, wrapped in a repository on [datasource].
Future<MoneyPartnerRepository> openTestPartnerRepository(
  FakeMoneyPartnerDatasource datasource,
) async {
  Hive.init(Directory.systemTemp.createTempSync('money_partner').path);
  return MoneyPartnerRepository(
    partnerBox: await Hive.openBox<dynamic>(
      MoneyPartnerRepository.partnerBoxName,
    ),
    entriesBox: await Hive.openBox<dynamic>(
      MoneyPartnerRepository.entriesBoxName,
    ),
    datasource: datasource,
  );
}
