import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/shared/services/quote_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'loadQuotes parses every bundled quote with a non-empty author',
    () async {
      final service = QuoteService();

      final quotes = await service.loadQuotes();

      expect(quotes, isNotEmpty);
      for (final quote in quotes) {
        expect(quote.quote, isNotEmpty);
        expect(quote.author, isNotEmpty);
      }
    },
  );

  test('dailyQuote is stable for the same day', () async {
    final service = QuoteService(now: () => DateTime(2026, 3, 5));

    final first = await service.dailyQuote();
    final second = await service.dailyQuote();

    expect(second, first);
  });

  test('dailyQuote changes on a different day', () async {
    final quotesLength = await QuoteService().loadQuotes().then(
      (q) => q.length,
    );
    // Pick two days whose day-of-year values land on different indices —
    // guaranteed as long as the bundle has more than one quote.
    final today = QuoteService(now: () => DateTime(2026, 1, 1));
    final tomorrow = QuoteService(now: () => DateTime(2026, 1, 2));

    final quoteToday = await today.dailyQuote();
    final quoteTomorrow = await tomorrow.dailyQuote();

    expect(quotesLength, greaterThan(1));
    expect(quoteToday, isNot(quoteTomorrow));
  });

  test('dailyQuote wraps around once every quote has been used', () async {
    final quotesLength = await QuoteService().loadQuotes().then(
      (q) => q.length,
    );
    final start = DateTime(2026);
    final firstDay = QuoteService(now: () => start);
    final wrappedDay = QuoteService(
      now: () => start.add(Duration(days: quotesLength)),
    );

    final firstQuote = await firstDay.dailyQuote();
    final wrappedQuote = await wrappedDay.dailyQuote();

    expect(wrappedQuote, firstQuote);
  });
}
