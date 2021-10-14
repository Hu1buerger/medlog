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
    );

Map<String, dynamic> _$MedicationIntakeEventToJson(
        MedicationIntakeEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'eventTime': instance.eventTime.toIso8601String(),
      'pharmaceuticalID': instance.pharmaceuticalID,
      'amount': instance.amount,
    };
