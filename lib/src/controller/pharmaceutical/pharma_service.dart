import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:medlog/src/model/pharmaceutical/pharmaceutical.dart';

import '../storage_service.dart';

class PharmaService extends StorageService<Pharmaceutical> {
  static String storageKey = "pharmaceuticals";
  static JsonConverter<Pharmaceutical> jsonConverter =
      JsonConverter(toJson: (t) => t.toJson(), fromJson: (json) => Pharmaceutical.fromJson(json));

  PharmaService() : super(storageKey, jsonConverter, Logger("PharmaService"));


  @override
  Future<List<Pharmaceutical>> load() async {
    var pharmaceuticals = await super.load();
    //maybe this should be logged?
    return pharmaceuticals;
  }
}
