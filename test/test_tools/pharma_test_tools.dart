import 'dart:math';

import 'package:medlog/src/model/pharmaceutical/dosage.dart';
import 'package:medlog/src/model/pharmaceutical/pharmaceutical.dart';
import 'package:medlog/src/repo/pharmaceutical/pharmaceutical_repo.dart';

List<String> _tradenames = ["Tradename 1", "Tradename 2"];
List<String> _dosages = ["10mg", "20mg", "25mg", "1g"];
List<String> _substance = ["Substance 1", "Substance 2", "Substance 3"];

Pharmaceutical generatePharmaceutical() {
  return Pharmaceutical.create(
      id: PharmaceuticalRepo.createPharmaID(),
      tradename: _listGetRnd(_tradenames),
      dosage: Dosage.parse(_listGetRnd(_dosages)),
      substances: [_listGetRnd(_substance)]); //TODO: generate multiple substances
}

T _listGetRnd<T>(List<T> list) {
  var rnd = Random();
  return list[rnd.nextInt(list.length)];
}
