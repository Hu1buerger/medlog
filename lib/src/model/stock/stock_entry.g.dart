// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StockItem _$StockItemFromJson(Map<String, dynamic> json) => StockItem(
      json['id'] as String,
      json['pharmaceuticalID'] as String,
      (json['amount'] as num).toDouble(),
      $enumDecode(_$StockStateEnumMap, json['state']),
      DateTime.parse(json['expiryDate'] as String),
    );

Map<String, dynamic> _$StockItemToJson(StockItem instance) => <String, dynamic>{
      'id': instance.id,
      'pharmaceuticalID': instance.pharmaceuticalID,
      'amount': instance.amount,
      'state': _$StockStateEnumMap[instance.state],
      'expiryDate': instance.expiryDate.toIso8601String(),
    };

const _$StockStateEnumMap = {
  StockState.closed: 'closed',
  StockState.open: 'open',
};
