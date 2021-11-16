import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:given_when_then_unit_test/given_when_then_unit_test.dart';
import 'package:medlog/src/util/filesystem_util.dart';
import 'package:medlog/src/util/store.dart';

import 'package:mocktail/mocktail.dart' hide when;
import 'package:mocktail/mocktail.dart' as mktl show when;

import 'store_test.dart';

void main() {
  given("a JsonStore with backupmanager", () {
    late File file;
    late Directory backupmanagerDir;

    before(() {
      backupmanagerDir = tmpDir.createTempSync();
      file = backupmanagerDir.createNamed(Backupmanager.latestFileName);
    });

    given("a file with content", () {
      late JsonStore jsonStore;

      before(() {
        file.createSync();

        var bckmgr = Backupmanager(backupmanagerDir);
        jsonStore = bckmgr.createStore();
      });

      when("the versionKey is not contained", () {
        const String content = '{}';

        before(() => file.writeAsStringSync(content));

        then("the backupmanager should create a backup", () async {
          await jsonStore.load();

          var files = backupmanagerDir.listFiles();
          expect(files.length, 2);
        });
      });

      when("the versionKey is contained", () {
        // ignore: prefer_function_declarations_over_variables
        String appVersion = "1.2.1";

        late MockVersionHandler versionHandler;

        before(() {
          versionHandler = MockVersionHandler();
          VersionHandler.Instance = versionHandler;

          mktl.when(() => versionHandler.getVersion()).thenAnswer((_) => Future.value(appVersion));
        });

        when("it is equal to the running version", () {
          String fileVersion = appVersion;

          before(() => writeMockStoreToFile(file, fileVersion));

          then("no new backupfile should be created", () async {
            await jsonStore.load();

            var files = backupmanagerDir.listFiles();
            //just one file should be created
            expect(files.length, 1);
          });
        });
        when("and the versions dont match", () {
          String fileVersion = "1.2.1.1";

          assert(appVersion != fileVersion);

          then("a new file should be created dueto backup", () async {
            await jsonStore.load();

            var files = backupmanagerDir.listFiles();

            // a backupfile and the current one should be created
            expect(files.length, 2);
          });
        });
      });
    });
  });
}

void writeMockStoreToFile(File file, String? fileAppVersion) {
  file.writeAsStringSync(generateStoreFile(fileAppVersion));
}

String generateStoreFile(String? fileAppVersion) {
  Json content = {};

  if (fileAppVersion != null) {
    content[Backupmanager.constVersionKey] = fileAppVersion;
  }

  var string = jsonEncode(content);
  assert(string.isNotEmpty);

  return string;
}

class MockVersionHandler extends Mock implements VersionHandler {}
