import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:given_when_then_unit_test/given_when_then_unit_test.dart';
import 'package:medlog/src/util/store.dart';
import 'package:mocktail/mocktail.dart' hide when;
import 'package:mocktail/mocktail.dart' as mktl show when;

void main() {
  group("mocktest", () {
    File file = MockFile();

    setUp(() async {
      reset(file);
      mktl.when(() => file.parent).thenReturn(Directory.current);
      mktl.when(() => file.existsSync()).thenReturn(true);
    });

    test("test s/r on cache", () {
      // s/r as store & retrieve
      Store store = JsonStore(file: file);

      const String key = "test";
      const String value = "value";

      expect(store.containsKey(key), isFalse);

      store.storeString(key, value);
      expect(store.loadString(key), value);
    });

    test("test write", () async {
      Store store = JsonStore(file: file);

      throwOnMissingStub(file as Mock);
      mktl.when(() => file.writeAsString(any())).thenAnswer((invocation) => Future.value(file));

      await store.flush();
      var res = verify(() => file.writeAsString(any())).called(1);
      res;
    });
  });

  given("emtpy file", () {
    when("storing a valid store", () {
      final file = _emptyTmpFile();
      var store = JsonStore(file: file);

      assert(file.lengthSync() == 0);

      store.storeString("test", "test");
      
      then("file should exist", (){
        expect(file.existsSync(), isTrue);
      });
      
      then("the file should contain data", () async {
        await store.flush();
        expect(file.lengthSync() > 0, isTrue);
      });
    });
  });

  given("valid file", (){
    then("load should contain all keys", () async {
      final file = _emptyTmpFile();
      file.createSync();
      
      Json items = generateData();
      Store store = JsonStore(file: file);

      items.forEach((key, value) => store.storeString(key, value.toString()));
      await store.flush();
      //end of generating data

      Store store2 = JsonStore(file: file);
      await store2.load();

      for(var entry in items.entries){
        expect(store.containsKey(entry.key), isTrue);
        expect(store.loadString(entry.key), entry.value);
      }
    });
  });

  given("operating on cache", (){
    var file = _emptyTmpFile();
    Store store = JsonStore(file: file);

    assert(file.lengthSync() == 0);

    when("adding string", (){
      const String key = "key";
      const String value = "value";
      store.storeString(key, "value");

      then("extracting string is valid", (){
        expect(store.loadString(key), isNot(throwsA(anything)));
        expect(store.loadString(key), value);
      });
      then("loading other type should throw", (){
        expect(() => store.loadJson(key), throwsA(anything));
      });
    });
  });
}

final tmpDir = Directory.systemTemp.createTempSync();
int fileNO = -1;
File _emptyTmpFile(){
  fileNO++;
  return File(tmpDir.path + "/$fileNO.txt");
}

Json generateData(){
  int entrys = 10;

  Json result = {};
  for (var i = 0; i < entrys; i++) {
    result[_randomString()] = _randomString();
  }

  return result;
}

String _randomString(){
  Random rng = Random();
  int length = rng.nextInt(59) + 1;

  return String.fromCharCodes(List.generate(length, (index) => rng.nextInt(33) + 89));
}
class MockFile extends Mock implements File {}
