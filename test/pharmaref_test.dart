import 'package:flutter_test/flutter_test.dart';
import 'package:medlog/src/pharmaceutical/pharmaceutical.dart';

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

void testEquals(Pharmaceutical a, Pharmaceutical b) {
  expect(a.id, b.id);
  expect(a.tradename, b.tradename);
  expect(a.dosage, b.dosage);
  expect(a.activeSubstance, b.activeSubstance);
  expect(a.pzn, b.pzn);
}
