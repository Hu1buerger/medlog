import 'package:logging/logging.dart';
import 'package:medlog/src/model/log_entry/log_event.dart';
import 'package:medlog/src/model/log_entry/medication_intake_event.dart';
import 'package:medlog/src/model/log_entry/stock_event.dart';

import '../storage_service.dart';

class LogService extends StorageService<LogEvent> {
  static const String typeKey = "type";
  static const String payloadKey = "body";

  static const String stockEventID = "SE";
  static const String medicationIntakaeEventID = "ME";

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

    // wrap the json of a specific item into a jsonObject with type and body and id the runtimeType
    if(json.containsKey(typeKey) == false){
      logger.fine("hit an old log entry");
      // this is for keeping old logs intact
      var jsonBody = json;
      json = {};
      json[typeKey] = medicationIntakaeEventID;
      json[payloadKey] = jsonBody;
    }

    switch(json[typeKey]){
      case stockEventID:
        return StockEvent.fromJson(json[payloadKey]);
      case medicationIntakaeEventID:
        return MedicationIntakeEvent.fromJson(json[payloadKey]);
      default:
        logger.severe("cannot deserialize LogEvent $json");
    }

    throw Error();
  }

  @override
  Map<String, dynamic> toJson(LogEvent t){
    Map<String, dynamic> json = {};

    if(t is StockEvent){
      json[typeKey] = stockEventID;
      json[payloadKey] = t.toJson();
    }

    if(t is MedicationIntakeEvent){
      json[typeKey] = medicationIntakaeEventID;
      json[payloadKey] = t.toJson();
    }

    if(json.isEmpty){
      logger.severe("cannot serialze this logEvent $t");
    }

    return json;
  }
}