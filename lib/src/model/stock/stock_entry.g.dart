// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StockItem _$StockItemFromJson(Map<String, dynamic> json) => StockItem(
      json['id'] as String,
      json['pharmaceuticalID'] as String,
      (json['amount'] as num).toDouble(),
      _$enumDecode(_$StockStateEnumMap, json['state']),
      DateTime.parse(json['expiryDate'] as String),
    );

Map<String, dynamic> _$StockItemToJson(StockItem instance) => <String, dynamic>{
      'id': instance.id,
      'pharmaceuticalID': instance.pharmaceuticalID,
      'amount': instance.amount,
      'state': _$StockStateEnumMap[instance.state],
      'expiryDate': instance.expiryDate.toIso8601String(),
    };

K _$enumDecode<K, V>(
  Map<K, V> enumValues,
  Object? source, {
  K? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
}

const _$StockStateEnumMap = {
  StockState.closed: 'closed',
  StockState.open: 'open',
};
