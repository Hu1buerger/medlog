import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';
import 'package:medlog/src/controller/log/log_service.dart';
import 'package:medlog/src/controller/pharmaceutical/pharmaceutical_controller.dart';
import 'package:medlog/src/model/log_entry/log_event.dart';
import 'package:medlog/src/model/log_entry/medication_intake_event.dart';
import 'package:medlog/src/model/log_entry/stock_event.dart';
import 'package:medlog/src/model/pharmaceutical/pharmaceutical_ref.dart';

/// Handles the keeping of records
class LogController with ChangeNotifier {
  static final _logger = Logger("LogController");

  LogService logService;
  PharmaceuticalController pharmaController;

  int _lastID = 0;

  List<LogEvent> _log = <LogEvent>[];

  List<LogEvent> get log => _log;

  List<LogEvent> _itemsInNeedToRehydrate = [];

  LogController(this.pharmaController, this.logService) {
    pharmaController.addListener(_tryRehydrate);
  }

  /// adds an event that changes the stock
  /// TODO: use StockItem as argument.... like yeah
  void addStockEvent(StockEvent event) {
    assert(event.pharmaceutical is PharmaceuticalRef);

    event.id = ++_lastID;
    _insert(event);
  }

  /// logs the intake of medication
  void addMedicationIntake(MedicationIntakeEvent event) {
    assert(event.pharmaceutical is PharmaceuticalRef);

    event.id = ++_lastID;
    _insert(event);
  }

  void delete(entry) {
    assert(log.contains(entry));

    bool wasRemoved = log.remove(entry);
    if (wasRemoved) {
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

  Future<void> loadLog() async {
    _logger.fine("starting to load the log");

    logService.loadFromDisk();
    var logs = await logService.getAll();

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
        _logger.fine("failed to rehydrate ${e.id}");
      }
    }
  }

  _sortLog() {
    _log.sort((a, b) => a.eventTime.compareTo(b.eventTime));
  }
}
