// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StockEvent _$StockEventFromJson(Map<String, dynamic> json) => StockEvent(
      json['id'] as int,
      DateTime.parse(json['eventTime'] as String),
      json['pharmaceuticalID'] as String,
      (json['amount'] as num).toDouble(),
    );

Map<String, dynamic> _$StockEventToJson(StockEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'eventTime': instance.eventTime.toIso8601String(),
      'pharmaceuticalID': instance.pharmaceuticalID,
      'amount': instance.amount,
    };
