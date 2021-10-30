import 'package:logging/logging.dart';
import 'package:medlog/src/model/log_entry/log_event.dart';
import 'package:medlog/src/model/log_entry/medication_intake_event.dart';
import 'package:medlog/src/model/log_entry/stock_event.dart';

import '../storage_service.dart';

class LogService extends StorageService<LogEvent> {
  final Map<Type, StorageService> delegates = {
    MedicationIntakeEvent: _MedicationIntakeStorageService(Logger("LogService.med")),
    StockEvent: _StockEventStorageService(Logger("LogService.stock"))
  };

  LogService() : super("log", logger: Logger("LogService"));

  @override
  Future<List<LogEvent>> loadFromDisk() async {
    List<LogEvent> items = <LogEvent>[];

    for (var e in delegates.entries) {
      final List<LogEvent> l = await e.value.loadFromDisk() as List<LogEvent>;
      items.addAll(l);
    }

    items.sort((a, b) => a.id.compareTo(b.id));
    items.forEach(publish);
    logger.fine("loaded ${items.length} items");

    signalDone();
    return items;
  }

  @override
  Future<void> store(List<LogEvent> list) async {
    // all items in list shall be of a type contained in delegate.keys
    assert(list.any((e) => delegates.containsKey(e.runtimeType) == false) == false);

    for (var e in delegates.entries) {
      var applicableItems = list.where((element) => element.runtimeType == e.key).toList();

      switch (e.key) {
        case MedicationIntakeEvent:
          await e.value.store(applicableItems.cast<MedicationIntakeEvent>());
          break;
        case StockEvent:
          await e.value.store(applicableItems.cast<StockEvent>());
          break;
        default:
          logger.severe("unimplemented converter");
          throw UnimplementedError();
      }
    }
  }
}

class _MedicationIntakeStorageService extends StorageService<MedicationIntakeEvent> {
  _MedicationIntakeStorageService(Logger logger) : super("medicationIntakeEvents", logger: logger);

  @override
  Map<String, dynamic> toJson(MedicationIntakeEvent t) => t.toJson();

  @override
  MedicationIntakeEvent fromJson(Map<String, dynamic> json) => MedicationIntakeEvent.fromJson(json);
}

class _StockEventStorageService extends StorageService<StockEvent> {
  _StockEventStorageService(Logger logger) : super("stockEvents", logger: logger);

  @override
  Map<String, dynamic> toJson(StockEvent t) => t.toJson();

  @override
  StockEvent fromJson(Map<String, dynamic> json) => StockEvent.fromJson(json);
}
