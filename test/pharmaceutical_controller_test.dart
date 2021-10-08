import 'package:flutter_test/flutter_test.dart';
import 'package:medlog/src/pharmaceutical/pharma_service.dart';
import 'package:medlog/src/pharmaceutical/pharmaceutical.dart';
import 'package:medlog/src/pharmaceutical/pharmaceutical_controller.dart';

PharmaceuticalController pc = PharmaceuticalController(PharmaService());

void main() async {
  await pc.load();

  test("test pharmaceuticals types", testPCcontainsOnlyRefs);
  test("test create pharmaceutical", () {
    pc.createPharmaceutical(Pharmaceutical(
        human_known_name: "RETARDIN AL 25mg", tradename: "RETARDIN", dosage: "25mg", activeSubstance: "Homopathie"));
    pc.pharmaceuticalByNameAndDosage("RETARDIN AL 25mg", "25mg");
  });
  test("test pharms type post creation", testPCcontainsOnlyRefs);
}

void testPCcontainsOnlyRefs() {
  for (var p in pc.pharmaceuticals) {
    expect(PharmaceuticalRef, p.runtimeType);
  }
}
