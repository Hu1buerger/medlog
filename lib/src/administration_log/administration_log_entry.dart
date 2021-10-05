import 'package:medlog/src/pharmaceutical/pharmaceutical.dart';

class AdministrationLogEntry{
  int id;

  Pharmaceutical pharamaceutical;
  String get medname => pharamaceutical.tradename;
  String get dose => pharamaceutical.dosage;
  DateTime adminDate;

  AdministrationLogEntry(this.id, this.pharamaceutical, this.adminDate);

  factory AdministrationLogEntry.now(Pharmaceutical p) => AdministrationLogEntry(-1, p, DateTime.now());
}