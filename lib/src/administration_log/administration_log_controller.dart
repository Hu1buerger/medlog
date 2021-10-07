import 'package:flutter/cupertino.dart';
import 'package:medlog/src/pharmaceutical/pharmaceutical.dart';
import 'package:medlog/src/pharmaceutical/pharmaceutical_controller.dart';

import 'administration_log_entry.dart';

class AdministrationLogController with ChangeNotifier {

  PharmaceuticalController pharmaController;

  int _lastID = 0;

  List<AdministrationLogEntry> _log = [];
  List<AdministrationLogEntry> get log => _log;

  AdministrationLogController(this.pharmaController);

  Future<void> loadLog() async {
    var medikinet = pharmaController.getOrCreate("Medikinet", "30mg");
    var adalimumab = pharmaController.getOrCreate("Adalimumab", "40mg");

    _log = [
      AdministrationLogEntry(-1, medikinet, DateTime(2020, 10, 05, 18, 07)),
      AdministrationLogEntry(-1, medikinet, DateTime(2020, 10, 04, 18, 07)),
      AdministrationLogEntry(-1, medikinet, DateTime(2020, 10, 03, 18, 07)),
      AdministrationLogEntry(-1, medikinet, DateTime(2020, 10, 02, 18, 07)),
    ];
    _sortLog();
  }

  void addLogEntry(Pharmaceutical pharmaceutical, DateTime adminTime) {
    var logEntry = AdministrationLogEntry(_lastID++, pharmaceutical, adminTime);

    _log.add(logEntry);
    _sortLog();
    notifyListeners();
  }

  _sortLog(){
    _log.sort((a,b) => a.adminDate.compareTo(b.adminDate));
  }
}
