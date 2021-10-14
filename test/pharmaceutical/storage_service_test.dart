import 'dart:async';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
import 'package:logging/src/logger.dart';
import 'package:medlog/src/controller/storage_service.dart';

var rng = Random();

void main() async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((event) {
    print(event.message);
  });

  late MockStorageService ps;

  //setup empty
  setUp(() {
    ps = MockStorageService([]);
  });

  group("Testing without backlog", () {
    test("getAll on empty load", () => testGetAllEmpty(ps));
    test("getAll on data", () => testGetAllOnData(ps));
    test("recieve updates and push", () => testReceiveEvents(ps));
  });

  group("Testing with backlog", () {
    test("getAll on empty load", () {
      ps.backLog = [];
      testGetAllEmpty(ps);
    });
    test("getAll on data", () {
      ps.backLog = [];
      testGetAllOnData(ps);
    });
  });

}

/// tests the getAll on an empty load
void testGetAllEmpty(MockStorageService ps) async {
  ps.loadFromDisk();
  ps.signalDone();
  var loaded = await ps.getAll();
  expect(loaded.isEmpty, isTrue);
}

void testGetAllOnData(MockStorageService ps) async {
  ps.data = List.generate(20, (index) => rng.nextInt(1 << 8).toString());
  ps.loadFromDisk();
  ps.signalDone();
  var result = await ps.getAll();
  expect(result, ps.data);
}

/// test that we can receive events and publish
void testReceiveEvents(MockStorageService ps) async{
  var completer = Completer();

  var result = [];
  ps.events.listen((event) {
    result.add(event);
  }, onDone: completer.complete);

  List<String> data = List.generate(250, (index) => rng.nextInt(1 << 16).toString());
  for (var e in data) {
    ps.publish(e);
  }

  ps.signalDone();
  await completer.future;

  expect(result, data);
}

class MockStorageService extends StorageService<String> {
  List<String> data = [];

  MockStorageService(this.data)
      : super(
      "mock", Logger("MockStorageService"), jsonConverter: JsonConverter(toJson: (s) => {s: s}, fromJson: (m) => m.keys.first));

  @override
  Future<List<String>> loadFromDisk() async {
    data.forEach(publish);
    return data;
  }

  @override
  Future<void> store(list) async {
    data = list;
    return;
  }
}
