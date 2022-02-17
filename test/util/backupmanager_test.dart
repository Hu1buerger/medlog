import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:given_when_then_unit_test/given_when_then_unit_test.dart';
import 'package:medlog/src/model/json.dart';
import 'package:medlog/src/util/backupmanager.dart';
import 'package:medlog/src/util/filesystem_util.dart';
import 'package:medlog/src/util/store.dart';
import 'package:medlog/src/util/version_handler.dart';
import 'package:mocktail/mocktail.dart' hide when;
import 'package:mocktail/mocktail.dart' as mktl show when;

import 'store_test.dart';

//TODO: this test dosnt seem to test precisely
void main() {
  given("a JsonStore with backupmanager", () {
    late File file;
    late Directory backupmanagerDir;

    late MockVersionHandler versionHandler;

    String appVersion = "1.2.1";

    before(() {
      backupmanagerDir = tmpDir.createTempSync();
      file = backupmanagerDir.createNamed(Backupmanager.latestFileName);

      // mock the VersionHandler bcs PlatformTools throws on PackageInfo.getAll and that gets calle
      versionHandler = MockVersionHandler();
      VersionHandler.Instance = versionHandler;

      mktl.when(() => versionHandler.getVersion()).thenAnswer((_) => Future.value(appVersion));
    });

    // TODO: rewrite the tests,
    /*
     * Function:
     * - createBackup:
     *    + check that a backup has been created.
     * - should backup
     *
     */
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
