import 'dart:math';

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
