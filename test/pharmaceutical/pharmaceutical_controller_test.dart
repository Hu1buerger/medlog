import 'package:flutter_test/flutter_test.dart';
import 'package:medlog/src/controller/pharmaceutical/pharmaceutical_controller.dart';
import 'package:medlog/src/model/pharmaceutical/pharmaceutical.dart';

import 'mock_pharma_service.dart';

PharmaceuticalController pc = PharmaceuticalController(MockPharmaService([]));

/// The pharmaceutical controller is a unit that handles the keeping of records for pharmaceuticals
///
/// Definitions:
///   - Pharmaceutical
///     - A unit that is purchasable on the market.
///     - It contains a substance that is causing the treatment effect (including homeopathics)
///     - It is identified by an id. This can either be created on the client device and is denoted by the [DocumentState.user_created]
///
/// Its tasks is
///   - to handout a unique PharmaceuticalRef for a Pharmaceutical
///   - updating the reference once it recieves an update about the parmaceutical
///   - delegate loading and storing to its service
///   - filtering the list of known pharmaceuticals for some query (open to mod)
///   - creating pharmaceuticals by the user
///
/// Future tasks:
///   - sending an update request to the server,
///   - merging remote changes with current changes
///
/// TODO: test only one ref, filtering, file operations,
void main() async {
  //setup empty
  pc = PharmaceuticalController(MockPharmaService([]));
  await pc.load();

  test("test create pharmaceutical", _testCreatePharmaceutical);
  test("test pharms type post creation", _testPCcontainsOnlyRefs);
}

void testEquals(Pharmaceutical a, Pharmaceutical b){
  expect(a.id, b.id);
  expect(a.human_known_name, b.human_known_name);
  expect(a.displayName, b.displayName);
  expect(a.activeSubstance, b.activeSubstance);
  expect(a.dosage, b.dosage);
  expect(a.tradename, b.tradename);
  expect(a.documentState, b.documentState);
}

/// tests that all stored entrys are Refs to ensure updatablility
void _testPCcontainsOnlyRefs() {
  for (var p in pc.pharmaceuticals) {
    expect(PharmaceuticalRef, p.runtimeType);
  }
}

void _testCreatePharmaceutical(){
  var pharma = Pharmaceutical(
      human_known_name: "RETARDIN AL 25mg", tradename: "RETARDIN", dosage: "25mg", activeSubstance: "Homopathie");
  pc.createPharmaceutical(pharma);
  var retrieved = pc.pharmaceuticalByNameAndDosage("RETARDIN AL 25mg", "25mg");

  expect(retrieved != null, isTrue);
  // set the id of pharma to the id of retrieved bcs that gets updated on working behaviour
  retrieved!.id = pharma.id;
  testEquals(pharma, retrieved);
}