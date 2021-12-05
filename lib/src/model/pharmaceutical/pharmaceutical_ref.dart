import 'package:medlog/src/model/pharmaceutical/pharmaceutical.dart';

import 'dosage.dart';

class PharmaceuticalRef implements Pharmaceutical {
  bool registered = false;
  Pharmaceutical ref;

  @override
  String get id => ref.id;

  @override
  set id(value) => ref.id = value;

  @override
  bool get isIded => ref.isIded;

  @override
  DocumentState get documentState => ref.documentState;

  @override
  String? get activeSubstance => ref.activeSubstance;

  @override
  Dosage get dosage => ref.dosage;

  @override
  double get minUnit => ref.minUnit;

  @override
  String? get human_known_name => ref.human_known_name;

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
  Pharmaceutical cloneAndUpdate(
      {String? humanName,
      String? tradename,
      Dosage? dosage,
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
