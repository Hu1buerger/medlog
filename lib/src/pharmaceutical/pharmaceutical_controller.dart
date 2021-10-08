import 'package:logging/logging.dart';
import 'package:medlog/src/pharmaceutical/pharma_service.dart';
import 'package:medlog/src/pharmaceutical/pharmaceutical.dart';

class PharmaceuticalController {
  final Logger _logger = Logger("PharmaceuticalController");
  final PharmaService _pharmaservice;

  List<PharmaceuticalRef> _pharmStore = [];

  List<Pharmaceutical> get pharmaceuticals => _pharmStore;

  List<String> get tradenames {
    return pharmaceuticals.map((e) => e.tradename).toSet().toList();
  }

  PharmaceuticalController(this._pharmaservice);

  Future<void> load() async {
    var pharms = await _pharmaservice.load();
    for (var p in pharms) {
      _addPharmaceutical(p);
    }
  }

  Future<void> store() async {
    _pharmaservice.store(pharmaceuticals);
  }

  createPharmaceutical(Pharmaceutical p) {
    assert(p is PharmaceuticalRef == false);
    assert(p.documentState == DocumentState.user_created);

    _addPharmaceutical(p);
  }

  Pharmaceutical getTrackedInstance(Pharmaceutical p) {
    assert(p.id != -1);

    List<Pharmaceutical> matches;
    // non user_created instances can assure that the id is unique
    if (p.documentState != DocumentState.user_created) {
      // get match by id
      matches = pharmaceuticals
          .where((element) => element.documentState != DocumentState.user_created)
          .where((element) => element.id == p.id)
          .toList();
    } else {
      matches = pharmaceuticals
          .where((element) =>
              element.human_known_name == p.human_known_name &&
              element.dosage == p.dosage &&
              element.tradename == p.tradename &&
              element.activeSubstance == p.activeSubstance)
          .toList();
    }

    assert(matches.length == 1);
    assert(matches.single is PharmaceuticalRef);

    return matches.single;
  }

  void _addPharmaceutical(Pharmaceutical pharm) {
    var p = pharmaceuticalByNameAndDosage(pharm.tradename, pharm.dosage);
    // check wheter it is already known
    if (p != null) {
      _logger.fine("Refusing to add track $pharm bcs $p is already tracked");
      assert(p.id == pharm.id);
      return;
    }
    _insert(pharm);
  }

  void _insert(Pharmaceutical p) {
    if (p.id == -1) {
      p = PharmaceuticalRef(p.cloneAndUpdate(id: _pharmaservice.getNextFreeID()));
    } else {
      if (pharmaceuticals.any((element) => element.id == p.id)) throw StateError("Id is already taken");
    }

    if (p is PharmaceuticalRef == false) {
      p = PharmaceuticalRef(p);
    }

    _pharmStore.add(p as PharmaceuticalRef);
    p.registered = true;
  }

  Pharmaceutical? pharmaceuticalByNameAndDosage(String tradename, String dose) {
    var p = pharmaceuticals
        .where((element) => element.tradename.startsWith(tradename))
        .where((element) => element.dosage == dose)
        .toList();

    assert(p.length < 2);

    return p.isNotEmpty ? p.first : null;
  }

  List<Pharmaceutical> pharmaceuticalByTradeName(String tradename) {
    return pharmaceuticals.where((element) => element.tradename == tradename).toList();
  }

  List<Pharmaceutical> filter(String query) {
    var filters = [
      (Pharmaceutical p, String queryString) => p.human_known_name.contains(queryString),
      (Pharmaceutical p, String queryString) => p.tradename.contains(queryString),
    ];

    return pharmaceuticals.where((element) => filters.map((e) => e(element, query)).contains(true)).toList();
  }
}
