import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/quote.dart';

part 'quote_service.g.dart';

/// Loads the bundled quote list and picks the quote of the day.
class QuoteService {
  QuoteService({DateTime Function() now = DateTime.now}) : _now = now;

  final DateTime Function() _now;

  List<Quote>? _cache;

  /// Loads and caches the quotes bundled in `assets/quotes.json`.
  Future<List<Quote>> loadQuotes() async {
    final cached = _cache;
    if (cached != null) return cached;

    final json = await rootBundle.loadString('assets/quotes.json');
    final data = jsonDecode(json) as Map<String, dynamic>;
    final quotes = (data['quotes'] as List)
        .map((e) => Quote.fromJson(e as Map<String, dynamic>))
        .toList();
    _cache = quotes;
    return quotes;
  }

  /// The quote for today, stable for the whole day and changing at midnight.
  Future<Quote> dailyQuote() async {
    final quotes = await loadQuotes();
    final now = _now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    return quotes[dayOfYear % quotes.length];
  }
}

/// The app-wide [QuoteService].
@riverpod
QuoteService quoteService(Ref ref) => QuoteService();

/// The quote of the day, sourced from [quoteServiceProvider].
@riverpod
Future<Quote> dailyQuote(Ref ref) {
  return ref.watch(quoteServiceProvider).dailyQuote();
}
