import 'package:medlog/src/model/pharmaceutical/pharmaceutical.dart';

import 'dosage.dart';

class PharmaceuticalRef implements Pharmaceutical {
  PharmaceuticalRef(this.ref);

  bool registered = false;
  Pharmaceutical ref;

  static PharmaceuticalRef toRef(Pharmaceutical p) {
    if (p is Pharmaceutical) {
      assert(p is PharmaceuticalRef == false);
      return PharmaceuticalRef(p);
    }
    return p as PharmaceuticalRef;
  }

  @override
  Pharmaceutical cloneAndUpdate(
      {String? tradename, Dosage? dosage, List<String>? substances, String? id, double? smallestPartialUnit}) {
    ref = ref.cloneAndUpdate(
        tradename: tradename, dosage: dosage, substances: substances, id: id, smallestPartialUnit: smallestPartialUnit);
    return this;
  }

  @override
  String get id => ref.id;

  @override
  String get displayName => ref.displayName;

  @override
  String? get displaySubstances => ref.displaySubstances;

  @override
  DocumentState get documentState => ref.documentState;

  @override
  Dosage get dosage => ref.dosage;

  @override
  bool get isIded => ref.isIded;

  @override
  double get smallestDosageSize => ref.smallestDosageSize;

  @override
  List<String> get substances => ref.substances;

  @override
  Map<String, dynamic> toJson() => ref.toJson();

  @override
  String get tradename => ref.tradename;

  @override
  set id(String _id) {
    throw Error();
  }
}
