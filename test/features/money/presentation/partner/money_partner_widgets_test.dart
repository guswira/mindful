import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mindful/core/theme/app_theme.dart';
import 'package:mindful/features/auth/domain/auth_state.dart';
import 'package:mindful/features/money/data/money_partner_repository.dart';
import 'package:mindful/features/money/data/money_repository.dart';
import 'package:mindful/features/money/domain/entry_visibility.dart';
import 'package:mindful/features/money/domain/money_entry.dart';
import 'package:mindful/features/money/domain/money_partner.dart';
import 'package:mindful/features/money/presentation/add_money_sheet.dart';
import 'package:mindful/features/money/presentation/partner/link_scan_view.dart';
import 'package:mindful/features/money/presentation/widgets/entry_list.dart';
import 'package:mindful/features/money/presentation/widgets/partner_spending_card.dart';
import 'package:mindful/shared/services/widget_service.dart';
import 'package:mindful/shared/widgets/tinted_pill.dart';

import '../../money_partner_fakes.dart';

class _MockBox extends Mock implements Box<dynamic> {}

class _MockSecureStorage extends Mock implements FlutterSecureStorage {}

class _MockWidgetService extends Mock implements WidgetService {}

/// The partner repository without Hive: answers from memory.
class _FakePartnerRepository extends MoneyPartnerRepository {
  _FakePartnerRepository({this.partner, this.entries = const []})
    : super(partnerBox: _MockBox(), entriesBox: _MockBox());

  MoneyPartner? partner;
  List<MoneyEntry> entries;
  MoneyLinkError? refuseWith;
  final accepted = <String>[];

  @override
  MoneyPartner? getPartner() => partner;

  @override
  List<MoneyEntry> getEntries({DateTimeRange? range}) =>
      partner == null ? const [] : entries;

  @override
  Future<void> refresh() async {}

  @override
  Future<void> acceptInvite(String code) async {
    accepted.add(code);
    if (refuseWith case final error?) throw MoneyLinkException(error);
    partner = testPartner;
  }
}

void main() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  late _MockBox entriesBox;
  late _MockBox settingsBox;
  late _MockSecureStorage storage;

  setUp(() {
    entriesBox = _MockBox();
    settingsBox = _MockBox();
    storage = _MockSecureStorage();
    when(() => entriesBox.values).thenReturn(const <dynamic>[]);
    when(() => settingsBox.get(any())).thenReturn(null);
    when(
      () => storage.read(key: any(named: 'key')),
    ).thenAnswer((_) async => null);
  });

  Widget build(Widget child, _FakePartnerRepository partners) => ProviderScope(
    overrides: [
      moneyRepositoryProvider.overrideWith(
        (ref) async => MoneyRepository(
          entriesBox: entriesBox,
          settingsBox: settingsBox,
          storage: storage,
          partner: partners,
        ),
      ),
      moneyPartnerRepositoryProvider.overrideWith((ref) async => partners),
      currentUserIdProvider.overrideWithValue('u1'),
      widgetServiceProvider.overrideWith((ref) async {
        final service = _MockWidgetService();
        when(() => service.updateWidgetData()).thenAnswer((_) async {});
        return service;
      }),
    ],
    child: MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: SingleChildScrollView(child: child)),
    ),
  );

  group('AddMoneySheet', () {
    Future<MoneyEntry> saveSpending(
      WidgetTester tester,
      _FakePartnerRepository partners, {
      String? tap,
    }) async {
      await tester.binding.setSurfaceSize(const Size(400, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      when(() => entriesBox.put(any(), any())).thenAnswer((_) async {});
      await tester.pumpWidget(build(const AddMoneySheet(), partners));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, '5000');
      if (tap != null) {
        await tester.tap(find.text(tap));
        await tester.pump();
      }
      await tester.tap(find.widgetWithText(TintedPill, 'Save'));
      await tester.pump();
      final captured = verify(
        () => entriesBox.put(any(), captureAny()),
      ).captured;
      return MoneyEntry.fromJson(
        Map<String, dynamic>.from(captured.last as Map),
      );
    }

    testWidgets('not linked: no picker, spending saved private', (
      tester,
    ) async {
      final saved = await saveSpending(tester, _FakePartnerRepository());
      expect(find.text('Who sees it'), findsNothing);
      expect(saved.visibility, EntryVisibility.private);
    });

    testWidgets('linked: spending defaults to shared', (tester) async {
      final saved = await saveSpending(
        tester,
        _FakePartnerRepository(partner: testPartner),
      );
      expect(saved.visibility, EntryVisibility.shared);
    });

    testWidgets('linked: Private keeps it to yourself', (tester) async {
      final saved = await saveSpending(
        tester,
        _FakePartnerRepository(partner: testPartner),
        tap: 'Private',
      );
      expect(saved.visibility, EntryVisibility.private);
    });
  });

  group('EntryList', () {
    testWidgets('together shows both; "You" hides the partner\'s', (
      tester,
    ) async {
      when(
        () => entriesBox.values,
      ).thenReturn([partnerEntry('mine', 10, today, userId: 'u1').toJson()]);
      final partners = _FakePartnerRepository(
        partner: testPartner,
        entries: [partnerEntry('theirs', 25, today)],
      );
      await tester.pumpWidget(build(const EntryList(), partners));
      await tester.pumpAndSettle();

      expect(find.text('Together'), findsOneWidget);
      expect(find.text('-10.00'), findsOneWidget);
      expect(find.text('-25.00'), findsOneWidget);
      // The day header totals both.
      expect(find.text('-35.00'), findsOneWidget);
      // The partner's entry names them; their initial badges the icon.
      expect(find.textContaining('Ayu'), findsWidgets);

      await tester.tap(find.text('You'));
      await tester.pumpAndSettle();
      expect(find.text('-25.00'), findsNothing);

      await tester.tap(find.text('Ayu'));
      await tester.pumpAndSettle();
      expect(find.text('-10.00'), findsNothing);
      expect(find.text('-25.00'), findsWidgets);
    });

    testWidgets('not linked: no scope pills', (tester) async {
      when(
        () => entriesBox.values,
      ).thenReturn([partnerEntry('mine', 10, today, userId: 'u1').toJson()]);
      await tester.pumpWidget(
        build(const EntryList(), _FakePartnerRepository()),
      );
      await tester.pumpAndSettle();
      expect(find.text('Together'), findsNothing);
    });
  });

  testWidgets('PartnerSpendingCard adds both sides up', (tester) async {
    when(
      () => entriesBox.values,
    ).thenReturn([partnerEntry('mine', 100, today, userId: 'u1').toJson()]);
    final partners = _FakePartnerRepository(
      partner: testPartner,
      entries: [partnerEntry('theirs', 50, today)],
    );
    await tester.pumpWidget(build(const PartnerSpendingCard(), partners));
    await tester.pumpAndSettle();

    expect(find.text('With Ayu · this month'), findsOneWidget);
    expect(find.text('100.00'), findsOneWidget);
    expect(find.text('50.00'), findsOneWidget);
    expect(find.text('150.00'), findsOneWidget);
  });

  group('LinkScanView (typed code, no camera off phones)', () {
    final desktop = TargetPlatformVariant.only(TargetPlatform.macOS);

    testWidgets('a malformed code is refused before asking Supabase', (
      tester,
    ) async {
      final partners = _FakePartnerRepository();
      await tester.pumpWidget(build(const LinkScanView(), partners));
      await tester.enterText(find.byType(TextField), 'hello');
      await tester.tap(find.text('Link'));
      await tester.pump();

      expect(partners.accepted, isEmpty);
      expect(find.textContaining('wrong or has expired'), findsOneWidget);
    }, variant: desktop);

    testWidgets('the server refusing shows why', (tester) async {
      final partners = _FakePartnerRepository()
        ..refuseWith = MoneyLinkError.alreadyLinked;
      await tester.pumpWidget(build(const LinkScanView(), partners));
      await tester.enterText(find.byType(TextField), 'a1b2-c3d4');
      await tester.tap(find.text('Link'));
      await tester.pumpAndSettle();

      expect(partners.accepted, ['A1B2C3D4']);
      expect(find.textContaining('already linked'), findsOneWidget);
    }, variant: desktop);
  });
}
