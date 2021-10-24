// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medication_intake_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MedicationIntakeEvent _$MedicationIntakeEventFromJson(
        Map<String, dynamic> json) =>
    MedicationIntakeEvent(
      json['id'] as int,
      DateTime.parse(json['eventTime'] as String),
      json['pharmaceuticalID'] as String,
      (json['amount'] as num).toDouble(),
      source:
          _$enumDecodeNullable(_$PharmaceuticalSourceEnumMap, json['source']) ??
              PharmaceuticalSource.other,
    );

Map<String, dynamic> _$MedicationIntakeEventToJson(
        MedicationIntakeEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'eventTime': instance.eventTime.toIso8601String(),
      'pharmaceuticalID': instance.pharmaceuticalID,
      'amount': instance.amount,
      'source': _$PharmaceuticalSourceEnumMap[instance.source],
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

K? _$enumDecodeNullable<K, V>(
  Map<K, V> enumValues,
  dynamic source, {
  K? unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<K, V>(enumValues, source, unknownValue: unknownValue);
}

const _$PharmaceuticalSourceEnumMap = {
  PharmaceuticalSource.stock: 'stock',
  PharmaceuticalSource.other: 'other',
};
