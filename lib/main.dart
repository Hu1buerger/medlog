import 'package:flutter/material.dart';
import 'package:medlog/src/administration_log/administration_log_controller.dart';
import 'package:medlog/src/pharmaceutical/pharma_service.dart';
import 'package:medlog/src/pharmaceutical/pharmaceutical_controller.dart';

import 'src/app.dart';

void main() async {
  final pharmController = PharmaceuticalController(PharmaService());
  await pharmController.load();
  final logController = AdministrationLogController(pharmController);
  await logController.loadLog();

  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
  runApp(MyApp(logController: logController, pharmaController: pharmController,));
}
