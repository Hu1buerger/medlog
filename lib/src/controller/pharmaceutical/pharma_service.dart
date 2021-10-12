import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:medlog/src/model/pharmaceutical/pharmaceutical.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

import '../storage_service.dart';

class PharmaService extends StorageService<Pharmaceutical> {
  static String storageKey = "pharmaceuticals";
  static JsonConverter<Pharmaceutical> jsonConverter = JsonConverter(
      toJson: (t) => t.toJson(), fromJson: (json) => Pharmaceutical.fromJson(json));

  //static const String updateURL = "https://drive.google.com/uc?export=download&id=1ebw63LfYNd6RVPJUxtfyYSMx13fkIEsr";
  static const String updateURL = "https://gist.githubusercontent.com/Hu1buerger/3a92d33965db9e299f8077fe6feb5f97/raw/pharmaceuticals.json";

  late Timer onlineFetcher;

  PharmaService() : super(storageKey, jsonConverter, Logger("PharmaService"));

  startup(){
    loadFromDisk();
    _fetchRemote();
    onlineFetcher = Timer.periodic(const Duration(minutes: 15), (timer){
      logger.info("starting periodic fetch");
      _fetchRemote();
    });
  }

  Future<bool> storeToExternal(List<Pharmaceutical> list) async {
    var externDir = await path_provider.getExternalStorageDirectory();
    if(externDir == null || externDir.existsSync() == false) throw StateError("couldnt create outputdir");

    var dir = await Directory("${externDir.path}/medlog").create(recursive: true);
    var exportFile = File("${dir.path}/pharmaceuticals-export-${DateTime.now().toIso8601String()}.json");

    // encode data to the right format.
    var pharms = encodeToMaps(list).toList();
    var data = jsonEncode({
      storageKey: pharms
    });

    await exportFile.writeAsString(data);
    logger.info("written data to ${exportFile.path}");
    return true;
  }

  _fetchRemote() async {
    logger.fine("starting remote pharmaceutical load");
    var updateURI = Uri.parse(updateURL);
    http.get(updateURI).then((response) {
      if (response.statusCode != 200)
        return;
      var remoteUpdate = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      var pharmaceuticals = remoteUpdate[storageKey] as List;

      for (var pJson in pharmaceuticals) {
        var p = fromJson(pJson);
        assert(p.documentState != DocumentState.user_created);
        publish(p);
      }

      logger.fine("recieved ${pharmaceuticals.length} pharmaceuticals");
    });
  }
}