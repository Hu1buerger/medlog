import 'package:flutter_test/flutter_test.dart';
import 'package:medlog/src/repo/pharmaceutical/pharma_service.dart';
import 'package:medlog/src/repo/pharmaceutical/pharmaceutical_repo.dart';
import 'package:medlog/src/model/pharmaceutical/dosage.dart';
import 'package:medlog/src/model/pharmaceutical/pharmaceutical.dart';
import 'package:medlog/src/model/pharmaceutical/pharmaceutical_ref.dart';

import 'mock_pharma_service.dart';

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

  group("localActions", () {
    var service = MockPharmaService([]);
    var controller = PharmaceuticalRepo(service);

    test("test retrieve a fresh created pharm by name and dosage", () => _testRetrieveByNameAndDosage(controller));
    test("test pharms type post creation", () => _testPCcontainsOnlyRefs(controller));
  });

  group("test collisionHandling", () {
    test("insert twice the same", () {
      var service = MockPharmaService([]);
      var controller = PharmaceuticalRepo(service);

      var p = Pharmaceutical(tradename: "idiotin", dosage: Dosage.parse("20mg"), activeSubstance: "masters");

      controller.createPharmaceutical(p);
      p = controller.getTrackedInstance(p);
      expect(() => controller.addPharmaceutical(p), isNot(throwsA(anything)));
    });

    test("insert different", () {
      var service = MockPharmaService([]);
      var controller = PharmaceuticalRepo(service);

      var p1 = Pharmaceutical(tradename: "a", dosage: Dosage.parse("1g"), activeSubstance: "a");
      var p2 = Pharmaceutical(tradename: "b", dosage: Dosage.parse("1g"), activeSubstance: "a");

      controller.createPharmaceutical(p1);
      controller.createPharmaceutical(p2);

      expect(controller.pharmaceuticals.length, 2);
    });

    test("insert a authored version", () {
      var service = MockPharmaService([]);
      var controller = PharmaceuticalRepo(service);

      var p = Pharmaceutical(tradename: "idiotin", dosage: Dosage.parse("20mg"), activeSubstance: "masters");

      controller.createPharmaceutical(p);
      p = controller.getTrackedInstance(p);

      var p2 = Pharmaceutical(
          id: p.id,
          tradename: p.tradename,
          dosage: p.dosage,
          activeSubstance: "otherSubstance",
          documentState: DocumentState.in_review);
      controller.addPharmaceutical(p2);

      var result = controller.pharmaceuticalByID(p2.id)!;
      testEquals(result, p2);
    });

    test("reject downgrade", () {
      var service = MockPharmaService([]);
      var controller = PharmaceuticalRepo(service);

      controller.addPharmaceutical(Pharmaceutical(
          id: PharmaceuticalRepo.createPharmaID(),
          tradename: "name",
          dosage: Dosage.parse("1g"),
          activeSubstance: "goFuckyourSelf",
          documentState: DocumentState.in_review));
      var p = controller.pharmaceuticals.first;

      var p2 = PharmaceuticalRef.toRef(
          (p as PharmaceuticalRef).ref.cloneAndUpdate(documentState: DocumentState.user_created));
      controller.addPharmaceutical(p2);

      expect(controller.pharmaceuticals.length, 1);
      expect(controller.pharmaceuticals.first.documentState, p.documentState);
    });
  });
}

void testEquals(Pharmaceutical actual, Pharmaceutical expected) {
  expect(actual.id, expected.id);
  expect(actual.human_known_name, expected.human_known_name);
  expect(actual.displayName, expected.displayName);
  expect(actual.activeSubstance, expected.activeSubstance);
  expect(actual.dosage, expected.dosage);
  expect(actual.tradename, expected.tradename);
  expect(actual.documentState, expected.documentState);
}

/// tests that all stored entrys are Refs to ensure updatablility
void _testPCcontainsOnlyRefs(PharmaceuticalRepo c) {
  for (var p in c.pharmaceuticals) {
    expect(PharmaceuticalRef, p.runtimeType);
  }
}

void _testRetrieveByNameAndDosage(PharmaceuticalRepo c) {
  var pharma = Pharmaceutical(
      human_known_name: "RETARDIN AL 25mg",
      tradename: "RETARDIN",
      dosage: Dosage.parse("25mg"),
      activeSubstance: "Homopathie");
  c.createPharmaceutical(pharma);
  var retrieved = c.pharmaceuticalByNameAndDosage("RETARDIN AL 25mg", Dosage.parse("25mg"));

  expect(retrieved != null, isTrue);
  // set the id of pharma to the id of retrieved bcs that gets updated on working behaviour
  retrieved!.id = pharma.id;
  testEquals(pharma, retrieved);
}

Future<PharmaceuticalRepo> createPharmaController(
    {int items = 0, bool fetchEnabled = false, bool mockedService = false}) async {
  // all items are fully configured
  var service;

  if (mockedService) {
    service = MockPharmaService([]);
  } else {
    print("CAUTION writing to the production data is possible, using production pharmaservice");
    service = PharmaService();
  }

  var controller = PharmaceuticalRepo(service, fetchEnabled: fetchEnabled);
  await controller.load();

  if (items > 0) {
    var testData = testPharmaceuticals(count: items);
    testData.forEach(controller.createPharmaceutical);
  }

  return controller;
}

void populatePC(PharmaceuticalRepo pc) {
  if (pc.pharmaceuticals.isEmpty) {
    pc.createPharmaceutical(Pharmaceutical(
        tradename: "TestPharamceutical", dosage: Dosage.parse("10mg"), activeSubstance: "TestSusbstance"));
  }
}

List<Pharmaceutical> testPharmaceuticals({int count = 1}) {
  return List.generate(
      count,
      (index) => Pharmaceutical(
          tradename: "Tradename-$index", dosage: Dosage.parse("$index mg"), activeSubstance: "Substance-$index"));
}
