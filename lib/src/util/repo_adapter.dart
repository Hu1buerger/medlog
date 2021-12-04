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

  T load<T>(String key, T Function(Object json) adapter) {
    if (kvstore.containsKey(key) == false) throw ArgumentError.value(key, "", "not stored in kv-store");

    return adapter(kvstore.get(key));
  }

  void store<T>(String key, T val, Object Function(T) adapter) {
    kvstore.update(key, adapter(val));
  }

  List<T> loadList<T>(String key, T Function(Object) adapter) {
    if (kvstore.containsKey(key) == false) throw ArgumentError.value(key, "", "not stored in kv-store");

    final storedValue = kvstore.get(key);
    final list = storedValue as List<Object>;
    return list.map(adapter).toList();
  }

  /// store a list of
  storeList<T>(String key, List<T> list, Object Function(T) adapter) {
    var jsonList = list.map(adapter).toList();
    kvstore.update(key, jsonList);
  }
}
