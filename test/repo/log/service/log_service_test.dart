import 'dart:developer';

import 'package:flutter_test/flutter_test.dart';
import 'package:medlog/src/model/log_entry/medication_intake_event.dart';
import 'package:medlog/src/model/log_entry/stock_event.dart';
import 'package:medlog/src/repo/log/log_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../test_tools/matcher/log_event_matcher.dart';

main() {
  test("store and retrieve", () async {
    var dt1 = DateTime(2020, 10, 10, 18, 7, 20);
    var le = StockEvent(1, dt1, "pharmaID1", 20);
    var miE =
        MedicationIntakeEvent(2, dt1.add(Duration(minutes: 1)), "pharmaID1", 1);

    var list = [le, miE];

    SharedPreferences.setMockInitialValues({});

    var logService = LogService();
    await logService.store(list);
    var result = await logService.loadFromDisk();

    var matcher = unorderedMatches(list.map((e) => LogEventMatcher(e)));
    expect(result, matcher);
    log("stored ${result.length} items");
  });
}
