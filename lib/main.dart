import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:medlog/src/app.dart';
import 'package:medlog/src/controller/administration_log/log_controller.dart';
import 'package:medlog/src/controller/administration_log/log_service.dart';
import 'package:medlog/src/controller/pharmaceutical/pharma_service.dart';
import 'package:medlog/src/controller/pharmaceutical/pharmaceutical_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _initializeLogger();

  final pharmController = PharmaceuticalController(PharmaService());
  await pharmController.load();
  final logController = LogController(pharmController, LogService());
  await logController.loadLog();

  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
  runApp(MyApp(
    logController: logController,
    pharmaController: pharmController,
  ));
}

void _initializeLogger() {
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    /*log(record.message,
        time: record.time,
        sequenceNumber: record.sequenceNumber,
        level: record.level.value,
        name: record.loggerName,
        zone: record.zone,
        error: record.error,
        stackTrace: record.stackTrace);*/

    // ignore: avoid_print
    print('${record.level.name.characters.first}/${record.loggerName}: ${record.message}');
  });

  Logger.root.severe("starting to log");
}
