import 'package:flutter/material.dart';
import 'package:medlog/src/controller/log/log_controller.dart';
import 'package:medlog/src/controller/pharmaceutical/pharmaceutical_controller.dart';
import 'package:medlog/src/controller/stock/stock_controller.dart';
import 'package:medlog/src/model/stock/stock_entry.dart';
import 'package:medlog/src/presentation/stock/view_stock.dart';

class Settings extends StatefulWidget {
  static const String route_name = "/settings";

  final PharmaceuticalController pharmaceuticalController;
  final LogController logController;
  final StockController stockController;

  const Settings(
      {Key? key,
      required this.pharmaceuticalController,
      required this.logController,
      required this.stockController})
      : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  static String title = "Settings";

  PharmaceuticalController get pharmController =>
      widget.pharmaceuticalController;
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
          children: [
            const Text("v1.0.1"),
            ElevatedButton(
              onPressed: () async {
                try {
                  var result = await pharmController.pharmaservice
                      .storeToExternal(pharmController.pharmaceuticals);
                  if (result)
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("data written")));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("failed to write text ${e}")));
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
                  stockController.createStockItem(StockItem.create(
                      pharmController.pharmaceuticals.first,
                      10,
                      StockState.open,
                      DateTime.now().add(Duration(days: 187))));
                  logController.addStockEvent(
                      pharmController.pharmaceuticals.first,
                      10,
                      DateTime.now());
                },
                child: Text("add mocked StockEvent")),
            ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, ViewStock.routeName);
                },
                child: Text("goto stockview"))
          ],
        ));
  }
}
