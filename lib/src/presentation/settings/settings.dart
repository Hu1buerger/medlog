import 'package:flutter/material.dart';
import 'package:medlog/src/controller/file_exporter.dart';
import 'package:medlog/src/controller/log/log_controller.dart';
import 'package:medlog/src/controller/log/log_provider.dart';
import 'package:medlog/src/controller/pharmaceutical/pharmaceutical_controller.dart';
import 'package:medlog/src/controller/stock/stock_controller.dart';
import 'package:medlog/src/model/log_entry/stock_event.dart';
import 'package:medlog/src/model/stock/stock_entry.dart';
import 'package:medlog/src/presentation/home_page/home_page.dart';
import 'package:package_info_plus/package_info_plus.dart';

class Settings extends StatefulWidget {
  static const String route_name = "/settings";

  final PharmaceuticalController pharmaceuticalController;
  final LogProvider logProvider;
  final LogController logController;
  final StockController stockController;

  const Settings(
      {Key? key, required this.pharmaceuticalController, required this.logProvider, required this.stockController, required this.logController})
      : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  static String title = "Settings";

  PharmaceuticalController get pharmController => widget.pharmaceuticalController;

  LogProvider get logProvider => widget.logProvider;

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

                  return Text("${packageInfo.version}+${packageInfo.buildNumber} \n ${packageInfo.buildSignature}");
                }),
            ElevatedButton(onPressed: (){
              var fx = FileExporter(widget.logController, pharmController, stockController);
              fx.write();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("backup finished")));
            }, child: Text("backup")),
            ElevatedButton(
              onPressed: () async {
                // quick fix for removing user defined pharmaceuticals
                pharmController.pharmaceuticals.clear();
                // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                pharmController.notifyListeners();
              },
              child: Text("cleanAll"),
            ),
            ElevatedButton(
                onPressed: () {
                  stockController.stock.clear();

                  for (var p in pharmController.pharmaceuticals) {
                    var stockItem = StockItem.create(p, 20, StockState.closed, DateTime.now().add(Duration(days: 187)));

                    stockController.addStockItem(stockItem);
                  }
                },
                child: Text("fill stock for all")),
          ],
        ));
  }
}
