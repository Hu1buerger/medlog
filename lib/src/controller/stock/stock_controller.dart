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

  void createStockItem(StockItem item) {
    assert(item.id == "");
    item.id = uuid.v4();

    addStockItem(item);
  }

  void addStockItem(StockItem item) {
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

  List<StockItem> expiredAfter(DateTime date) {
    return stock.where((element) => element.expiryDate.isAfter(date)).toList();
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
}
