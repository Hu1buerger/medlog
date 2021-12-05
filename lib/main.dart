import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:logging_to_logcat/logging_to_logcat.dart';
import 'package:medlog/src/app.dart';
import 'package:medlog/src/repo/log/log_repo.dart';
import 'package:medlog/src/repo/pharmaceutical/pharmaceutical_repo.dart';
import 'package:medlog/src/repo/stock/stock_controller.dart';
import 'package:medlog/src/util/backupmanager.dart';
import 'package:medlog/src/util/repo_adapter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _initializeLogger();
  Logger.root.info("starting the app");

  final store = (await backupmanager()).createStore();
  final repoAdapter = RepoAdapter(store);
  final pharmController = PharmaceuticalRepo(repoAdapter);
  final logController = LogRepo(repoAdapter, pharmController);
  final stockC = StockRepo(repoAdapter, pharmController);

  await store.load();
  await pharmController.load();
  await logController.load();
  await stockC.load();

  runApp(MedlogApp(
    logRepo: logController,
    pharmaRepo: pharmController,
    stockRepo: stockC,
    store: store,
  ));
}

void _initializeLogger() {
  Logger.root.level = Level.ALL; // defaults to Level.INFO

  Logger.root.activateLogcat();
  Logger.root.info("""
  
  
  Starting medlog...
  """);
}
