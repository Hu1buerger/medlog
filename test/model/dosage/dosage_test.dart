import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:medlog/src/model/pharmaceutical/dosage.dart';

main() {
  test("test parsing", () {
    var rng = Random();
    int repetitions = 200;

    for (int i = 0; i < repetitions; i++) {
      var dosage = Dosage(
          rng.nextDouble() * 1000, Dosage.units[i % Dosage.units.length]);

      var string = dosage.toString();
      var parsedDosage = Dosage.parse(string);

      _testEquals(parsedDosage, dosage);
    }
  });
}

void _testEquals(Dosage actual, Dosage expected) {
  expect(actual.value, expected.value);
  expect(actual.unit, expected.unit);
}
