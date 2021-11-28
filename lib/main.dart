import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:logging_to_logcat/logging_to_logcat.dart';
import 'package:medlog/src/app.dart';
import 'package:medlog/src/repo/log/log_repo.dart';
import 'package:medlog/src/repo/log/log_service.dart';
import 'package:medlog/src/repo/pharmaceutical/pharma_service.dart';
import 'package:medlog/src/repo/pharmaceutical/pharmaceutical_repo.dart';
import 'package:medlog/src/repo/stock/stock_controller.dart';
import 'package:medlog/src/repo/stock/stock_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _initializeLogger();
  Logger.root.info("starting the app");

  final pharmController = PharmaceuticalRepo(PharmaService());
  final logController = LogRepo(pharmController, LogService());
  final stockC = StockRepo(StockService(), pharmController);

  await pharmController.load();
  await logController.loadLog();
  await stockC.load();
  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
  runApp(MedlogApp(
    logController: logController,
    pharmaController: pharmController,
    stockController: stockC,
  ));
}

void _initializeLogger() {
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  /*Logger.root.onRecord.listen((record) {
    /*log(record.message,
        time: record.time,
        sequenceNumber: record.sequenceNumber,
        level: record.level.value,
        name: record.loggerName,
        zone: record.zone,
        error: record.error,
        stackTrace: record.stackTrace);*/

    // ignore: avoid_print
    //print('${record.level.name.characters.first}/${record.loggerName}: ${record.message}');
  });*/

  Logger.root.activateLogcat();
  Logger.root.info("""
  
  
  Starting medlog...
  """);
}
