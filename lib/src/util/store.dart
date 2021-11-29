import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:medlog/src/util/date_time_extension.dart';
import 'package:medlog/src/util/filesystem_util.dart';
import 'package:medlog/src/util/version_handler.dart';

typedef Json = Map<String, dynamic>;

//TODO: add a func to set a list as val
abstract class Store {
  Future<void> load();
  Future<void> flush();

  void insertJson(String key, Json json);
  void insertString(String key, String value);

  void updateJson(String key, Json value);
  void updateString(String key, String value);

  Json getJson(String key);
  String getString(String key);

  bool containsKey(String key);
}

//TODO: maybe hide certain keys ie HIDDEN-VersionKey
class JsonStore implements Store {
  JsonStore({required File file, this.backupmanager}) {
    if (file.parent.existsSync() == false) throw ArgumentError("the directory which contains file dosnt exist");

    if (!file.existsSync()) {
      logger.fine("creating file ${file.path}");
      file.createSync();
    }

    _file = file;
  }

  Logger logger = Logger("JsonStore");

  Backupmanager? backupmanager;

  late File _file;
  Map<String, dynamic> _cache = {};
  bool clean = true;

  @protected
  File get file => _file;

  @override
  Future<void> load() async {
    var content = await _file.readAsString();

    if (content.isNotEmpty) {
      _cache = jsonDecode(content);
    }
    clean = true;

    await _checkBackuptools();
  }

  /// if the backupmanager is instantiated use it and make backups
  _checkBackuptools() async {
    if (backupmanager != null) {
      await backupmanager!.checkAndDoBackup(this);
      _cache[backupmanager!.versionKey] = await VersionHandler.Instance.getVersion();
    }
  }

  @override
  Future<void> flush() {
    if (clean) logger.fine("flushing even though the store is clean");

    var content = jsonEncode(_cache);
    return _file.writeAsString(content);
  }

  @override
  bool containsKey(String key) => _cache.containsKey(key);

  @override
  void insertString(String key, String value) {
    if (containsKey(key)) throw StateError("key already contained");
    updateString(key, value);
  }

  @override
  void insertJson(String key, Json value) {
    if (containsKey(key)) throw StateError("key already contained");
    updateJson(key, value);
  }

  @override
  void updateJson(String key, Json value) => _cache[key] = value;

  @override
  void updateString(String key, String value) => _cache[key] = value;

  @override
  String getString(String key) {
    if (containsKey(key) == false) throw ArgumentError("key not available");
    return _cache[key] as String;
  }

  @override
  Json getJson(String key) {
    if (containsKey(key) == false) throw ArgumentError("key not available");
    return _cache[key] as Json;
  }
}

class Backupmanager {
  static const String appIdentifier = "io.hu1buerger.medlog";
  static const String constVersionKey = "$appIdentifier/version";

  static const String latestFileName = "latest.json";

  static final Logger logger = Logger("Backupmanager");

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

  Future<bool> _shouldBackup(Store store) async {
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

  Future checkAndDoBackup(JsonStore store) async {
    //assert(_latestFile == store.file);

    final state = await _shouldBackup(store);
    if (state) {
      logger.fine("version missmatch doing backup");

      String path = store.file.parent.newFilePath("${DateTime.now().fileSystemName()}.json");
      await store.file.copy(path);
      logger.info("copyed the current state to $path");
      //_updateFiles();
    }
  }
}
