import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:medlog/src/model/pharmaceutical/dosage.dart';
import 'package:medlog/src/model/pharmaceutical/pharmaceutical.dart';
import 'package:medlog/src/repo/pharmaceutical/pharmaceutical_filter.dart';

import '../test_tools/matcher/pharmaceutical_matcher.dart';

main() {
  final validChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz01234567890-.+#";

  group("string test", () {
    for (int i = 0; i < 25; i++) {
      test("!negate match - $i", () {
        PharmaceuticalFilter filter = PharmaceuticalFilter.test(negate: false);
        Random rng = Random();

        final value =
            String.fromCharCodes(Iterable.generate(100, (i) => validChars.codeUnitAt(rng.nextInt(validChars.length))));
        final query = value;

        expect(filter.stringPartialMatch(value, query), isTrue);
      });

      test("negate match - $i", () {
        PharmaceuticalFilter filter = PharmaceuticalFilter.test(negate: true);
        Random rng = Random();

        final value =
            String.fromCharCodes(Iterable.generate(100, (i) => validChars.codeUnitAt(rng.nextInt(validChars.length))));
        final query = value;

        expect(filter.stringPartialMatch(value, query), isFalse);
      });

      test("!negate !match - $i", () {
        PharmaceuticalFilter filter = PharmaceuticalFilter.test(negate: false);
        Random rng = Random();

        final query =
            String.fromCharCodes(Iterable.generate(100, (i) => validChars.codeUnitAt(rng.nextInt(validChars.length))));
        var value =
            String.fromCharCodes(Iterable.generate(100, (i) => validChars.codeUnitAt(rng.nextInt(validChars.length))));

        while (value == query) {
          value = String.fromCharCodes(
              Iterable.generate(100, (i) => validChars.codeUnitAt(rng.nextInt(validChars.length))));
        }

        expect(filter.stringPartialMatch(value, query), isFalse);
      });

      test("negate !match - $i", () {
        PharmaceuticalFilter filter = PharmaceuticalFilter.test(negate: true);
        Random rng = Random();

        final query =
            String.fromCharCodes(Iterable.generate(100, (i) => validChars.codeUnitAt(rng.nextInt(validChars.length))));
        var value =
            String.fromCharCodes(Iterable.generate(100, (i) => validChars.codeUnitAt(rng.nextInt(validChars.length))));

        while (value == query) {
          value = String.fromCharCodes(
              Iterable.generate(100, (i) => validChars.codeUnitAt(rng.nextInt(validChars.length))));
        }

        expect(filter.stringPartialMatch(query, value), isTrue);
      });
    }
  });

  test("test on pharmaceuticals", () {
    var pharms = [
      Pharmaceutical.create(tradename: "Naproxen", dosage: Dosage.parse("10mg"), substances: ["Naproxen"]),
      Pharmaceutical.create(tradename: "Abc-med", dosage: Dosage.parse("10mg"), substances: ["abc-med"]),
      Pharmaceutical.create(tradename: "Ebcabc-med", dosage: Dosage.parse("10mg"), substances: ["ebc-med"]),
    ];

    var filter = PharmaceuticalFilter(matcher: "Name", negate: false);

    var nap = pharms.where((p) => filter.isMatch(p: p, query: "nap")).toList();
    expect(nap.length, 1);
    expect(nap.single, PharmaceuticalMatcher(pharms[0]));

    var ket = pharms.where((p) => filter.isMatch(p: p, query: "abc")).toList();
    expect(ket.length, 2);
    expect(ket.toSet(), pharms.getRange(1, 3).toList().toSet());
  });
}
