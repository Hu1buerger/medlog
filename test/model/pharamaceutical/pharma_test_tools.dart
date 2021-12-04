import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:medlog/src/model/pharmaceutical/dosage.dart';
import 'package:medlog/src/model/pharmaceutical/pharmaceutical.dart';
import 'package:medlog/src/repo/pharmaceutical/pharmaceutical_repo.dart';

List<String> _tradenames = ["Tradename 1", "Tradename 2"];
List<String> _dosages = ["10mg", "20mg", "25mg", "1g"];
List<String> _substance = ["Substance 1", "Substance 2", "Substance 3"];

Pharmaceutical generatePharmaceutical() {
  return Pharmaceutical(
      id: PharmaceuticalRepo.createPharmaID(),
      tradename: _listGetRnd(_tradenames),
      dosage: Dosage.parse(_listGetRnd(_dosages)),
      activeSubstance: _listGetRnd(_substance));
}

T _listGetRnd<T>(List<T> list) {
  var rnd = Random();
  return list[rnd.nextInt(list.length)];
}

class PharmaceuticalMatcher extends Matcher {
  PharmaceuticalMatcher(this.expected);

  final Pharmaceutical expected;

  @override
  Description describe(Description description) => description.add("matches logical equality on two pharmaceuticals");

  @override
  Description describeMismatch(item, Description mismatchDescription, Map matchState, bool verbose) {
    return mismatchDescription.addAll(
        "Mismatch on: ", ", \n", "", matchState.entries.map((e) => (e.key as String) + " : " + (e.value as String)));
  }

  @override
  bool matches(item, Map matchState) {
    bool mismatch = false;
    mismatch |= _testMatch(matchState, "id", item.id, expected.id);
    mismatch |= _testMatch(matchState, "human_known_name", item.human_known_name, expected.human_known_name);
    mismatch |= _testMatch(matchState, "displayName", item.displayName, expected.displayName);
    mismatch |= _testMatch(matchState, "activeSubstance", item.activeSubstance, expected.activeSubstance);
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
