import 'package:flutter_test/flutter_test.dart';
import 'package:medlog/src/model/log_entry/log_event.dart';
import 'package:medlog/src/model/log_entry/medication_intake_event.dart';
import 'package:medlog/src/model/log_entry/stock_event.dart';

class LogEventMatcher<T extends LogEvent> extends Matcher {
  final T expected;

  const LogEventMatcher(this.expected);

  @override
  Description describe(Description description) =>
      description.add("matches logevents by field");

  @override
  bool matches(item, Map matchState) {
    assert(matchState.isEmpty);

    _testFeature(matchState, "type",
        () => expect(item.runtimeType, expected.runtimeType));
    // preemptively fail bcs the type mismatched
    if (matchState.isNotEmpty) return false;

    final actual = item as T;
    _testFeature(matchState, "id", () => expect(actual.id, expected.id));
    _testFeature(
        matchState,
        "eventTime",
        () => expect(actual.eventTime.toIso8601String(),
            expected.eventTime.toIso8601String()));

    switch (actual.runtimeType) {
      case MedicationIntakeEvent:
        var a = actual as MedicationIntakeEvent;
        var e = expected as MedicationIntakeEvent;

        _testFeature(matchState, "pharmaceuticalID",
            () => expect(a.pharmaceuticalID, e.pharmaceuticalID));
        _testFeature(matchState, "amount", () => expect(a.amount, e.amount));
        _testFeature(matchState, "source", () => expect(a.source, e.source));
        break;
      case StockEvent:
        var a = actual as StockEvent;
        var e = expected as StockEvent;

        _testFeature(matchState, "pharmaceuticalID",
            () => expect(a.pharmaceuticalID, e.pharmaceuticalID));
        _testFeature(matchState, "amount", () => expect(a.amount, e.amount));
        break;
      default:
        throw UnimplementedError(
            "unknown type of LogEvent - test not implemented");
    }

    return matchState.isEmpty;
  }

  @override
  Description describeMismatch(
      item, Description mismatchDescription, Map matchState, bool verbose) {
    var stringMatchMap = (matchState as Map<String, dynamic>);

    var errors =
        stringMatchMap.keys.fold(<String>[], (List<String> previousValue, key) {
      previousValue.add("$key : ${stringMatchMap[key].toString()}");
      return previousValue;
    });

    return mismatchDescription.addAll("[", ",", "]", errors);
  }

  void _testFeature(
      Map matchState, String featureName, void Function() matcher) {
    final errorDesc = "$featureName-mismatch";
    if (matchState.containsKey(errorDesc))
      throw ArgumentError("cannot rematch the same feature", featureName);

    try {
      matcher();
    } on TestFailure catch (e) {
      matchState[errorDesc] = e.message ?? "";
    }
  }
}
