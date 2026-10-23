import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import 'package:mindful/core/l10n/date_symbols_subset.dart';

void main() {
  setUpAll(initializeAppDateFormatting);

  final date = DateTime(2026, 10, 26);

  test('formats dates in Bahasa Indonesia', () {
    expect(DateFormat('EEEE, d MMMM', 'id').format(date), 'Senin, 26 Oktober');
  });

  test('formats dates in English', () {
    expect(DateFormat('EEEE, MMMM d', 'en').format(date), 'Monday, October 26');
    expect(DateFormat.yMMMd('en_US').format(date), 'Oct 26, 2026');
  });
}
