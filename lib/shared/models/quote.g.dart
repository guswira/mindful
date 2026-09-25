// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quote.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Quote _$QuoteFromJson(Map<String, dynamic> json) =>
    _Quote(quote: json['quote'] as String, author: json['author'] as String);

Map<String, dynamic> _$QuoteToJson(_Quote instance) => <String, dynamic>{
  'quote': instance.quote,
  'author': instance.author,
};
