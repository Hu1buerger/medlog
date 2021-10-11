import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService<T> {
  static SharedPreferences? preferences;

  late final Logger _logger;
  final JsonConverter<T> _jsonConverter;
  final String _storageKey;

  Logger get logger => _logger;

  StorageService(String storageKey, JsonConverter<T> jsonConverter, Logger logger)
      : _storageKey = storageKey,
        _jsonConverter = jsonConverter,
        _logger = logger;

  static Future _init() async {
    if (preferences == null) {
      WidgetsFlutterBinding.ensureInitialized();
      preferences = await SharedPreferences.getInstance();
    }
  }

  List<String> loadRawData() {
    if (preferences!.containsKey(_storageKey) == false) return [];
    return preferences!.getStringList(_storageKey)!;
  }

  List<Map<String, dynamic>> loadJsonObjects() {
    final listOfJsons = loadRawData();

    return listOfJsons.map((e) => json.decode(e) as Map<String, dynamic>).toList();
  }

  Future<List<T>> load() async {
    await _init();

    var obsMaps = loadJsonObjects();
    if (obsMaps.isEmpty) return <T>[];

    List<T> obs;
    try {
      obs = obsMaps.map((e) => _jsonConverter.fromJson(e)).toList();
      // ignore: deprecated_member_use, the runtime throws CastError when our converter functions cast to the new type while an old type is stored
    } on CastError catch (e) {
      _logger.severe("Error while converting the jsonStrings to objects", e, StackTrace.current);
      //combine all jsonobjects to a jsonList
      onIllegalDataFormat("$_storageKey: [${obsMaps.map((e) => jsonEncode(e)).reduce((value, element) => value = value + "," + element)}]");
      obs = <T>[];
    }

    return obs;
  }

  Future<void> store(List<T> list) async {
    await _init();

    var strings = stringsEncode(list);
    var writeFut = preferences!.setStringList(_storageKey, strings.toList());
    // ignore: unnecessary_cast
    return writeFut as Future<void>;
  }

  Iterable<Map<String,dynamic>> encodeToMaps(List<T> list){
    return list.map((e) => _jsonConverter.toJson(e));
  }

  Iterable<String> stringsEncode(List<T> list){
    var strings = encodeToMaps(list)
        .map((e) => json.encode(e));

    return strings;
  }

  Future<void> onIllegalDataFormat(String data) async {
    logger.severe("policy for illegalConversion is clearing...");
    //write the data to the disk as for now... this can be a security risk due to dumping possibly encrypted data to logcat
    logger.info("dumping the contents: $data");

    await clear();
  }

  Future<void> clear() async {
    await _init();
    preferences!.remove(_storageKey);
  }
}

class JsonConverter<T> {
  Map<String, dynamic> Function(T) toJson;
  T Function(Map<String, dynamic>) fromJson;

  JsonConverter({required this.toJson, required this.fromJson});
}
