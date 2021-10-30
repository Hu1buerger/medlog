import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService<T> {
  static SharedPreferences? preferences;

  late final Logger logger;
  final JsonConverter<T>? _jsonConverter;
  final String _storageKey;

  List<T>? backLog;
  late final StreamController<T> _streamController;

  Stream<T> get events => _streamController.stream;

  StorageService(String storageKey, {Logger? logger, JsonConverter<T>? jsonConverter})
      : _storageKey = storageKey,
        logger = logger ?? Logger(storageKey),
        _jsonConverter = jsonConverter {
    _streamController = initStreamController();
  }

  /// sets the streamController up that is used for the publish action;
  StreamController<T> initStreamController() {
    return StreamController(onListen: () {
      _publishBackLog();
    });
  }

  Future<void> _init() async {
    if (preferences == null) {
      logger.fine("initializing the SharedPreferences");

      WidgetsFlutterBinding.ensureInitialized();
      preferences = await SharedPreferences.getInstance();
    }
  }

  /// loads the data from the local store.
  ///
  Future<List<T>> loadFromDisk() async {
    //assert(_streamController.hasListener == false);

    await _init();
    //await preferences!.reload();
    logger.finest("starting to load from disk");

    var obsMaps = loadJsonObjects();
    if (obsMaps.isEmpty) {
      return <T>[];
    }

    // convert all objects;
    List<T> obs = [];

    for (var o in obsMaps) {
      try {
        var item = fromJson(o);
        obs.add(item);
        publish(item);

        // ignore: deprecated_member_use, the runtime throws CastError when our converter functions cast to the new type while an old type is stored
      } on CastError catch (e) {
        logger.severe("Error while converting the jsonStrings to objects", e, StackTrace.current);
        //combine all jsonobjects to a jsonList
        onIllegalDataFormat(o);
      }
    }

    logger.finest("finishing load with ${obs.length} items");
    //assert(_streamController.hasListener == false);
    return obs;
  }

  /// stores the data to the local file
  Future<void> store(List<T> list) async {
    await _init();

    logger.finer("storing ${list.length} items");

    var strings = stringsEncode(list);
    var writeFut = preferences!.setStringList(_storageKey, strings.toList());
    // ignore: unnecessary_cast
    return writeFut as Future<void>;
  }

  /// cleares the local datarepo
  Future<void> clear() async {
    await _init();
    logger.fine("clearing datarepo");
    preferences!.remove(_storageKey);
  }

  /// turns all elements that were loaded to a list
  ///
  /// returns on done.
  /// EITHER getAll can be called XOR events.listen
  Future<List<T>> getAll() async {
    assert(_streamController.hasListener == false);
    logger.finest("requesting all knowledge as list");

    //await diskLoadDone;
    return events.toList();
  }

  void publish(T t) {
    if (_streamController.isClosed) {
      logger.severe("streamController is closed but still trying to publish", null, StackTrace.current);
    }

    if (backLog != null) {
      if (_streamController.hasListener == false || _streamController.isPaused) {
        logger.fine("publishing $t to the backlog");
        backLog?.add(t);

        return;
      }
    }

    logger.finest("publishing $t to the controller");
    _streamController.add(t);
  }

  void _publishBackLog() {
    assert(backLog == null || (backLog != null && (backLog!.isEmpty || _streamController.isClosed == false)));

    if (backLog != null) {
      logger.finer("publishing the backlog with ${backLog!.length} items");

      var bLog = backLog!;
      //disable the backlog for now
      backLog = null;
      for (var e in bLog) {
        publish(e);
      }

      //reenable the backlog
      backLog = [];
    }
  }

  void enableBacklog() {
    backLog ??= [];
  }

  void disableBacklog() {
    if (backLog != null) {
      _publishBackLog();
      backLog = null;
    }
  }

  void clearBacklog() {
    if (backLog != null) {
      backLog = [];
    }
  }

  /// signals that no new events will be emitted
  void signalDone() {
    if (_streamController.isClosed) {
      logger.finest("signaling done to closed controller");
      if (backLog?.isNotEmpty ?? false) {
        logger.severe("elements were backlogged but the eventStream was already closed");
      }
    }

    _publishBackLog();
    logger.fine("signaling done");
    _streamController.close();
  }

  /// gathers the objects stored in local file as Maps
  ///
  /// only conversion of encoding to Map<String, dynamic> aka jsonish
  List<Map<String, dynamic>> loadJsonObjects() {
    if (preferences!.containsKey(_storageKey) == false) {
      logger.finest("storageKey: {$_storageKey} not known");
      return [];
    }

    final listOfJsons = preferences!.getStringList(_storageKey)!;

    return listOfJsons.map((e) => json.decode(e) as Map<String, dynamic>).toList();
  }

  Iterable<Map<String, dynamic>> encodeToMaps(List<T> list) {
    return list.map((e) => toJson(e));
  }

  /// encodes the hole list to Strings using the jsonConverter object
  Iterable<String> stringsEncode(List<T> list) {
    var strings = encodeToMaps(list).map((e) => json.encode(e));

    return strings;
  }

  Future<void> onIllegalDataFormat(Map<String, dynamic> illegalDataformatItem) async {
    logger.severe("policy for illegalConversion is clearing...");
    //write the data to the disk as for now... this can be a security risk due to dumping possibly encrypted data to logcat
    //"$_storageKey: [${obsMaps.map((e) => jsonEncode(e)).reduce((value, element) => value = value + "," + element)}]";
    logger.info("dumping the contents: $illegalDataformatItem");

    //await clear();
  }

  T fromJson(Map<String, dynamic> json) {
    if (_jsonConverter == null) {
      throw StateError("the jsonConverter needs to be initialized or this function be overriden");
    }
    return _jsonConverter!.fromJson(json);
  }

  Map<String, dynamic> toJson(T t) {
    if (_jsonConverter == null) {
      throw StateError("the jsonConverter needs to be initialized or this function be overriden");
    }
    return _jsonConverter!.toJson(t);
  }
}

class JsonConverter<T> {
  Map<String, dynamic> Function(T) toJson;
  T Function(Map<String, dynamic>) fromJson;

  JsonConverter({required this.toJson, required this.fromJson});
}
