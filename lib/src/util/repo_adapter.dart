import 'package:medlog/src/util/store.dart';

/*
 * TODO: The encodingAdapters are typeunsafe
 *  THis is a result of json.Encode not using a type reifying
 *
 */
class RepoAdapter {
  RepoAdapter(this.kvstore);

  Store kvstore;

  List<Function(RepoAdapter)> shutdownHook = [];

  O load<I, O>(String key, O Function(I json) adapter) {
    if (kvstore.containsKey(key) == false) {
      throw ArgumentError.value(key, "", "not stored in kv-store");
    }

    return adapter(kvstore.get(key));
  }

  O loadOrDefault<I, O>(String key, O Function(I) adapter, O defaultVal) {
    try {
      return load(key, adapter);
    } on ArgumentError catch (e) {
      return defaultVal;
    }
  }

  void store<T>(String key, T val, Object Function(T) adapter) {
    kvstore.update(key, adapter(val));
  }

  List<O> loadList<I, O>(String key, O Function(I) adapter) {
    if (kvstore.containsKey(key) == false) {
      throw ArgumentError.value(key, "", "not stored in kv-store");
    }

    final storedValue = kvstore.get(key);
    final list = (storedValue as List).cast<I>();
    return list.map(adapter).toList();
  }

  List<O> loadListOrDefault<I, O>(String key, O Function(I) adapter, List<O> orDefault) {
    try {
      return loadList(key, adapter);
    } on ArgumentError catch (e) {
      return orDefault;
    }
  }

  /// store a list of
  storeList<T>(String key, List<T> list, Object Function(T) adapter) {
    var jsonList = list.map(adapter).toList();
    kvstore.update(key, jsonList);
  }
}
