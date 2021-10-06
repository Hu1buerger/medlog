import 'package:json_annotation/json_annotation.dart';
import 'package:medlog/src/pharmaceutical/pharmaceutical.dart';

part 'administration_log_entry.g.dart';

@JsonSerializable()
class AdministrationLogEntry{
  int id;
  Pharmaceutical pharamaceutical;
  DateTime adminDate;

  String get medname => pharamaceutical.tradename;
  String get dose => pharamaceutical.dosage;

  AdministrationLogEntry(this.id, this.pharamaceutical, this.adminDate);

  factory AdministrationLogEntry.now(Pharmaceutical p) => AdministrationLogEntry(-1, p, DateTime.now());

  factory AdministrationLogEntry.fromJson(Map<String,dynamic> json){
    var e = _$AdministrationLogEntryFromJson(json);
    return e;
  }

  Map<String, dynamic> toJson() => _$AdministrationLogEntryToJson(this);
}