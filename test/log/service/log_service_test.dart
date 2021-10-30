import 'package:flutter_test/flutter_test.dart';
import 'package:medlog/src/controller/log/log_service.dart';
import 'package:medlog/src/model/log_entry/log_event.dart';
import 'package:medlog/src/model/log_entry/medication_intake_event.dart';
import 'package:medlog/src/model/log_entry/stock_event.dart';
import 'package:shared_preferences/shared_preferences.dart';

main() {
  test("store and retrieve", () async {
    var dt1 = DateTime(2020, 10, 10, 18, 7, 20);
    var le = StockEvent(1, dt1, "pharmaID1", 20);
    var miE = MedicationIntakeEvent(2, dt1.add(Duration(minutes: 1)), "pharmaID1", 1);

    var list = [le, miE];

    SharedPreferences.setMockInitialValues({});

    var logService = LogService();
    await logService.store(list);
    var result = await logService.loadFromDisk();

    var matcher = unorderedMatches(list.map((e) => LogEventMatcher(e)));
    expect(result, matcher);
  });
}

class LogEventMatcher<T extends LogEvent> extends Matcher {
  final T expected;

  const LogEventMatcher(this.expected);

  @override
  Description describe(Description description) => description.add("matches logevents by field");

  @override
  bool matches(item, Map matchState) {
    assert(matchState.isEmpty);

    _testFeature(matchState, "type", () => expect(item.runtimeType, expected.runtimeType));
    // preemptively fail bcs the type mismatched
    if (matchState.isNotEmpty) return false;

    final actual = item as T;
    _testFeature(matchState, "id", () => expect(actual.id, expected.id));
    _testFeature(matchState, "eventTime",
        () => expect(actual.eventTime.toIso8601String(), expected.eventTime.toIso8601String()));

    switch (actual.runtimeType) {
      case MedicationIntakeEvent:
        var a = actual as MedicationIntakeEvent;
        var e = expected as MedicationIntakeEvent;

        _testFeature(matchState, "pharmaceuticalID", () => expect(a.pharmaceuticalID, e.pharmaceuticalID));
        _testFeature(matchState, "amount", () => expect(a.amount, e.amount));
        _testFeature(matchState, "source", () => expect(a.source, e.source));
        break;
      case StockEvent:
        var a = actual as StockEvent;
        var e = expected as StockEvent;

        _testFeature(matchState, "pharmaceuticalID", () => expect(a.pharmaceuticalID, e.pharmaceuticalID));
        _testFeature(matchState, "amount", () => expect(a.amount, e.amount));
        break;
      default:
        throw UnimplementedError("unknown type of LogEvent - test not implemented");
    }

    return matchState.isEmpty;
  }

  @override
  Description describeMismatch(item, Description mismatchDescription, Map matchState, bool verbose) {
    var stringMatchMap = (matchState as Map<String, dynamic>);

    var errors = stringMatchMap.keys.fold(<String>[], (List<String> previousValue, key) {
      previousValue.add("$key : ${stringMatchMap[key].toString()}");
      return previousValue;
    });

    return mismatchDescription.addAll("[", ",", "]", errors);
  }

  void _testFeature(Map matchState, String featureName, void Function() matcher) {
    final errorDesc = "$featureName-mismatch";
    if (matchState.containsKey(errorDesc)) throw ArgumentError("cannot rematch the same feature", featureName);

    try {
      matcher();
    } on TestFailure catch (e) {
      matchState[errorDesc] = e.message ?? "";
    }
  }
}
