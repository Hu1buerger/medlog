import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:given_when_then_unit_test/given_when_then_unit_test.dart';
import 'package:medlog/src/util/store.dart';
import 'package:mocktail/mocktail.dart' hide when;
import 'package:mocktail/mocktail.dart' as mktl show when;

//TODO: test that clean is false after write
void main() {
  given("mocked file", () {
    File file = MockFile();

    setUp(() async {
      reset(file);
      // setup the mock so initializing the store dosnt throw
      mktl.when(() => file.parent).thenReturn(Directory.current);
      mktl.when(() => file.existsSync()).thenReturn(true);
    });

    when("the store contains values", () {});
    test("test s/r on cache", () {
      // s/r as store & retrieve
      Store store = JsonStore(file: file);

      const String key = "test";
      const String value = "value";

      expect(store.containsKey(key), isFalse);

      store.insertString(key, value);
      expect(store.getString(key), value);
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

  given("empty file", () {
    late File file;
    late Store store;

    before(() {
      file = _emptyTmpFile();
      store = JsonStore(file: file);
    });

    when("loading from file", () {
      then("the store shall not throw", () async {
        expect(() => store.load(), returnsNormally, reason: "the store shall handle an empty file");
      });
    });
    when("storing a valid store", () {
      then("file should exist", () {
        assert(file.lengthSync() == 0);
        store.insertString("test", "test");

        expect(file.existsSync(), isTrue);
      });

      then("the file should contain data", () async {
        assert(file.lengthSync() == 0);
        store.insertString("test", "test");

        await store.flush();
        expect(file.lengthSync() > 0, isTrue);
      });
    });
  });

  given("valid file", () {
    then("load should contain all keys", () async {
      final file = _emptyTmpFile();
      file.createSync();

      Json items = generateData();
      Store store = JsonStore(file: file);

      items.forEach((key, value) => store.insertString(key, value.toString()));
      await store.flush();
      //end of generating data

      Store store2 = JsonStore(file: file);
      await store2.load();

      for (var entry in items.entries) {
        expect(store.containsKey(entry.key), isTrue);
        expect(store.getString(entry.key), entry.value);
      }
    });
  });

  given("empty JsonStore", () {
    var file = _emptyTmpFile();
    late Store store;

    before(() => store = JsonStore(file: file));

    given("value as string", () {
      const String key = "key";
      const String value = "value";

      when("inserting string", () {
        then("inserting the same key, even though it is already contained should throw", () {
          store.insertString(key, value);

          expect(() => store.insertString(key, value), throwsA(anything));
        });
        then("retrieving it should result the same value", () {
          store.insertString(key, value);

          expect(store.getString(key), isNot(throwsA(anything)));
          expect(store.getString(key), value);
        });
        then("loading other type should throw", () {
          store.insertString(key, value);

          expect(() => store.getJson(key), throwsA(anything));
        });
      });

      when("updating key", () {
        when("[AND] the key is not present", () {
          then(",it should be inserted", () {
            assert(store.containsKey(key) == false);

            store.updateString(key, value);
            expect(store.containsKey(key), isTrue);
          });
        });

        when("[AND] the key is present", () {
          before(() => store.insertString(key, value));

          then("a contained key should change value", () {
            const val2 = "val2";
            assert(val2 != value);

            store.updateString(key, val2);
            expect(store.getString(key), val2);
          });

          then("inserting another type should change the type", () {
            final Map<String, dynamic> val2 = {"string": "string"};
            store.updateJson(key, val2);

            expect(store.getJson(key), val2);
          });
        });
      });
    });
  });
}

final tmpDir = Directory.systemTemp.createTempSync();
int fileNO = -1;
File _emptyTmpFile() {
  fileNO++;
  return File(tmpDir.path + "/$fileNO.txt");
}

Json generateData() {
  int entrys = 10;

  Json result = {};
  for (var i = 0; i < entrys; i++) {
    result[_randomString()] = _randomString();
  }

  return result;
}

String _randomString() {
  Random rng = Random();
  int length = rng.nextInt(59) + 1;

  return String.fromCharCodes(List.generate(length, (index) => rng.nextInt(33) + 89));
}

class MockFile extends Mock implements File {}
