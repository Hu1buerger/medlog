import 'dart:math';

import 'package:medlog/src/administration_log/log_service.dart';
import 'package:medlog/src/pharmaceutical/pharmaceutical.dart';

class PharmaService extends StorageService<Pharmaceutical> {
  static String storageKey = "pharmaceuticals";
  static JsonConverter<Pharmaceutical> jsonConverter =
      JsonConverter(toJson: (t) => t.toJson(), fromJson: (json) => Pharmaceutical.fromJson(json));

  PharmaService() : super(storageKey, jsonConverter);

  int lastID = 0;

  int getNextFreeID() {
    return ++lastID;
  }

  @override
  Future<List<Pharmaceutical>> load() async {
    var pharmaceuticals = await super.load();

    if (pharmaceuticals.isEmpty) {
      // load mock data
      //pharmaceuticals = [
      //  Pharmaceutical(human_known_name: "Medikinet 20mg", tradename: "Medikinet", dosage: "20mg", activeSubstance: "Methylphenidat", id: 0),
      //  Pharmaceutical(human_known_name: "Medikinet 40mg", tradename: "Medikinet", dosage: "40mg", activeSubstance: "Methylphenidat", id: 1),
      //  Pharmaceutical(human_known_name: "Medikinet 60mg", tradename: "Medikinet", dosage: "60mg", activeSubstance: "Methylphenidat", id: 2),
      //  Pharmaceutical(human_known_name: "Ritalin 40mg", tradename: "Ritalin", dosage: "40mg", activeSubstance: "Methylphenidat", id: 4),
      //  Pharmaceutical(human_known_name: "Ritalin 20mg", tradename: "Ritalin", dosage: "20mg", activeSubstance: "Methylphenidat", id: 3),
      //  Pharmaceutical(human_known_name: "Hulio®", tradename: "Hulio", dosage: "40mg", activeSubstance: "Adalimumab", id: 5),
      //];
    }

    if(pharmaceuticals.isEmpty){
      lastID = 0;
    }else {
      lastID = pharmaceuticals.map((e) => e.id).reduce(max);
    }

    return pharmaceuticals;
  }
}
