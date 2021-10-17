import 'package:medlog/src/model/pharmaceutical/pharmaceutical.dart';

class PharmaceuticalRef implements Pharmaceutical {
  bool registered = false;
  Pharmaceutical ref;

  @override
  String get id => ref.id;

  @override
  set id(value) => ref.id = value;

  @override
  bool get id_is_set => ref.id_is_set;

  @override
  DocumentState get documentState => ref.documentState;

  @override
  String? get activeSubstance => ref.activeSubstance;

  @override
  String get dosage => ref.dosage;

  @override
  double get smallestConsumableUnit => ref.smallestConsumableUnit;

  @override
  String get human_known_name => ref.human_known_name;

  @override
  String get tradename => ref.tradename;

  @override
  String get displayName => ref.displayName;

  @override
  Map<String, dynamic> toJson() => ref.toJson();

  PharmaceuticalRef(this.ref) {
    if (ref is PharmaceuticalRef) throw ArgumentError();
  }

  @override
  Pharmaceutical cloneAndUpdate({String? humanName,
    String? tradename,
    String? dosage,
    String? activeSubstance,
    String? pzn,
    DocumentState? documentState,
    String? id,
    double? smallestPartialUnit}) {
    ref = ref.cloneAndUpdate(
        humanName: humanName,
        tradename: tradename,
        dosage: dosage,
        activeSubstance: activeSubstance,
        pzn: pzn,
        documentState: documentState,
        id: id,
        smallestPartialUnit: smallestPartialUnit);

    return this;
  }

  static PharmaceuticalRef toRef(Pharmaceutical p) {
    if (p is Pharmaceutical) {
      assert(p is PharmaceuticalRef == false);
      return PharmaceuticalRef(p);
    }
    return p as PharmaceuticalRef;
  }
}