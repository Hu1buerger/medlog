import 'package:logging/logging.dart';
import 'package:medlog/src/model/log_entry/log_event.dart';
import 'package:medlog/src/model/log_entry/medication_intake_event.dart';
import 'package:medlog/src/model/log_entry/stock_event.dart';

import '../storage_service.dart';

class LogService extends StorageService<LogEvent> {
  static const String typeKey = "type";
  static const String payloadKey = "body";

  static const String StockEventID = "SE";
  static const String MedicationIntakaeEventID = "ME";

  LogService()
      : super("log", Logger("LogService"));

  @override
  Future<List<LogEvent>> loadFromDisk() async {
    var items = await super.loadFromDisk();
    signalDone();
    return items;
  }

  @override
  LogEvent fromJson(Map<String, dynamic> json){
    if(json.isEmpty) throw ArgumentError.value(json);

    if(json.containsKey(typeKey) == false){
      logger.fine("hit an old log entry");
      // this is for keeping old logs intact
      var jsonBody = json;
      json = {};
      json[typeKey] = MedicationIntakaeEventID;
      json[payloadKey] = jsonBody;
    }

    switch(json[typeKey]){
      case StockEventID:
        return StockEvent.fromJson(json[payloadKey]);
      case MedicationIntakaeEventID:
        return MedicationIntakeEvent.fromJson(json[payloadKey]);
      default:
        logger.severe("cannot deserialize LogEvent $json");
    }

    throw Error();
  }

  @override
  Map<String, dynamic> toJson(LogEvent e){
    Map<String, dynamic> json = {};

    if(e is StockEvent){
      json[typeKey] = StockEventID;
      json[payloadKey] = e.toJson();
    }

    if(e is MedicationIntakeEvent){
      json[typeKey] = MedicationIntakaeEventID;
      json[payloadKey] = e.toJson();
    }

    if(json.isEmpty){
      logger.severe("cannot serialze this logEvent $e");
    }

    return json;
  }
}