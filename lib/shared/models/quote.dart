import 'package:freezed_annotation/freezed_annotation.dart';

part 'quote.freezed.dart';
part 'quote.g.dart';

/// A single quote shown on the home screen.
@freezed
abstract class Quote with _$Quote {
  const factory Quote({required String quote, required String author}) = _Quote;

  factory Quote.fromJson(Map<String, dynamic> json) => _$QuoteFromJson(json);
}
