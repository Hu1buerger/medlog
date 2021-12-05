import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:medlog/src/model/pharmaceutical/pharmaceutical.dart';
import 'package:medlog/src/model/stock/stock_entry.dart';
import 'package:medlog/src/repo/pharmaceutical/pharmaceutical_repo.dart';
import 'package:medlog/src/util/repo_adapter.dart';
import 'package:medlog/src/util/store.dart';
import 'package:uuid/uuid.dart';

//TODO: extend this mofo and override load and store => ExampleDataStockController
class StockRepo with ChangeNotifier {
  static const String key = "stock";

  Logger logger = Logger("StockRepo");

  PharmaceuticalRepo pharmaController;
  Uuid uuid = const Uuid();

  final RepoAdapter repoAdapter;
  List<StockItem> _stock = [];
  List<StockItem> get stock => _stock;

  StockRepo(this.repoAdapter, this.pharmaController);

  List<StockItem> stockItemByPharmaceutical(Pharmaceutical p) {
    return stock.where((element) => element.pharmaceutical == p).toList();
  }

  List<StockItem> expiredAfter(DateTime date) {
    return stock.where((element) => element.expiryDate.isAfter(date)).toList();
  }

  double remainingUnits(Pharmaceutical p) {
    var stockOfP = stockItemByPharmaceutical(p);

    return stockOfP.isEmpty ? 0 : stockOfP.map((e) => e.amount).reduce((value, element) => value += element);
  }

  void addStockItem(StockItem item) {
    assert(item.id == "");
    item.id = uuid.v4();

    insertStockItem(item);
  }

  @visibleForTesting
  void insertStockItem(StockItem item) {
    assert(item.id != "");

    if (stock.contains(item)) {
      logger.severe("item to add already in store");
      return;
    }

    if (stock.any((element) => element.id == item.id)) {
      //Handle later;
      logger.severe("id match unhandled");
      return;
    }

    stock.add(item);
    notifyListeners();
  }

  /// takes amount * units from the stockItem and returns how many couldn't be satisfied
  double takeFromStockItem(StockItem item, double amount) {
    assert(stock.contains(item));

    logger.finest(
        "taking $amount from ${item.id} ${item.pharmaceutical.displayName} which has ${item.amount} units remaining");

    double remainingAmount = 0;
    if (item.amount >= amount) {
      item.amount -= amount;
    } else {
      remainingAmount = amount - item.amount;
      item.amount = 0;
    }

    _updateItem(item);
    return remainingAmount;
  }

  void _updateItem(StockItem item) {
    assert(stock.contains(item));
    assert(item.amount >= 0);

    if (item.amount < 0) {
      logger.severe("items {${item.id} ${item.pharmaceutical.displayName}} amount is less than 0.", item.toJson());
    }

    if (item.amount == 0) {
      stock.remove(item);
    }

    notifyListeners();
  }

  Future load() async {
    var items = repoAdapter.loadListOrDefault<Json, StockItem>(key, (json) => StockItem.fromJson(json), []);

    for (var i in items) {
      var pharmaceutical = pharmaController.pharmaceuticalByID(i.pharmaceuticalID);
      if (pharmaceutical == null) logger.severe("cannot rehydrate for ${i.id}");
      i.pharmaceutical = pharmaceutical!;
    }

    _stock = items;
    notifyListeners();
  }

  store() {
    repoAdapter.storeList(key, stock, (StockItem s) => s.toJson());
  }

  void openItem(StockItem stockItem) {
    if (stockItem.state == StockState.closed) {
      stockItem.state = StockState.open;
      logger.fine("opening ${stockItem.id} ${stockItem.pharmaceutical.displayName}");
      notifyListeners();
    }
  }

  void updateStockState(StockItem stockItem, StockState state) {
    if (stockItem.state == state) return;

    logger.fine(
        "setting StockItem{id:${stockItem.id}} stockState from ${describeEnum(stockItem.state)} to ${describeEnum(state)}");
    stockItem.state = state;
    notifyListeners();
  }

  void delete(StockItem stockItem) {
    //TODO: handle linked StockEvents and remove them
    assert(stock.contains(stockItem));

    stock.remove(stockItem);
    notifyListeners();
  }
}
