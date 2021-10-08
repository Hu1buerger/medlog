import 'package:json_annotation/json_annotation.dart';
import 'package:medlog/src/pharmaceutical/pharmaceutical.dart';

part 'log_entry.g.dart';

@JsonSerializable()
class LogEntry{
  int id;
  Pharmaceutical pharamaceutical;
  DateTime adminDate;

  String get displayName => pharamaceutical.displayName;
  String get dosage => pharamaceutical.dosage;
  String get activeSubstance => pharamaceutical.activeSubstance ?? "Unassigned";

  LogEntry(this.id, this.pharamaceutical, this.adminDate);

  factory LogEntry.now(Pharmaceutical p) => LogEntry(-1, p, DateTime.now());

  factory LogEntry.fromJson(Map<String,dynamic> json){
    var e = _$AdministrationLogEntryFromJson(json);
    return e;
  }

  Map<String, dynamic> toJson() => _$AdministrationLogEntryToJson(this);
}