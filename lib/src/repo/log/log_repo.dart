import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';
import 'package:medlog/src/model/log_entry/log_event.dart';
import 'package:medlog/src/model/log_entry/medication_intake_event.dart';
import 'package:medlog/src/model/log_entry/stock_event.dart';
import 'package:medlog/src/repo/pharmaceutical/pharmaceutical_repo.dart';
import 'package:medlog/src/util/repo_adapter.dart';
import 'package:medlog/src/util/store.dart';

/// Handles the keeping of records
///
/// This class currently seems to handle to much
///
/// TODO: The [LogProvider] will take over
///  and its responsibility is to just combine all LogEvents and thats it
class LogRepo with ChangeNotifier {
  static const String key = "log";
  static const String keyMedIntake = "$key-medIn";
  static const String keyStock = "$key-stock";

  static final _logger = Logger("LogRepo");
  static final supportedTypes = [MedicationIntakeEvent, StockEvent];

  final RepoAdapter repoAdapter;
  PharmaceuticalRepo pharmaController;

  int _lastID = 0;

  List<LogEvent> _log = <LogEvent>[];

  List<LogEvent> get log => _log;

  List<LogEvent> _itemsInNeedToRehydrate = [];

  LogRepo(this.repoAdapter, this.pharmaController) {
    pharmaController.addListener(_tryRehydrate);
  }

  Future<void> load() async {
    _logger.fine("starting to load the log");

    var medIn = repoAdapter.loadListOrDefault<Json, MedicationIntakeEvent>(
        keyMedIntake, (Json json) => MedicationIntakeEvent.fromJson(json), []);
    var stockE =
        repoAdapter.loadListOrDefault<Json, StockEvent>(keyStock, (Json json) => StockEvent.fromJson(json), []);
    var logs = [...medIn, ...stockE];

    if (logs.isNotEmpty) {
      _sortLog(logs);

      _itemsInNeedToRehydrate = logs;
      _lastID = logs.map((e) => e.id).reduce(max);
      _tryRehydrate();
    } else {
      _log = [];
      _lastID = 0;
    }

    _logger.fine("finished loading with ${log.length} entrys");
    return;
  }

  store() {
    // also store items that would need to rehydrate
    _log.addAll(_itemsInNeedToRehydrate);
    _logger.fine("storing ${_log.length} events");

    var stockEvents = _log.whereType<StockEvent>().toList();
    repoAdapter.storeList(keyStock, stockEvents, (StockEvent s) => s.toJson());

    var miEvents = _log.whereType<MedicationIntakeEvent>().toList();
    repoAdapter.storeList(keyMedIntake, miEvents, (MedicationIntakeEvent e) => e.toJson());
  }

  int nextID() {
    _lastID += 1;
    assert(log.map((e) => e.id).contains(_lastID) == false);

    return _lastID;
  }

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
    _sortLog(_log);
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

  _sortLog(List<LogEvent> list) {
    list.sort((a, b) => a.eventTime.compareTo(b.eventTime));
    return list;
  }
}
