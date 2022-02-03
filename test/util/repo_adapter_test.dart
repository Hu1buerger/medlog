// ignore_for_file: prefer_function_declarations_over_variables

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:given_when_then_unit_test/given_when_then_unit_test.dart';
import 'package:medlog/src/model/json.dart';
import 'package:medlog/src/model/pharmaceutical/pharmaceutical.dart';
import 'package:medlog/src/util/repo_adapter.dart';
import 'package:medlog/src/util/store.dart';
import 'package:mocktail/mocktail.dart' as mctl;
import 'package:tuple/tuple.dart';

import '../test_tools/matcher/pharmaceutical_matcher.dart';
import '../test_tools/pharma_test_tools.dart';

typedef Adapter = dynamic Function(dynamic);

/// key, loadAdapter, storeAdapter, encodedState, runtimeObject / matcher, the expected runtimetype after loading
typedef Testcase = Tuple5<String, dynamic Function(dynamic), dynamic, dynamic, Type>;

/// Test the RepoAdapter
///
/// It should handle converting all known jsonTypes to a runtime object.
/// Datatypes to test: string, num, bool, lists, objects (aka new json objects)
main() {
  // ignore: prefer_function_declarations_over_variables
  final pharmaLoadAdapter = (json) => Pharmaceutical.fromJson(json);
  // ignore: prefer_function_declarations_over_variables
  final pharmaStoreAdapter = (p) => p.toJson();

  when("loading", () {
    given("trivial datatypes", () {
      // string, num, bool,
      List<Testcase> testcases = [
        Testcase("int, int", (i) => i, 1, 1, int),
        Testcase("bool, bool", (i) => i, true, true, bool),
        Testcase("string, int", (val) => int.parse(val), "1", 1, int),
        Testcase("string, int", (enc) => enc as String, "string", "string", String),
      ];

      _runTestcases(testcases, _trivialTypesLoad);
    });

    given("trivial objects", () {
      List<Testcase> testcases = [
        // Map<String, dynamic> -> Pharmaceutical
        ...List.generate(10, (index) {
          var p = generatePharmaceutical();
          return Testcase("json, Pharmaceutical: pharm-$index", pharmaLoadAdapter, p.toJson(), PharmaceuticalMatcher(p),
              Pharmaceutical);
        })
      ];
      // append other testcases

      _runTestcases(testcases, _trivialTypesLoad);
    });

    given("lists", () {
      List<Testcase> testcases = [
        Testcase("key", (val) => int.parse(val), ["1", "2", "3"], [1, 2, 3], List),
        ...List.generate(2, (index) {
          var pharmaList = List.generate(10, (index) => generatePharmaceutical());
          var jsonList = pharmaList.map((e) => e.toJson()).toList();

          return Testcase("pharmaList-$index", pharmaLoadAdapter, jsonList,
              pharmaList.map((e) => PharmaceuticalMatcher(e)).toList(), List);
        })
      ];

      _runTestcases(testcases, _testComplexTypesLoad);
    });
  });

  when("storing", () {
    given("trivial datatypes", () {
      // string, num, bool,
      List<Testcase> testcases = [
        Testcase("int, int", (i) => i, 1, 1, int),
        Testcase("bool, bool", (i) => i, true, true, bool),
        Testcase("string, int", (val) => int.parse(val), "1", 1, int),
        Testcase("string, int", (enc) => enc as String, "string", "string", String),
      ];

      _runTestcases(testcases, _trivialTypesStore);
    });

    given("trivial objects", () {
      List<Testcase> testcases = [
        // Map<String, dynamic> -> Pharmaceutical
        ...List.generate(10, (index) {
          var p = generatePharmaceutical();
          return Testcase("json, Pharmaceutical: pharm-$index", pharmaStoreAdapter, p, p.toJson(), Json);
        })
      ];

      _runTestcases(testcases, _trivialTypesStore);
    });

    given("lists", () {
      List<Testcase> testcases = [
        Testcase("key", (val) => int.parse(val), ["1", "2", "3"], [1, 2, 3], List),
        ...List.generate(2, (index) {
          var pharmaList = List.generate(10, (index) => generatePharmaceutical());
          var jsonList = pharmaList.map((e) => e.toJson()).toList();

          return Testcase("pharmaList-$index", pharmaStoreAdapter, pharmaList, jsonList, List);
        })
      ];

      _runTestcases(testcases, _complexTypesStore);
    });
  });
}

_runTestcases(List<Testcase> cases, Function(Testcase) test) => cases.forEach(test);

_trivialTypesLoad(Testcase testcase) {
  final String key = testcase.item1;
  final adapter = testcase.item2;
  final dynamic valEncoded = testcase.item3;
  String partialValEnc = valEncoded.toString().substring(0, min(valEncoded.toString().length, 20));
  final dynamic matcher = testcase.item4;
  final resultType = testcase.item5;

  given("[AND] encoded value of $partialValEnc", () {
    late MockedStore kvstore;
    late RepoAdapter rpoAdpt;

    before(() {
      kvstore = MockedStore();
      rpoAdpt = RepoAdapter(kvstore);
    });

    when("the store dosnt hold the kv-pair", () {
      before(() {
        mctl.when(() => kvstore.containsKey(key)).thenReturn(false);
      });

      then("loading should throw", () {
        expect(() => rpoAdpt.load(key, adapter), throwsA(isA<ArgumentError>()));
      });
    });

    when("the store holds the value", () {
      before(() {
        mctl.when(() => kvstore.containsKey(key)).thenReturn(true);
        mctl.when(() => kvstore.get(key)).thenReturn(valEncoded);
      });

      then("loading shall not trow", () {
        expect(() => rpoAdpt.load(key, adapter), returnsNormally);
      });

      then("load should have been called on the kvstore", () {
        rpoAdpt.load(key, adapter);
        mctl.verify(() => kvstore.load()).called(1);
      }, skip: "currently not implemented on, and compensated by the app");

      then("the value should have been converted", () {
        expect(rpoAdpt.load(key, adapter), matcher);
      });

      then("the retrieved value should be of type ${resultType.toString()}", () {
        final val = rpoAdpt.load(key, adapter);
        expect(val.runtimeType, resultType);
      });
    });
  });
}

_trivialTypesStore(Testcase testcase) {
  final String key = testcase.item1;
  final storeAdapter = (i) => testcase.item2(i) as Object;
  final runtimeObject = testcase.item3;
  final encodedState = testcase.item4;

  given("[AND] runtimeObj $runtimeObject", () {
    late MockedStore kvstore;
    late RepoAdapter rpoAdpt;
    late Object? storedObj;

    before(() {
      kvstore = MockedStore();
      rpoAdpt = RepoAdapter(kvstore);

      mctl.when(() => kvstore.update(key, mctl.any())).thenAnswer((invocation) {
        storedObj = invocation.positionalArguments[1];
      });
    });

    then("store shouldnt throw", () {
      expect(() => rpoAdpt.store(key, runtimeObject, storeAdapter), returnsNormally);
    });

    then("load should have been called on the kvstore", () {
      rpoAdpt.store(key, runtimeObject, storeAdapter);
      mctl.verify(() => kvstore.flush()).called(1);
    }, skip: "currently not implemented on, and compensated by the app");

    then("storing should write the value", () {
      rpoAdpt.store(key, runtimeObject, storeAdapter);

      mctl.verify(() => kvstore.update(key, encodedState)).called(1);
      expect(storedObj, encodedState);
    });
  });
}

_testComplexTypesLoad(Testcase testcase) {
  final String key = testcase.item1;
  final adapter = testcase.item2;
  final dynamic valEncoded = testcase.item3;
  String partialValEnc = valEncoded.toString().substring(0, min(valEncoded.toString().length, 20));
  final List<dynamic> matcher = testcase.item4;
  final resultType = testcase.item5;

  assert(valEncoded is List);

  given("Encoded value of $partialValEnc", () {
    var kvstore = MockedStore();
    var rpoAdpt = RepoAdapter(kvstore);

    when("the store dosnt hold the kv-pair", () {
      before(() {
        mctl.when(() => kvstore.containsKey(key)).thenReturn(false);
      });

      then("loading should throw", () {
        expect(() => rpoAdpt.load(key, adapter), throwsA(isA<ArgumentError>()));
      });
    });

    when("the store holds another value, but not ours", () {
      before(() {
        mctl.when(() => kvstore.containsKey(key)).thenReturn(true);
        mctl.when(() => kvstore.get(key)).thenReturn("{}"); // string is definitely not a list
      });
    });

    when("the store holds the value", () {
      before(() {
        mctl.when(() => kvstore.containsKey(key)).thenReturn(true);
        mctl.when(() => kvstore.get(key)).thenReturn(valEncoded);
      });

      then("loading shall not trow", () {
        expect(() => rpoAdpt.loadList(key, adapter), returnsNormally);
      });

      then("load should have been called on the kvstore", () {
        rpoAdpt.loadList(key, adapter);
        mctl.verify(() => kvstore.load()).called(1);
      }, skip: "currently not implemented on, and compensated by the app");

      then("the value should have been converted", () {
        expect(rpoAdpt.loadList(key, adapter), unorderedMatches(matcher));
      });

      then("the retrieved value should be of type ${resultType.toString()}", () {
        final val = rpoAdpt.loadList(key, adapter);
        expect(val.runtimeType, resultType, skip: "cannot hold the type as of now");
      });
    });
  });
}

_complexTypesStore(Testcase testcase) {
  final String key = testcase.item1;
  final storeAdapter = (i) => testcase.item2(i) as Object;
  final runtimeObject = testcase.item3;
  final encodedState = testcase.item4;

  assert(runtimeObject is List);

  given("[AND] runtimeObj $runtimeObject", () {
    late MockedStore kvstore;
    late RepoAdapter rpoAdpt;
    late Object? storedObj;

    before(() {
      kvstore = MockedStore();
      rpoAdpt = RepoAdapter(kvstore);

      mctl.when(() => kvstore.update(key, mctl.any())).thenAnswer((invocation) {
        storedObj = invocation.positionalArguments[1];
      });
    });

    then("store shouldnt throw", () {
      expect(() => rpoAdpt.storeList(key, runtimeObject, storeAdapter), returnsNormally);
    });

    then("store should have been called on the kvstore", () {
      rpoAdpt.storeList(key, runtimeObject, storeAdapter);
      mctl.verify(() => kvstore.load()).called(1);
    }, skip: "currently not implemented on, and compensated by the app");

    then("storing should write the value", () {
      rpoAdpt.storeList(key, runtimeObject, storeAdapter);

      mctl.verify(() => kvstore.update(key, encodedState)).called(1);
      expect(storedObj, unorderedMatches(encodedState));
      expect(storedObj, isInstanceOf<List>());
    });
  });
}

class MockedStore extends mctl.Mock implements Store {}
