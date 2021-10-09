// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pharmaceutical.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Pharmaceutical _$PharmaceuticalFromJson(Map<String, dynamic> json) =>
    Pharmaceutical(
      tradename: json['tradename'] as String,
      dosage: json['dosage'] as String,
      activeSubstance: json['activeSubstance'] as String?,
      human_known_name: json['human_known_name'] as String?,
      documentState:
          _$enumDecodeNullable(_$DocumentStateEnumMap, json['documentState']) ??
              DocumentState.user_created,
      id: json['id'] as String? ?? "",
    );

Map<String, dynamic> _$PharmaceuticalToJson(Pharmaceutical instance) =>
    <String, dynamic>{
      'id': instance.id,
      'documentState': _$DocumentStateEnumMap[instance.documentState],
      'human_known_name': instance.human_known_name,
      'tradename': instance.tradename,
      'dosage': instance.dosage,
      'activeSubstance': instance.activeSubstance,
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

const _$DocumentStateEnumMap = {
  DocumentState.user_created: 'user_created',
  DocumentState.in_review: 'in_review',
  DocumentState.peer_reviewed: 'peer_reviewed',
  DocumentState.admin_reviewed: 'admin_reviewed',
};
