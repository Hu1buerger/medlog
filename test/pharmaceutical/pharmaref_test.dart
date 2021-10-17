import 'package:flutter_test/flutter_test.dart';
import 'package:medlog/src/model/pharmaceutical/pharmaceutical.dart';
import 'package:medlog/src/model/pharmaceutical/pharmaceutical_ref.dart';

import 'pharmaceutical_controller_test.dart' show testEquals;

/// test the updating of a ref (matches the usecase of updating a pharmaceutical i.e. changing the name)
void main() {
  Pharmaceutical a = Pharmaceutical(
      tradename: "TRADENAME_A",
      dosage: "10ccs of stupid",
      activeSubstance: "stupidity",
      documentState: DocumentState.user_created);

  Pharmaceutical b = Pharmaceutical(
      tradename: "TRADENAME_B",
      dosage: "20ccs of stupid",
      activeSubstance: "truth",
      documentState: DocumentState.in_review);

  PharmaceuticalRef ref = PharmaceuticalRef(a);


  test("test values equals", () => testEquals(a, ref));
  test("replace ref", () {
    ref.ref = b;

    testEquals(b, ref);
    expect(b, equals(ref.ref));
    expect(a, isNot(equals(ref.ref)));
  });
}
