import 'package:medlog/src/pharmaceutical/pharmaceutical.dart';

class PharmaceuticalController {
  static PharmaceuticalController provider = PharmaceuticalController({});

  //map of medname to pharmaceuticals;
  Map<String, List<Pharmaceutical>> _pharmaMap;


  List<Pharmaceutical> get pharmaceuticals =>
      _pharmaMap.isEmpty ? [] :
      _pharmaMap.values.reduce((List<Pharmaceutical> previousValue, List<Pharmaceutical> element) =>
      previousValue + element);

  List<String> get tradenames {
    return pharmaceuticals.map((e) => e.tradename).toSet().toList();
  }

  PharmaceuticalController(this._pharmaMap);

  addPharmaceutical(Pharmaceutical pharm) {
    var p = pharmaceuticalByNameAndDosage(pharm.tradename, pharm.dosage);
    // check wheter it is already known
    if (p != null) return;

    _insert(pharm);
  }

  _insert(Pharmaceutical pharm) {
    if (!_pharmaMap.containsKey(pharm.tradename)) {
      _pharmaMap[pharm.tradename] = <Pharmaceutical>[];
    }

    _pharmaMap[pharm.tradename]!.add(pharm);
  }

  Pharmaceutical? pharmaceuticalByNameAndDosage(String tradename, String dose) {
    var listOfSameName = _pharmaMap[tradename];
    if (listOfSameName == null) return null;

    var p = listOfSameName.where((element) => element.dosage == dose);

    assert(p.length < 2);

    return p.isNotEmpty ? p.first : null;
  }

  List<Pharmaceutical> pharmaceuticalByTradeName(String tradename){
    return pharmaceuticals.where((element) => element.tradename == tradename).toList();
  }

  Pharmaceutical getOrCreate(String tradename, String dose) {
    var p = pharmaceuticalByNameAndDosage(tradename, dose);

    if (p == null) {
      p = Pharmaceutical(tradename, dose);
      _insert(p);
    }

    return p;
  }
}