import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';
import 'package:medlog/src/repo/log/log_service.dart';
import 'package:medlog/src/repo/pharmaceutical/pharmaceutical_repo.dart';
import 'package:medlog/src/model/log_entry/log_event.dart';
import 'package:medlog/src/model/log_entry/medication_intake_event.dart';
import 'package:medlog/src/model/log_entry/stock_event.dart';

/// Handles the keeping of records
///
/// This class currently seems to handle to much
///
/// TODO: The [LogProvider] will take over
///  and its responsibility is to just combine all LogEvents and thats it
class LogRepo with ChangeNotifier {
  static final _logger = Logger("LogController");
  static final supportedTypes = [MedicationIntakeEvent, StockEvent];

  LogService logService;
  PharmaceuticalRepo pharmaController;

  int _lastID = 0;

  List<LogEvent> _log = <LogEvent>[];

  List<LogEvent> get log => _log;

  List<LogEvent> _itemsInNeedToRehydrate = [];

  LogRepo(this.pharmaController, this.logService) {
    pharmaController.addListener(_tryRehydrate);
  }

  Future<void> loadLog() async {
    _logger.fine("starting to load the log");

    var logs = await logService.loadFromDisk();

    if (logs.isNotEmpty) {
      _itemsInNeedToRehydrate = logs;
      _lastID = logs.map((e) => e.id).reduce(max);
      _tryRehydrate();
    } else {
      _log = [];
      _lastID = 0;
    }

    _logger.fine("finished loading with ${logs.length} entrys");
    return;
  }

  Future<void> storeLog() async {
    // also store items that would need to rehydrate
    _log.addAll(_itemsInNeedToRehydrate);

    _logger.fine("storing ${_log.length} events");
    await logService.store(_log);
  }

  Map<String, List<Map<String, dynamic>>> jsonKV() => logService.toJsonArray(log);

  int nextID() => _lastID++;

  void addLogEvent(LogEvent event) {
    assert(log.contains(event) == false);

    event.id = nextID();
    _insert(event);
  }

  void delete(LogEvent event) {
    assert(log.contains(event));

    bool updated = log.remove(event);
    if (updated) {
      _logger.fine("removing $event");
      notifyListeners();
    }
  }

  void _insert(LogEvent le) {
    assert(log.any((element) => element.id == le.id) == false);

    _logger.fine("inserted ${le.id} as ${le.runtimeType.toString()}");
    log.add(le);
    _sortLog();
    notifyListeners();
  }

  _tryRehydrate() {
    for (int i = _itemsInNeedToRehydrate.length - 1; i >= 0; i--) {
      var e = _itemsInNeedToRehydrate[i];

      // rehydrating all items.
      bool success = e.rehydrate(pharmaController);
      if (success) {
        _logger.fine("rehydrated ${e.id}");
        _itemsInNeedToRehydrate.removeAt(i);
        _insert(e);
      } else {
        _logger.severe("failed to rehydrate ${e.id}");
      }
    }
  }

  _sortLog() {
    _log.sort((a, b) => a.eventTime.compareTo(b.eventTime));
  }
}

class MedicationIntakeController {}
