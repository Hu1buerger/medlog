class Dosage {
  ///units that are recognized rn
  static const units = ["mg", "ng", "g", "mg/ml"];

  final double value;
  final String unit;

  Dosage(this.value, this.unit);

  @override
  String toString() {
    String valString;
    if (value.toInt() == value) {
      valString = value.toInt().toString();
    } else {
      valString = value.toString();
    }

    return "$valString $unit";
  }

  static Dosage parse(String s) {
    if (units.any((element) => s.contains(element)) == false) {
      throw ArgumentError.value(s, "arg", "dosnt contain unit and cnnt be parsed");
    }

    var unit = "";
    for (var u in units) {
      if (s.contains(u) == false) continue;

      // the longer match should be the right unit
      if (u.length > unit.length) unit = u;
    }

    assert(unit.isNotEmpty);

    var sSplit = s.split(unit);
    if (sSplit.length != 2) throw ArgumentError.value(s, "argument", "dosnt seem to contain any value");

    var valuePart = sSplit.first;
    var value = double.parse(valuePart);

    return Dosage(value, unit);
  }

  /// scales the current instance
  Dosage scale(double factor) {
    if (factor <= 0) throw ArgumentError.value(factor);

    return Dosage(value * factor, unit);
  }
}
