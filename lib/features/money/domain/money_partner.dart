/// The account this user's money is linked with — at most one. Name and
/// email are copied from the partner's Google profile when the link is
/// made. See SPEC.md Money Flow Feature Linked partner.
class MoneyPartner {
  const MoneyPartner({
    required this.id,
    required this.name,
    required this.email,
    required this.linkedAt,
  });

  /// Reads a `money_links` row (or its Hive copy).
  factory MoneyPartner.fromJson(Map<String, dynamic> json) {
    final email = json['partner_email'] as String? ?? '';
    final name = json['partner_name'] as String?;
    return MoneyPartner(
      id: json['partner_id'] as String,
      name: name == null || name.isEmpty ? email : name,
      email: email,
      linkedAt: DateTime.parse(json['created_at'] as String),
    );
  }

  final String id;

  /// Display name — the email when the profile has no name.
  final String name;
  final String email;

  /// When the link was made; the partner only sees shared spending
  /// created after it.
  final DateTime linkedAt;

  /// The name's first word ("Ayu" from "Ayu Lestari"), for tight labels.
  String get firstName {
    final first = name.trim().split(RegExp(r'\s+')).first;
    return first.isEmpty ? name : first;
  }

  /// Serializes back to the `money_links` row shape.
  Map<String, dynamic> toJson() => {
    'partner_id': id,
    'partner_name': name,
    'partner_email': email,
    'created_at': linkedAt.toIso8601String(),
  };
}

/// Why linking with a code failed.
enum MoneyLinkError {
  /// Unknown or expired code.
  invalidCode,

  /// The user scanned their own code.
  ownCode,

  /// One of the two accounts is already linked.
  alreadyLinked,

  /// Anything else (offline, server error).
  unknown,
}

/// Thrown by linking when the code can't be used.
class MoneyLinkException implements Exception {
  const MoneyLinkException(this.error);

  final MoneyLinkError error;

  @override
  String toString() => 'MoneyLinkException($error)';
}

/// A one-time code another phone scans to link with this account.
class MoneyLinkInvite {
  const MoneyLinkInvite({required this.code, required this.expiresAt});

  /// 8 characters, shown as "A1B2-C3D4".
  final String code;
  final DateTime expiresAt;

  /// What the QR code holds.
  String get qrData => '$qrPrefix$code';

  /// [code] grouped in fours for reading aloud / typing.
  String get displayCode =>
      code.length == 8 ? '${code.substring(0, 4)}-${code.substring(4)}' : code;

  /// Marks a Mindful link QR, so a random QR code is ignored.
  static const String qrPrefix = 'mindful-link:';

  /// The code inside a scanned QR or typed text, normalized (upper case,
  /// no dash or spaces) — null when it can't be a link code.
  static String? parseCode(String raw) {
    var text = raw.trim();
    if (text.startsWith(qrPrefix)) {
      text = text.substring(qrPrefix.length);
    }
    final code = text.toUpperCase().replaceAll(RegExp(r'[\s-]'), '');
    return RegExp(r'^[0-9A-F]{8}$').hasMatch(code) ? code : null;
  }
}
