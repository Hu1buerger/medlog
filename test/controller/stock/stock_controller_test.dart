import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
import 'package:medlog/src/controller/pharmaceutical/pharma_service.dart';
import 'package:medlog/src/controller/pharmaceutical/pharmaceutical_controller.dart';
import 'package:medlog/src/controller/stock/stock_controller.dart';
import 'package:medlog/src/controller/stock/stock_service.dart';
import 'package:medlog/src/model/stock/stock_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';

import '../pharmaceutical/pharmaceutical_controller_test.dart';

main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record){
    print("${record.level}/${record.message}");
  });

  test("mocking prevents writing to disk", () async {
    String testKey = "testKey";
    SharedPreferences.setMockInitialValues(
      {testKey:[]}
    );

    var otherInstance = await SharedPreferences.getInstance();
    expect(otherInstance.containsKey(testKey), isTrue);
    expect(otherInstance.getKeys().length, 1);

    var data = "TESTSTRING";
    await otherInstance.setString(testKey, data);
    expect(otherInstance.getString(testKey), equals(data));
  });

  test("createItems", () async {
    SharedPreferences.setMockInitialValues({
      StockService.key: []
    });

    var tuple = await setupStockController();
    var testStock = tuple.item2;
    var stockController = tuple.item3;

    expect(stockController.stock, testStock);
    expect(stockController.stock.any((element) => element.id == ""), isFalse);
    expect(stockController.stock.any((element) => element.pharmaceutical != null), isNot(throwsA(anything)));
  });

  test("store items", () async{
    SharedPreferences.setMockInitialValues({});

    var tuple = await setupStockController();
    var testStock = tuple.item2;
    var stockController = tuple.item3;

    assert(listEquals(stockController.stock, testStock));

    var sp = await SharedPreferences.getInstance();
    await stockController.store();

    await sp.reload();
    expect(sp.getKeys().length, 1);
    var strings = sp.getStringList(StockService.key);
    expect(strings?.length ?? 0, testStock.length);
  });

  test("controller dosnt write empty items", (){
    //maybe the controller should write empty items too?
  });

  test("loading from store", () async {
    SharedPreferences.setMockInitialValues({});

    var tuple = await setupStockController();
    var pharmaController = tuple.item1;
    var stockController = tuple.item3;

    // generate the data;
    await stockController.store();
    await pharmaController.store();

    var sp = await SharedPreferences.getInstance();
    expect(sp.getKeys().length >= 2, isTrue);

    var pharmac = PharmaceuticalController(PharmaService(), fetchEnabled: false);
    await pharmac.load();
    var stockc = StockController(StockService(), pharmac);
    await stockc.load();

    //expect that all items are rehydrated
    expect(stockc.stock.any((element) => element.pharmaceutical != null), isNot(throwsA(anything)));
    expect(stockc.stock.map((e) => e.id), stockController.stock.map((e) => e.id));
  });
}

DateTime futureTime() {
  return DateTime.now().add(const Duration(days: 3, hours: 1, minutes: 8, seconds: 7));
}

Future<Tuple3<PharmaceuticalController, List<StockItem>, StockController>> setupStockController() async {
  var pharmaController = await createPharmaController(items: 3);
  var pharmaceuticals = pharmaController.pharmaceuticals;

  var testStock = List.generate(10, (index) =>
      StockItem.create(pharmaceuticals[index % pharmaceuticals.length], index + 1, StockState.closed, futureTime()));

  var stockService = StockService();
  var stockController = StockController(stockService, pharmaController);
  testStock.forEach(stockController.addStockItem);

  return Tuple3<PharmaceuticalController, List<StockItem>, StockController>(pharmaController, testStock, stockController);
}
