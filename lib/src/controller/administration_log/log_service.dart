import 'dart:convert';
import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:json_serializable/json_serializable.dart';
import 'package:logging/logging.dart';
import 'package:medlog/src/model/log_entry/log_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogService extends StorageService<LogEntry> {
  LogService() : super("log", JsonConverter(toJson: (t) => t.toJson(), fromJson: (json) => LogEntry.fromJson(json)),
      Logger("LogService"));
}

class StorageService<T> {
  static SharedPreferences? preferences;

  late final Logger _logger;
  final JsonConverter<T> _jsonConverter;
  final String _storageKey;

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

  Future<List<T>> load() async {
    await _init();

    if (preferences!.containsKey(_storageKey) == false) return <T>[];
    var listOfJsons = preferences!.getStringList(_storageKey)!;
    if (listOfJsons.isEmpty) return <T>[];

    var obsMaps = listOfJsons.map((e) => json.decode(e) as Map<String, dynamic>);

    List<T> obs;
    try {
      obs = obsMaps.map((e) => _jsonConverter.fromJson(e)).toList();
    // ignore: deprecated_member_use, the runtime throws CastError when our converter functions cast to the new type while an old type is stored
    } on CastError catch (e) {
      _logger.severe("Error while converting the jsonStrings to objects", e, StackTrace.current);
      //combine all jsonobjects to a jsonList
      onIllegalDataFormat("$_storageKey: [${listOfJsons.reduce((value, element) => value + ",")}]");
      obs = <T>[];
    }

    return obs;
  }

  Future<void> store(List<T> list) async {
    await _init();

    var strings = list.map((e) => _jsonConverter.toJson(e)).map((e) => json.encode(e));

    var writeFut = preferences!.setStringList(_storageKey, strings.toList());
    // ignore: unnecessary_cast
    return writeFut as Future<void>;
  }

  Future<void> onIllegalDataFormat(String data) async {
    _logger.severe("policy for illegalConversion is clearing...");
    //write the data to the disk as for now... this can be a security risk due to dumping possibly encrypted data to logcat
    _logger.info("dumping the contents: $data");

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
