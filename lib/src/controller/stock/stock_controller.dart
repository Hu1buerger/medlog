import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:medlog/src/controller/pharmaceutical/pharmaceutical_controller.dart';
import 'package:medlog/src/controller/stock/stock_service.dart';
import 'package:medlog/src/model/pharmaceutical/pharmaceutical.dart';
import 'package:medlog/src/model/stock/stock_entry.dart';
import 'package:uuid/uuid.dart';

//TODO: extend this mofo and override load and store => ExampleDataStockController
class StockController with ChangeNotifier {
  Logger logger = Logger("StockController");

  PharmaceuticalController pharmaController;
  Uuid uuid = const Uuid();

  StockService service;
  List<StockItem> stock = [];

  StockController(this.service, this.pharmaController);

  List<StockItem> stockItemByPharmaceutical(Pharmaceutical p) {
    return stock.where((element) => element.pharmaceutical == p).toList();
  }

  List<StockItem> expiredAfter(DateTime date) {
    return stock.where((element) => element.expiryDate.isAfter(date)).toList();
  }

  double remainingUnits(Pharmaceutical p){
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
  double takeFromStockItem(StockItem item, double amount){
    assert(stock.contains(item));

    logger.finest("taking $amount from ${item.id} ${item.pharmaceutical.displayName} which has ${item.amount} units remaining");

    double remainingAmount = 0;
    if(item.amount >= amount){
      item.amount -= amount;
    }else{
      remainingAmount = amount - item.amount;
      item.amount = 0;
    }

    _updateItem(item);
    return remainingAmount;
  }

  void _updateItem(StockItem item){
    assert(stock.contains(item));
    assert(item.amount >= 0);

    if(item.amount < 0){
      logger.severe("items {${item.id} ${item.pharmaceutical.displayName}} amount is less than 0.", item.toJson());
    }

    if(item.amount == 0){
      stock.remove(item);
    }

    notifyListeners();
  }

  Future load() async {
    var items = await service.loadFromDisk();

    for (var i in items) {
      var pharmaceutical =
          pharmaController.pharmaceuticalByID(i.pharmaceuticalID);
      if (pharmaceutical == null) logger.severe("cannot rehydrate for ${i.id}");
      i.pharmaceutical = pharmaceutical!;
    }

    stock = items;
  }

  Future store() {
    return service.store(stock);
  }

  void openItem(StockItem stockItem) {
    if(stockItem.state == StockState.closed){
      stockItem.state = StockState.open;
      logger.fine("opening ${stockItem.id} ${stockItem.pharmaceutical.displayName}");
      notifyListeners();
    }
  }
}
