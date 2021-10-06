import 'package:medlog/src/administration_log/administration_log_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LogService{
  late final SharedPreferences prefs;

  loadLog() async{
      prefs = await SharedPreferences.getInstance();
      var jsonLogEntrys = prefs.getStringList("log");
      if(jsonLogEntrys == null) return <AdministrationLogEntry>[];

      var lEs = jsonLogEntrys.map((e) => AdministrationLogEntry.fromJson(json.decode(e)))
          .toList()
          .sort((a,b) => a.id.compareTo(b.id));
      return lEs;
  }

  storeLog(){

  }
}