import 'dart:convert';
import 'dart:core' as core show print;
import 'dart:core' hide print;
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:medlog/src/controller/log/log_controller.dart';
import 'package:medlog/src/controller/pharmaceutical/pharmaceutical_controller.dart';
import 'package:medlog/src/controller/stock/stock_controller.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class FileExporter {
  FileExporter(this.logController, this.pharmaceuticalController, this.stockController);

  static final Logger logger = Logger("FileExporter");

  final LogController logController;
  final PharmaceuticalController pharmaceuticalController;
  final StockController stockController;

  Future write() async {
    //TODO: replace against the JsonStore

    Map<String, dynamic> result = {};

    var logSon = logController.jsonKV();
    result.addEntries(logSon.entries);

    var pharmSon = pharmaceuticalController.jsonKV();
    result.addEntries(pharmSon.entries);

    //todo: add stock
    String jsonResult = jsonEncode(result);
    var file = await createFile();

    await file.writeAsString(jsonResult);
    logger.info("backing up to ${file.path} with ${file.lengthSync()} length");
  }

  Future<File> createFile() async {
    var externDir = await path_provider.getExternalStorageDirectory();
    if (externDir == null || externDir.existsSync() == false) throw StateError("couldnt create outputdir");

    var exportDir = await Directory("${externDir.path}/medlog").create(recursive: true);
    var exportFile = File("${exportDir.path}/medlog-export-${DateTime.now().toIso8601String()}.json");
    return exportFile;
  }
}
