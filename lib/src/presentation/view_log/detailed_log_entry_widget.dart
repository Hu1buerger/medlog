import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:medlog/src/controller/administration_log/log_controller.dart';
import 'package:medlog/src/model/log_entry/log_entry.dart';

class DetailedLogEntryWidget extends StatelessWidget {
  static const String routeName = "/detailedLogEntry";
  static const String title = "Details";

  static final Logger _logger = Logger("DetailedLogEntryWidget");

  final LogEntry entry;
  final LogController logController;

  const DetailedLogEntryWidget({Key? key, required this.entry, required this.logController}) : super(key: key);

  Widget buildTitleValue(String title, String value) {
    return TextField(
      controller: TextEditingController(text: "  $value"),
      enabled: false,
      decoration: InputDecoration(prefix: Text(title)),
    );
  }

  void onDelete(BuildContext context){
    _logger.fine("onDelete for $entry");
    logController.delete(entry);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(title),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {},
            ),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildTitleValue("Tradename:", entry.displayName),
              buildTitleValue("Dosage:", entry.dosage),
              buildTitleValue("Active substance:", entry.activeSubstance),
              buildTitleValue("Date:", entry.adminDate.toString()),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: () => onDelete(context), child: const Text("delete me"))
            ],
          ),
        ));
  }
}
