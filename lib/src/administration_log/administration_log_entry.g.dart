// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'administration_log_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdministrationLogEntry _$AdministrationLogEntryFromJson(
        Map<String, dynamic> json) =>
    AdministrationLogEntry(
      json['id'] as int,
      Pharmaceutical.fromJson(json['pharamaceutical'] as Map<String, dynamic>),
      DateTime.parse(json['adminDate'] as String),
    );

Map<String, dynamic> _$AdministrationLogEntryToJson(
        AdministrationLogEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'pharamaceutical': instance.pharamaceutical,
      'adminDate': instance.adminDate.toIso8601String(),
    };
