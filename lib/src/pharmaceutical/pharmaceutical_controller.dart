import 'package:medlog/src/pharmaceutical/pharma_service.dart';
import 'package:medlog/src/pharmaceutical/pharmaceutical.dart';

class PharmaceuticalController {

  final PharmaService pharmaservice;

  List<Pharmaceutical> pharmStore = [];
  List<Pharmaceutical> get pharmaceuticals => pharmStore;

  List<String> get tradenames {
    return pharmaceuticals.map((e) => e.tradename).toSet().toList();
  }

  PharmaceuticalController(this.pharmaservice);

  Future<void> load() async {
    var pharms = await pharmaservice.load();
    for(var p in pharms) {
      _addPharmaceutical(p);
    }
  }

  Future<void> store() async{

  }

  createPharmaceutical(String tradename, String dosage, String activeSubstance){
    Pharmaceutical p = Pharmaceutical(DocumentState.user_created, tradename, dosage, activeSubstance);
    _addPharmaceutical(p);
  }

  _addPharmaceutical(Pharmaceutical pharm) {
    var p = pharmaceuticalByNameAndDosage(pharm.tradename, pharm.dosage);
    // check wheter it is already known
    if (p != null) {
      assert(p.id == pharm.id);
      return;
    }
    _insert(pharm);
  }

  Pharmaceutical? pharmaceuticalByNameAndDosage(String tradename, String dose) {
    var p = pharmaceuticals
        .where((element) => element.tradename == tradename)
        .where((element) => element.dosage == dose)
        .toList();

    assert(p.length < 2);

    return p.isNotEmpty ? p.first : null;
  }

  List<Pharmaceutical> pharmaceuticalByTradeName(String tradename) {
    return pharmaceuticals.where((element) => element.tradename == tradename).toList();
  }

  Pharmaceutical getOrCreate(String tradename, String dose) {
    var p = pharmaceuticalByNameAndDosage(tradename, dose);

    if (p == null) {
      p = Pharmaceutical(DocumentState.user_created, tradename, dose, "UNASSIGNED");
      _insert(p);
    }

    return p;
  }

  void _insert(Pharmaceutical p) {
    if(p.id == -1) {
      p = Pharmaceutical(p.documentState, p.tradename, p.dosage, p.activeIngredient, id: pharmaservice.getNextFreeID());
    }else{
      if(pharmaceuticals.any((element) => element.id == p.id)) throw StateError("Id is already taken");
    }

    pharmStore.add(p);
  }
}