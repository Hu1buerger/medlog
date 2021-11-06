import 'package:logging/src/logger.dart';
import 'package:medlog/src/controller/pharmaceutical/pharma_service.dart';
import 'package:medlog/src/controller/services/storage_service.dart';
import 'package:medlog/src/model/pharmaceutical/pharmaceutical.dart';

class MockPharmaService extends PharmaService {
  List<Pharmaceutical> data;

  MockPharmaService(this.data);

  @override
  Future<List<Pharmaceutical>> loadFromDisk() async {
    data.forEach(publish);
    signalDone();
    return data;
  }

  @override
  Future<void> store(List<Pharmaceutical> list) async {
    data = list;
    return;
  }
}

class MockStorageService<T> extends StorageService<T> {
  List<T> data;
  MockStorageService(String storageKey, this.data)
      : super(storageKey, logger: Logger("MockStorageService-$storageKey"));

  @override
  Future<List<T>> loadFromDisk() async {
    data.forEach(publish);
    return data;
  }

  @override
  Future<void> store(List<T> list) async {
    data = list;
  }
}
