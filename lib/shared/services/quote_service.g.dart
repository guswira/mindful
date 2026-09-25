// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quote_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$quoteServiceHash() => r'b566a8362c9f0a4cea9844028ccc48fd67fb581f';

/// The app-wide [QuoteService].
///
/// Copied from [quoteService].
@ProviderFor(quoteService)
final quoteServiceProvider = AutoDisposeProvider<QuoteService>.internal(
  quoteService,
  name: r'quoteServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$quoteServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef QuoteServiceRef = AutoDisposeProviderRef<QuoteService>;
String _$dailyQuoteHash() => r'724529cc2ad02ec913fea42396f929440e3af400';

/// The quote of the day, sourced from [quoteServiceProvider].
///
/// Copied from [dailyQuote].
@ProviderFor(dailyQuote)
final dailyQuoteProvider = AutoDisposeFutureProvider<Quote>.internal(
  dailyQuote,
  name: r'dailyQuoteProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$dailyQuoteHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DailyQuoteRef = AutoDisposeFutureProviderRef<Quote>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
