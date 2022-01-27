import 'package:flutter_test/flutter_test.dart';
import 'package:medlog/src/model/pharmaceutical/pharmaceutical.dart';

class PharmaceuticalMatcher extends Matcher {
  PharmaceuticalMatcher(this.expected);

  final Pharmaceutical expected;

  @override
  Description describe(Description description) =>
      description.add("matches logical equality on two pharmaceuticals");

  @override
  Description describeMismatch(
      item, Description mismatchDescription, Map matchState, bool verbose) {
    return mismatchDescription.addAll(
        "Mismatch on: ",
        ", \n",
        "",
        matchState.entries
            .map((e) => (e.key as String) + " : " + (e.value as String)));
  }

  @override
  bool matches(item, Map matchState) {
    bool mismatch = false;
    mismatch |= _testMatch(matchState, "id", item.id, expected.id);
    mismatch |= _testMatch(matchState, "displayName", item.displayName, expected.displayName);
    mismatch |= _testMatch(matchState, "displaySubstance", item.displaySubstances, expected.displaySubstances);
    mismatch |= _testMatch(matchState, "dosage", item.dosage.toString(), expected.dosage.toString());
    mismatch |= _testMatch(matchState, "tradename", item.tradename, expected.tradename);
    mismatch |= _testMatch(matchState, "documentState", item.documentState, expected.documentState);

    return !mismatch;
  }

  _testMatch(Map matchState, String attrName, expected, actual) {
    try {
      expect(actual, expected);
      return false;
    } on TestFailure catch (f) {
      matchState[attrName] = f.message ?? "";
    }

    return true;
  }
}
