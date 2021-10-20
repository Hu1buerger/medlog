import 'package:flutter/material.dart';
import 'package:medlog/src/controller/log/log_controller.dart';
import 'package:medlog/src/controller/pharmaceutical/pharmaceutical_controller.dart';
import 'package:medlog/src/controller/stock/stock_controller.dart';
import 'package:medlog/src/model/log_entry/stock_event.dart';
import 'package:medlog/src/model/stock/stock_entry.dart';
import 'package:medlog/src/presentation/home_page/home_page.dart';
import 'package:package_info_plus/package_info_plus.dart';

class Settings extends StatefulWidget {
  static const String route_name = "/settings";

  final PharmaceuticalController pharmaceuticalController;
  final LogController logController;
  final StockController stockController;

  const Settings(
      {Key? key, required this.pharmaceuticalController, required this.logController, required this.stockController})
      : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  static String title = "Settings";

  PharmaceuticalController get pharmController => widget.pharmaceuticalController;

  LogController get logController => widget.logController;

  StockController get stockController => widget.stockController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
          actions: [],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (bc, asyncSnapshot) {
                if (asyncSnapshot.hasData == false) return const Text("versionNumber");
                var packageInfo = asyncSnapshot.data!;

                return Text("${packageInfo.version}+${packageInfo.buildNumber}");
              }),
            ElevatedButton(
              onPressed: () async {
                try {
                  var result = await pharmController.pharmaservice.storeToExternal(pharmController.pharmaceuticals);
                  if (result) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("data written")));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("failed to write text ${e}")));
                }
              },
              child: Text("writeToDisk"),
            ),
            ElevatedButton(
              onPressed: () async {
                // quick fix for removing user defined pharmaceuticals
                pharmController.pharmaceuticals.clear();
                pharmController.notifyListeners();
              },
              child: Text("cleanAll"),
            ),
            ElevatedButton(
                onPressed: () async {
                  var stockItem = StockItem.create(pharmController.pharmaceuticals.first, 10, StockState.open,
                      DateTime.now().add(Duration(days: 187)));

                  // maybe the stockController should add the logEntry
                  stockController.createStockItem(stockItem);

                  var stockItem2 = StockItem.create(pharmController.pharmaceuticals.last, 7, StockState.closed,
                      DateTime.now().add(Duration(days: 187)));
                  stockController.createStockItem(stockItem2);

                  var stockEvent = StockEvent.create(DateTime.now(), stockItem.pharmaceutical, stockItem.amount);
                  logController.addStockEvent(stockEvent);
                },
                child: Text("add mocked stock")),
            ElevatedButton(
                onPressed: () {
                  stockController.stock.clear();

                  for (var p in pharmController.pharmaceuticals) {
                    var stockItem = StockItem.create(p, 20, StockState.closed, DateTime.now().add(Duration(days: 187)));

                    stockController.createStockItem(stockItem);
                  }
                },
                child: Text("fill stock for all")),
            ElevatedButton(
                onPressed: () {
                  Navigator.popAndPushNamed(context, HomePage.route);
                },
                child: Text("goto homepage"))
          ],
        ));
  }
}
