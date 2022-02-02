import 'package:medlog/src/util/store.dart';

/*
 * TODO: The encodingAdapters are typeunsafe
 *  THis is a result of json.Encode not using a type reifying
 *
 */
class RepoAdapter {
  RepoAdapter(this._kvstore);

  final Store _kvstore;

  //THOUGHT: maybe we should register the owner of the hook to check for duplicates
  final List<Function(RepoAdapter)> shutdownHook = [];

  O load<I, O>(String key, O Function(I json) adapter) {
    if (_kvstore.containsKey(key) == false) {
      throw ArgumentError.value(key, "", "not stored in kv-store");
    }

    return adapter(_kvstore.get(key));
  }

  O loadOrDefault<I, O>(String key, O Function(I) adapter, O defaultVal) {
    try {
      return load(key, adapter);
    } on ArgumentError catch (e) {
      return defaultVal;
    }
  }

  void store<T>(String key, T val, Object Function(T) adapter) {
    _kvstore.update(key, adapter(val));
  }

  List<O> loadList<I, O>(String key, O Function(I) adapter) {
    if (_kvstore.containsKey(key) == false) {
      throw ArgumentError.value(key, "", "not stored in kv-store");
    }

    final storedValue = _kvstore.get(key);
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
    _kvstore.update(key, jsonList);
  }

  registerShutdownHook(Function(RepoAdapter) hook) {
    if (shutdownHook.contains(hook)) return;
    shutdownHook.add(hook);
  }

  void execShutdownHooks() {
    for (var hook in shutdownHook) {
      hook(this);
    }
  }
}
