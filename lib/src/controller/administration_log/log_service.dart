import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:medlog/src/model/administration_log/log_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogService extends StorageService<LogEntry> {
  LogService()
      : super(
            "log", JsonConverter(toJson: (t) => t.toJson(), fromJson: (json) => LogEntry.fromJson(json)));
}

class StorageService<T> {
  static SharedPreferences? preferences;

  final JsonConverter<T> _jsonConverter;
  final String _storageKey;

  StorageService(String storageKey, JsonConverter<T> jsonConverter)
      : _storageKey = storageKey,
        _jsonConverter = jsonConverter;

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
    var obs = obsMaps.map((e) => _jsonConverter.fromJson(e));
    return obs.toList();
  }

  Future<void> store(List<T> list) async {
    await _init();

    var strings = list.map((e) => _jsonConverter.toJson(e)).map((e) => json.encode(e));

    var writeFut = preferences!.setStringList(_storageKey, strings.toList());
    // ignore: unnecessary_cast
    return writeFut as Future<void>;
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
