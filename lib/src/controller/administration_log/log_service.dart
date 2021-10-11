import 'package:logging/logging.dart';
import 'package:medlog/src/model/log_entry/log_entry.dart';

import '../storage_service.dart';

class LogService extends StorageService<LogEntry> {
  LogService()
      : super(
            "log",
            JsonConverter(
                toJson: (t) => t.toJson(),
                fromJson: (json) => LogEntry.fromJson(json)),
            Logger("LogService"));
}