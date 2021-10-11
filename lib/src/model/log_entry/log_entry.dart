import 'package:json_annotation/json_annotation.dart';
import 'package:medlog/src/model/pharmaceutical/pharmaceutical.dart';

part 'log_entry.g.dart';

//TODO: use id from pharmaceutical to link
@JsonSerializable()
class LogEntry{
  int id;
  Pharmaceutical pharmaceutical;
  DateTime adminDate;

  String get displayName => pharmaceutical.displayName;
  String get dosage => pharmaceutical.dosage;
  String get activeSubstance => pharmaceutical.activeSubstance ?? "Unassigned";

  LogEntry(this.id, this.pharmaceutical, this.adminDate){
    if(_isValidId(id) == false) throw ArgumentError();
  }

  factory LogEntry.now(Pharmaceutical p) => LogEntry(-1, p, DateTime.now());

  factory LogEntry.fromJson(Map<String,dynamic> json){
    var e = _$LogEntryFromJson(json);
    return e;
  }

  Map<String, dynamic> toJson() => _$LogEntryToJson(this);

  static bool _isValidId(int id){
    return id > 0;
  }
}