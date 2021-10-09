// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LogEntry _$AdministrationLogEntryFromJson(
        Map<String, dynamic> json) =>
    LogEntry(
      json['id'] as int,
      Pharmaceutical.fromJson(json['pharamaceutical'] as Map<String, dynamic>),
      DateTime.parse(json['adminDate'] as String),
    );

Map<String, dynamic> _$AdministrationLogEntryToJson(
        LogEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'pharamaceutical': instance.pharamaceutical,
      'adminDate': instance.adminDate.toIso8601String(),
    };
