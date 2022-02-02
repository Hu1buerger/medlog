import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:logging_to_logcat/logging_to_logcat.dart';
import 'package:medlog/src/api_provider.dart';
import 'package:medlog/src/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _initializeLogger();
  Logger.root.info("starting the app");

  final APIProvider provider = APIProvider();
  await provider.defaultInit();

  runApp(MedlogApp(provider: provider));
}

void _initializeLogger() {
  Logger.root.level = Level.ALL; // defaults to Level.INFO

  Logger.root.activateLogcat();
  Logger.root.info("""
  
  
  Starting medlog...
  """);
}
