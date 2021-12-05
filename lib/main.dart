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

  runApp(MedlogApp(
    logController: logController,
    pharmaController: pharmController,
    stockController: stockC,
  ));
}

void _initializeLogger() {
  Logger.root.level = Level.ALL; // defaults to Level.INFO

  Logger.root.activateLogcat();
  Logger.root.info("""
  
  
  Starting medlog...
  """);
}
