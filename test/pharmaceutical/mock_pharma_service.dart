import 'package:medlog/src/controller/pharmaceutical/pharma_service.dart';
import 'package:medlog/src/model/pharmaceutical/pharmaceutical.dart';

class MockPharmaService extends PharmaService{

  List<Pharmaceutical> data;

  MockPharmaService(this.data);

  @override
  Future<List<Pharmaceutical>> loadFromDisk() async{
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