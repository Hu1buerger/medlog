import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:logging/logging.dart';
import 'package:medlog/src/util/filesystem_util.dart';
import 'package:package_info_plus/package_info_plus.dart';

typedef Json = Map<String, dynamic>;

abstract class Store {
  Future<void> load();
  Future<void> flush();

  void storeJson(String key, Json json);
  void storeString(String key, String value);

  Json loadJson(String key);
  String loadString(String key);

  bool containsKey(String key);
}

//TODO: maybe hide certain keys ie HIDDEN-VersionKey 
class JsonStore implements Store {
  JsonStore({required File file, this.backupmanager}) {
    if (file.parent.existsSync() == false) throw ArgumentError("the directory which contains file dosnt exist");

    if (file.existsSync()) {
      logger.fine("file exists");
    } else {
      logger.fine("creating file");
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

    _cache = jsonDecode(content);
    clean = true;

    if(backupmanager != null){
      await backupmanager!.checkAndDoBackup(this);
      _cache[backupmanager!.versionKey] = await VersionHandler.getVersion();
    }
  }

  @override
  Future<void> flush() {
    if (clean) logger.fine("flushing even though the store is clean");

    var content = jsonEncode(_cache);
    return _file.writeAsString(content);
  }

  @override
  bool containsKey(String key) {
    return _cache.containsKey(key);
  }

  @override
  void storeJson(String key, Json json) => _cache[key] = json;

  @override
  void storeString(String key, String value) => _cache[key] = value;

  @override
  String loadString(String key) {
    if (containsKey(key) == false) throw ArgumentError("key not available");
    return _cache[key] as String;
  }

  @override
  Json loadJson(String key) {
    if (containsKey(key) == false) throw ArgumentError("key not available");
    return _cache[key] as Json;
  }
}

class Backupmanager{
  static const String appIdentifier = "io.hu1buerger.medlog";
  static const String constVersionKey = "$appIdentifier/version";

  static const String latestFileName = "latest.json";

  static final Logger logger = Logger("Backupmanager");

  Backupmanager();

  String get versionKey => constVersionKey;
  
  Future<bool> _shouldBackup(Store store) async {
    if (store.containsKey(versionKey)) {
      final filesAppVersion = store.loadString(versionKey);

      if (filesAppVersion.isEmpty) {
        logger.severe("the file did contain the VERSION_KEY but no version");
        return true;
      }
      final currentVersion = await VersionHandler.getVersion();

      if (filesAppVersion == currentVersion) {
        return false;
      }
    }
    return true;
  }

  Future checkAndDoBackup(JsonStore store) async {
    //assert(_latestFile == store.file);

    final state = await _shouldBackup(store);
    if(state){
      logger.fine("version missmatch doing backup");
      
      String path = store.file.parent.newFilePath("${DateTime.now().toIso8601String()}.json");
      await store.file.copy(path);
      logger.info("copyed the current state to $path");
      //_updateFiles();
    }
  }
}

class VersionHandler {
  static Future<PackageInfo> pkgInfo = PackageInfo.fromPlatform();

  static Future<String> getVersion() async {
    var info = await pkgInfo;
    return info.version;
  }
}
