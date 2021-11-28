import 'package:logging/logging.dart';
import 'package:medlog/src/repo/log/log_repo.dart';
import 'package:medlog/src/model/log_entry/log_event.dart';
import 'package:medlog/src/model/log_entry/medication_intake_event.dart';
import 'package:medlog/src/model/log_entry/stock_event.dart';
import 'package:medlog/src/model/pharmaceutical/pharmaceutical_ref.dart';

class LogProvider {
  LogProvider(this._logController) {
    _logController.addListener(_onChange);
  }

  static final logger = Logger("LogProvider");

  final LogRepo _logController;

  List<LogEvent> cache = [];

  /// adds an event that changes the stock
  void addStockEvent(StockEvent event) {
    assert(event.pharmaceutical is PharmaceuticalRef);

    _logController.addLogEvent(event);
  }

  /// logs the intake of medication
  void addMedicationIntake(MedicationIntakeEvent event) {
    assert(event.pharmaceutical is PharmaceuticalRef);

    _logController.addLogEvent(event);
  }

  void delete(LogEvent entry) {
    assert(cache.contains(entry));
    assert(LogRepo.supportedTypes.any((element) => element == entry.runtimeType));

    _logController.delete(entry);
  }

  List<LogEvent> getLog() {
    return cache.toList();
  }

  void _onChange() {
    logger.fine("change recieved");
    cache = _logController.log;
  }
}
