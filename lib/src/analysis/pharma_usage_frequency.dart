import 'package:medlog/src/api_provider.dart';
import 'package:medlog/src/model/log_entry/medication_intake_event.dart';
import 'package:medlog/src/model/pharmaceutical/pharmaceutical.dart';

class PharmaUsageFrequency {
  PharmaUsageFrequency(this.provider);

  final APIProvider provider;

  Map<Pharmaceutical, int> get usage {
    final Map<Pharmaceutical, int> res = {};

    for (final logEvent in provider.logProvider.getLog()) {
      if (logEvent is! MedicationIntakeEvent) continue;

      res.update(logEvent.pharmaceutical, (value) => value + 1, ifAbsent: () => 1);
    }

    return res;
  }
}
