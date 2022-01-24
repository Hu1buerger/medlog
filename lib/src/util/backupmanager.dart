import 'dart:io';

import 'package:logging/logging.dart';
import 'package:medlog/src/util/date_time_extension.dart';
import 'package:medlog/src/util/filesystem_util.dart';
import 'package:medlog/src/util/store.dart';
import 'package:medlog/src/util/version_handler.dart';
import 'package:path_provider/path_provider.dart';

Future<Backupmanager> backupmanager() async {
  const storeDir = "medlogstore";
  final appDocDir = await getApplicationDocumentsDirectory();
  final medlogDir = Directory(appDocDir.newFilePath(storeDir));

  if (await medlogDir.exists() == false) await medlogDir.create();

  return Backupmanager(medlogDir);
}

class Backupmanager {
  static const String appIdentifier = "io.hu1buerger.medlog";
  static const String constVersionKey = "$appIdentifier/version";

  static const String latestFileName = "latest.json";

  static final Logger logger = Logger("Backupmanager");

  // ignore: unused_field
  late Directory _managedDir;
  late File _latest;

  Backupmanager(Directory dir) {
    if (dir.existsSync() == false) throw ArgumentError();

    var possibleLatest = dir.createNamed(latestFileName);
    if (possibleLatest.existsSync() == false) possibleLatest.createSync();

    _latest = possibleLatest;
  }

  String get versionKey => constVersionKey;

  JsonStore createStore() {
    return JsonStore(file: _latest, backupmanager: this);
  }

  Future<bool> shouldBackup(Store store) async {
    if (store.containsKey(versionKey)) {
      final filesAppVersion = store.getString(versionKey);

      if (filesAppVersion.isEmpty) {
        logger.severe("the file did contain the VERSION_KEY but no version");
        return true;
      }

      final currentVersion = await VersionHandler.Instance.getVersion();
      if (filesAppVersion == currentVersion) {
        return false;
      }
    }
    return true;
  }

  Future doBackup(JsonStore store) async {
    //assert(_latestFile == store.file);
    logger.fine("version missmatch doing backup");

    // ignore: invalid_use_of_protected_member
    String path = store.file.parent.newFilePath("${DateTime.now().filesystemName()}.json");
    // ignore: invalid_use_of_protected_member
    await store.file.copy(path);
    logger.info("copyed the current state to $path");
    //_updateFiles();
  }
}
