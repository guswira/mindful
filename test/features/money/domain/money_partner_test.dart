import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/features/money/domain/money_partner.dart';

void main() {
  group('MoneyLinkInvite.parseCode', () {
    test('reads a scanned QR, a dashed or lower-case typed code', () {
      expect(MoneyLinkInvite.parseCode('mindful-link:A1B2C3D4'), 'A1B2C3D4');
      expect(MoneyLinkInvite.parseCode(' a1b2-c3d4 '), 'A1B2C3D4');
    });

    test('rejects anything that is not an 8-hex code', () {
      expect(MoneyLinkInvite.parseCode('https://example.com'), isNull);
      expect(MoneyLinkInvite.parseCode('A1B2C3'), isNull);
      expect(MoneyLinkInvite.parseCode('ZZZZZZZZ'), isNull);
    });
  });

  test('the invite shows its code in two groups and encodes the prefix', () {
    final invite = MoneyLinkInvite(code: 'A1B2C3D4', expiresAt: DateTime(2026));
    expect(invite.displayCode, 'A1B2-C3D4');
    expect(MoneyLinkInvite.parseCode(invite.qrData), 'A1B2C3D4');
  });

  test('a partner without a profile name goes by their email', () {
    final partner = MoneyPartner.fromJson({
      'partner_id': 'p1',
      'partner_name': null,
      'partner_email': 'ayu@example.com',
      'created_at': '2026-11-01T00:00:00Z',
    });
    expect(partner.name, 'ayu@example.com');
    expect(MoneyPartner.fromJson(partner.toJson()).linkedAt, partner.linkedAt);
  });

  test('firstName is the first word of the name', () {
    final partner = MoneyPartner(
      id: 'p1',
      name: 'Ayu Lestari',
      email: 'ayu@example.com',
      linkedAt: DateTime(2026),
    );
    expect(partner.firstName, 'Ayu');
  });
}
