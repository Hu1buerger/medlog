import 'dart:math';

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

  Map<Pharmaceutical, List<DateTime>> get usageTimes {
    Map<Pharmaceutical, List<DateTime>> datetimes = {};
    provider.logProvider
        .getLog()
        .whereType<MedicationIntakeEvent>()
        .forEach((element) => datetimes.update(element.pharmaceutical, (value) {
              value.add(element.eventTime);
              return value;
            }));

    return datetimes;
  }

  Map<Pharmaceutical, Duration> get meanDelta {
    return Map.fromEntries(provider.logProvider
        .getLog()
        .whereType<MedicationIntakeEvent>()
        .map((e) => e.pharmaceutical)
        .toSet()
        .map((e) => MapEntry(e, meanIntakeDurationForPharm(e))));
  }

  Duration meanIntakeDurationForPharm(Pharmaceutical pharmaceutical) {
    var intakes = provider.logProvider
        .getLog()
        .whereType<MedicationIntakeEvent>()
        .where((e) => e.pharmaceutical == pharmaceutical)
        .toList();

    if (intakes.length <= 1) {
      //no duration is measurable;
      throw Error();
    }

    final List<Duration> durations = [];
    for (int i = 1; i < intakes.length; i++) {
      var dt1 = intakes[i - 1].eventTime;
      var dt2 = intakes[i].eventTime;

      if (dt1.isAfter(dt2)) {
        // swap dt1,dt2 => difference >= 0
        assert(dt1 != dt2);
        var dtRegister = dt1;
        dt2 = dt1;
        dt2 = dtRegister;
        assert(dt1 != dt2);
      }

      durations.add(dt1.difference(dt2));
    }
    assert(durations.length == intakes.length - 1);

    // we could filter some durations i.e. less than 5 min to stabilize the mean
    // using microseconds bcs dose dart detect overflow?
    final durationsSum = durations.map((e) => e.inSeconds).reduce((value, element) => value + element);

    //rounding error shouldnt be super important due to the used unit
    final meanDuration = durationsSum ~/ durations.length;

    return Duration(seconds: meanDuration);
  }
}
