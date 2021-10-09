import 'package:logging/logging.dart';
import 'package:medlog/src/controller/administration_log/log_service.dart';
import 'package:medlog/src/model/pharmaceutical/pharmaceutical.dart';

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
