import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';
import 'package:medlog/src/controller/administration_log/log_service.dart';
import 'package:medlog/src/controller/pharmaceutical/pharmaceutical_controller.dart';
import 'package:medlog/src/model/log_entry/log_entry.dart';
import 'package:medlog/src/model/pharmaceutical/pharmaceutical.dart';

/// Handles the keeping of records
class LogController with ChangeNotifier {

  static final _logger = Logger("LogController");
  LogService logService;
  PharmaceuticalController pharmaController;

  int _lastID = 0;

  List<LogEntry> _log = <LogEntry>[];
  List<LogEntry> get log => _log;

  LogController(this.pharmaController, this.logService);

  Future<void> loadLog() async {
    var logs = await logService.load();
    if(logs.isNotEmpty){
      for(var e in logs){
        var trackedPharmaceutical = pharmaController.getTrackedInstance(e.pharmaceutical);
        e.pharmaceutical = trackedPharmaceutical;
      }
      _log = logs;
      _sortLog();
      _lastID = _log.map((e) => e.id).reduce(max);
    }else{
      _log = [];
      _lastID = 0;
    }

    return;
  }

  Future<void> storeLog() async{
    await logService.store(_log);
  }

  void addLogEntry(Pharmaceutical pharmaceutical, DateTime adminTime) {
    assert(pharmaceutical is PharmaceuticalRef);

    var logEntry = LogEntry(++_lastID, pharmaceutical, adminTime);

    _log.add(logEntry);
    _sortLog();
    notifyListeners();
  }

  _sortLog(){
    _log.sort((a,b) => a.adminDate.compareTo(b.adminDate));
  }

  void delete(LogEntry entry) {
    assert(log.contains(entry));
    bool wasRemoved = log.remove(entry);
    if(wasRemoved){
      notifyListeners();
    }
  }
}