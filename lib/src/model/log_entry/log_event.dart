import 'package:json_annotation/json_annotation.dart';
import 'package:medlog/src/repo/pharmaceutical/pharmaceutical_repo.dart';

abstract class LogEvent {
  static const unsetID = -1;

  /// the id of the event
  @JsonKey()
  int id;

  @JsonKey()
  DateTime eventTime;

  LogEvent(this.id, this.eventTime);

  /// tries to rehydrate the item
  ///
  /// Rehydration is the process of getting an item which we now only store via the id
  /// and setting the item associated with it from a source
  ///
  /// true on success
  /// false on fail
  bool rehydrate(PharmaceuticalRepo pc);
}
