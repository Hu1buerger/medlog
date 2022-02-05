import 'package:medlog/src/api_provider.dart';
import 'package:medlog/src/model/log_entry/medication_intake_event.dart';
import 'package:medlog/src/model/pharmaceutical/pharmaceutical.dart';

class PharmaUsageFrequency {
  PharmaUsageFrequency(this.provider);

  final APIProvider provider;

  Map<Pharmaceutical, int> get usageNumerics {
    final Map<Pharmaceutical, int> res = {};

    for (final logEvent in provider.logProvider.getLog()) {
      if (logEvent is! MedicationIntakeEvent) continue;

      res.update(logEvent.pharmaceutical, (value) => value + 1, ifAbsent: () => 1);
    }

    return res;
  }

  Map<Pharmaceutical, List<DateTime>> get usageTimes{
    Map<Pharmaceutical, List<DateTime>> datetimes = {};
    provider.logProvider.getLog()
    .whereType<MedicationIntakeEvent>()
    .forEach((element) => datetimes.update(element.pharmaceutical, (value) {
      value.add(element.eventTime);
      return value;
    }));

    return datetimes;
  } 
}
