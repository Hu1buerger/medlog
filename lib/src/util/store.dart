import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';

typedef Json = Map<String, dynamic>;

abstract class Store{

  Future<void> load();
  Future<void> flush();

  void storeJson(String key, Json json);
  void storeString(String key, String value);
  
  Json loadJson(String key);
  String loadString(String key);

  bool containsKey(String key);
}

class JsonStore implements Store{

  JsonStore({required File file}){
    if(file.parent.existsSync() == false) throw ArgumentError("the directory which contains file dosnt exist");
    
    if(file.existsSync()) {
      logger.fine("file exists");
    } else{
      logger.fine("creating file");
      file.createSync();
    }

    _file = file;
  }

  static Logger logger = Logger("JsonStore");
  late File _file;
  Map<String, dynamic> _cache = {};
  bool clean = true;

  @override
  Future<void> load() async {
    var content = await _file.readAsString();

    _cache = jsonDecode(content);
    clean = true;
  }

  @override
  Future<void> flush() {
    if(clean) logger.fine("flushing even though the store is clean");

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
    if(containsKey(key) == false) throw ArgumentError("key not available");
    return _cache[key] as String;
  }

  @override
  Json loadJson(String key) {
    if(containsKey(key) == false) throw ArgumentError("key not available");
    return _cache[key] as Json;
  }
}