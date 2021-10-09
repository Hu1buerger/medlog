// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LogEntry _$LogEntryFromJson(Map<String, dynamic> json) => LogEntry(
      json['id'] as int,
      Pharmaceutical.fromJson(json['pharmaceutical'] as Map<String, dynamic>),
      DateTime.parse(json['adminDate'] as String),
    );

Map<String, dynamic> _$LogEntryToJson(LogEntry instance) => <String, dynamic>{
      'id': instance.id,
      'pharmaceutical': instance.pharmaceutical,
      'adminDate': instance.adminDate.toIso8601String(),
    };
