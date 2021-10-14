// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StockEntry _$StockEntryFromJson(Map<String, dynamic> json) => StockEntry(
      json['pharmaceuticalID'] as String,
      json['amount'] as int,
      _$enumDecode(_$StockStateEnumMap, json['state']),
      DateTime.parse(json['expiryDate'] as String),
    )..pharmaceutical =
        Pharmaceutical.fromJson(json['pharmaceutical'] as Map<String, dynamic>);

Map<String, dynamic> _$StockEntryToJson(StockEntry instance) =>
    <String, dynamic>{
      'pharmaceuticalID': instance.pharmaceuticalID,
      'pharmaceutical': instance.pharmaceutical,
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
  StockState.close: 'close',
  StockState.open: 'open',
};
