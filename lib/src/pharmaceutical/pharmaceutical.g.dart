// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pharmaceutical.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Pharmaceutical _$PharmaceuticalFromJson(Map<String, dynamic> json) =>
    Pharmaceutical(
      json['tradename'] as String,
      json['dosage'] as String,
      pzn: json['pzn'] as String? ?? "UNASSIGNED",
      activeIngredient: json['activeIngredient'] as String? ?? "UNASSIGNED",
    );

Map<String, dynamic> _$PharmaceuticalToJson(Pharmaceutical instance) =>
    <String, dynamic>{
      'pzn': instance.pzn,
      'tradename': instance.tradename,
      'activeIngredient': instance.activeIngredient,
      'dosage': instance.dosage,
    };
