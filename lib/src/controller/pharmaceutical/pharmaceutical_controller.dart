import 'package:logging/logging.dart';
import 'package:medlog/src/controller/pharmaceutical/pharma_service.dart';
import 'package:medlog/src/model/pharmaceutical/pharmaceutical.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_util.dart';

class PharmaceuticalController {
  /// uid generator using crypto random number generator;
  static final Uuid uuid = Uuid(options: {'grng': UuidUtil.cryptoRNG()});
  final Logger _logger = Logger("PharmaceuticalController");
  final PharmaService _pharmaservice;

  final List<PharmaceuticalRef> _pharmStore = [];

  List<Pharmaceutical> get pharmaceuticals => _pharmStore;

  List<String> get tradenames {
    return pharmaceuticals.map((e) => e.tradename).toSet().toList();
  }

  List<String> get human_known_names => pharmaceuticals.map((e) => e.human_known_name).toList();

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
    assert(p.id_is_set == false);

    List<Pharmaceutical> matches;
    // non user_created instances can assure that the id is unique
    if (p.documentState != DocumentState.user_created) {
      // get match by id
      matches = pharmaceuticals.where((element) => element.id == p.id).toList();

      assert(matches.length < 2);
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

  ///
  /// inserting takes an amortized constant time
  /// if checking for duplicates is necessary the worst case runtime should be O(N) where N is the length of known pharmaceuticals
  void _insert(Pharmaceutical p) {
    if (p.id_is_set == false) {
      p = PharmaceuticalRef(p.cloneAndUpdate(id: _createPharmaID()));
    } else {
      if (pharmaceuticals.any((element) => element.id == p.id)) throw StateError("Id is already taken");
    }

    if (p is PharmaceuticalRef == false) {
      p = PharmaceuticalRef(p);
    }

    _pharmStore.add(p as PharmaceuticalRef);
    p.registered = true;
  }

  // might use optional instead of nullable type
  Pharmaceutical? pharmaceuticalByID(String id){
   assert(_isValidPharmaID(id));
   var results = pharmaceuticals.where((element) => element.id == id).toList();
   assert(results.length < 2);

   return results.isEmpty ? null : results.single;
  }

  Pharmaceutical? pharmaceuticalByNameAndDosage(String tradename, String dose) {
    var p = pharmaceuticals
        .where((element) => element.human_known_name.startsWith(tradename))
        .where((element) => element.dosage == dose)
        .toList();

    assert(p.length < 2);

    return p.isNotEmpty ? p.first : null;
  }

  List<Pharmaceutical> filter(String query) {
    var filters = [
      (Pharmaceutical p, String queryString) => p.human_known_name.contains(queryString),
      (Pharmaceutical p, String queryString) => p.tradename.contains(queryString),
    ];

    return pharmaceuticals.where((element) => filters.map((e) => e(element, query)).contains(true)).toList();
  }

  bool _isValidPharmaID(String id) {
    // enforce RFC4122 UUIDS, this refuses to validate GUID from microsoft.
    return Uuid.isValidUUID(fromString: id, validationMode: ValidationMode.strictRFC4122);
  }

  String _createPharmaID() {
    return uuid.v4();
  }
}
