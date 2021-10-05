import 'package:flutter/cupertino.dart';
import 'package:medlog/src/pharmaceutical/pharmaceutical.dart';

import 'administration_log_entry.dart';

class AdministrationLogController with ChangeNotifier {
  int _lastID = 0;

  late List<AdministrationLogEntry> _log;

  List<AdministrationLogEntry> get log => _log;

  Future<void> loadLog() async {
    var medikinet = Pharmaceutical.getOrCreate("Medikinet", "30mg");
    _log = [
      AdministrationLogEntry(-1, medikinet, DateTime(2020, 10, 05, 18, 07)),
      AdministrationLogEntry(-1, medikinet, DateTime(2020, 10, 04, 18, 07)),
      AdministrationLogEntry(-1, medikinet, DateTime(2020, 10, 03, 18, 07)),
      AdministrationLogEntry(-1, medikinet, DateTime(2020, 10, 02, 18, 07)),
    ];
  }

  void addLogEntry(Pharmaceutical pharmaceutical, DateTime adminTime) {
    var logEntry = AdministrationLogEntry(_lastID++, pharmaceutical, adminTime);

    _log.add(logEntry);
    notifyListeners();
  }
}
