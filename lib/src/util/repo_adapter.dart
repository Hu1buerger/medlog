import 'package:medlog/src/util/store.dart';

class RepoAdapter {
  late Store fileKVStore;
  List<Function(RepoAdapter)> shutdownHook = [];

  T load<T>(String key, T Function(Json json) adapter) {
    if (fileKVStore.containsKey(key) == false) throw ArgumentError.value(key);

    Json val = fileKVStore.getJson(key);
    return adapter(val);
  }

  void store<T>(String key, T val, Json Function(T) adapter) {
    Json json = adapter(val);

    fileKVStore.updateJson(key, json);
  }

  List<T> loadList<T>(String key, T Function(Json) adapter) {
    if (fileKVStore.containsKey(key) == false) throw ArgumentError.value(key);

    final list = fileKVStore.getJson(key) as List<Json>;
    return list.map(adapter).toList();
  }

  storeList<T>(String key, List<T> list, Json Function(T) adapter) {
    var jsonList = list.map(adapter).toList();
    //TODO: handle see store.dart
  }
}
