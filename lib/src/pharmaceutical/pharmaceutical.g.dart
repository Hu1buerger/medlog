// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pharmaceutical.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Pharmaceutical _$PharmaceuticalFromJson(Map<String, dynamic> json) =>
    Pharmaceutical(
      _$enumDecode(_$DocumentStateEnumMap, json['documentState']),
      json['tradename'] as String,
      json['dosage'] as String,
      json['activeIngredient'] as String,
      pzn: json['pzn'] as String? ?? "UNASSIGNED",
      id: json['id'] as int? ?? -1,
    );

Map<String, dynamic> _$PharmaceuticalToJson(Pharmaceutical instance) =>
    <String, dynamic>{
      'id': instance.id,
      'documentState': _$DocumentStateEnumMap[instance.documentState],
      'pzn': instance.pzn,
      'tradename': instance.tradename,
      'activeIngredient': instance.activeIngredient,
      'dosage': instance.dosage,
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

const _$DocumentStateEnumMap = {
  DocumentState.user_created: 'user_created',
  DocumentState.in_review: 'in_review',
  DocumentState.peer_reviewed: 'peer_reviewed',
  DocumentState.admin_reviewed: 'admin_reviewed',
};
