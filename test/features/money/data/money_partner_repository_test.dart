import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mindful/features/money/data/money_partner_repository.dart';
import 'package:mindful/features/money/data/money_repository.dart';
import 'package:mindful/features/money/domain/budget_settings.dart';
import 'package:mindful/features/money/domain/budget_type.dart';
import 'package:mindful/features/money/domain/entry_type.dart';
import 'package:mindful/features/money/domain/entry_visibility.dart';
import 'package:mindful/features/money/domain/money_partner.dart';

import '../money_partner_fakes.dart';

class _MockBox extends Mock implements Box<dynamic> {}

void main() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  late FakeMoneyPartnerDatasource datasource;
  late MoneyPartnerRepository repository;

  setUp(() async {
    datasource = FakeMoneyPartnerDatasource();
    repository = await openTestPartnerRepository(datasource);
  });

  tearDown(() => Hive.deleteFromDisk());

  test('not linked: no partner and no entries', () async {
    await repository.refresh();
    expect(repository.getPartner(), isNull);
    expect(repository.getEntries(), isEmpty);
  });

  test('refresh caches the partner and only their shared spending', () async {
    datasource
      ..partner = testPartner
      ..partnerEntries = [
        partnerEntry('a', 10, today),
        partnerEntry('b', 20, today, visibility: EntryVisibility.private),
        partnerEntry('c', 30, today, type: EntryType.income),
      ];

    await repository.refresh();

    expect(repository.getPartner()?.name, 'Ayu Lestari');
    expect(repository.getEntries().map((e) => e.id), ['a']);
  });

  test('a link removed on the other phone clears the cache', () async {
    datasource
      ..partner = testPartner
      ..partnerEntries = [partnerEntry('a', 10, today)];
    await repository.refresh();

    datasource.partner = null;
    await repository.refresh();

    expect(repository.getPartner(), isNull);
    expect(repository.getEntries(), isEmpty);
  });

  test('accepting a code links and loads the partner', () async {
    datasource
      ..partnerForInvite = testPartner
      ..partnerEntries = [partnerEntry('a', 10, today)];

    await repository.acceptInvite('A1B2C3D4');

    expect(datasource.acceptedCodes, ['A1B2C3D4']);
    expect(repository.getPartner()?.id, 'p1');
    expect(repository.getEntries(), hasLength(1));
  });

  test('a refused code throws and links nothing', () async {
    datasource.acceptError = MoneyLinkError.ownCode;

    await expectLater(
      repository.acceptInvite('A1B2C3D4'),
      throwsA(
        isA<MoneyLinkException>().having(
          (e) => e.error,
          'error',
          MoneyLinkError.ownCode,
        ),
      ),
    );
    expect(repository.getPartner(), isNull);
  });

  test('unlink forgets the partner and their spending', () async {
    datasource
      ..partner = testPartner
      ..partnerEntries = [partnerEntry('a', 10, today)];
    await repository.refresh();

    await repository.unlink();

    expect(datasource.unlinked, isTrue);
    expect(repository.getPartner(), isNull);
    expect(repository.getEntries(), isEmpty);
  });

  test('shared spending lowers both budgets; private stays out', () async {
    datasource
      ..partner = testPartner
      ..partnerEntries = [partnerEntry('a', 150, today)];
    await repository.refresh();
    final entriesBox = _MockBox();
    final settingsBox = _MockBox();
    when(() => entriesBox.values).thenReturn([
      partnerEntry('mine', 100, today, userId: 'u1').toJson(),
      partnerEntry(
        'mine-private',
        50,
        today,
        userId: 'u1',
        visibility: EntryVisibility.private,
      ).toJson(),
    ]);
    when(() => settingsBox.get('settings_daily')).thenReturn(
      BudgetSettings(
        id: 'b1',
        userId: 'u1',
        budgetType: BudgetType.daily,
        amount: 1000,
        currency: 'IDR',
        updatedAt: today,
      ).toJson(),
    );
    final money = MoneyRepository(
      entriesBox: entriesBox,
      settingsBox: settingsBox,
      partner: repository,
    );

    // Mine count in full (shared or private); the partner's shared 150 too.
    expect(money.getRemaining(BudgetType.daily), 1000 - 100 - 50 - 150);
  });
}
