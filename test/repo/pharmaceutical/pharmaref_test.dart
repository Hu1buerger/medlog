import 'package:flutter_test/flutter_test.dart';
import 'package:medlog/src/model/pharmaceutical/dosage.dart';
import 'package:medlog/src/model/pharmaceutical/pharmaceutical.dart';
import 'package:medlog/src/model/pharmaceutical/pharmaceutical_ref.dart';

import '../../test_tools/matcher/pharmaceutical_matcher.dart';

/// test the updating of a ref (matches the usecase of updating a pharmaceutical i.e. changing the name)
void main() {
  Pharmaceutical a = Pharmaceutical(
      tradename: "TRADENAME_A",
      dosage: Dosage.parse("10mg"),
      substances: ["stupidity"],
      documentState: DocumentState.user_created);

  Pharmaceutical b = Pharmaceutical(
      tradename: "TRADENAME_B",
      dosage: Dosage.parse("20mg"),
      substances: ["truth"],
      documentState: DocumentState.in_review);

  PharmaceuticalRef ref = PharmaceuticalRef(a);

  test("test values equals", () => expect(a, PharmaceuticalMatcher(ref)));
  test("replace ref", () {
    ref.ref = b;

    expect(b, PharmaceuticalMatcher(ref));
    expect(b, equals(ref.ref));
    expect(a, isNot(equals(ref.ref)));
  });
}
