import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:medlog/src/api_provider.dart';
import 'package:medlog/src/model/log_entry/medication_intake_event.dart';
import 'package:medlog/src/repo/log/log_provider.dart';

class MedicationIntakeDetails extends StatelessWidget {
  static const String routeName = "/detailedLogEntry";
  static const String title = "Details";

  static final Logger _logger = Logger("DetailedLogEntryWidget");

  final APIProvider provider;

  final MedicationIntakeEvent entry;

  LogProvider get logProvider => provider.logProvider;

  const MedicationIntakeDetails({Key? key, required this.entry, required this.provider}) : super(key: key);

  /// builds a widget with title and value
  ///
  /// displays title and value as a pair
  Widget buildTitleValue(String title, String value) {
    return TextField(
      controller: TextEditingController(text: "  $value"),
      enabled: false,
      decoration: InputDecoration(prefix: Text(title)),
    );
  }

  void onDelete(BuildContext context) {
    _logger.fine("onDelete for $entry");
    logProvider.delete(entry);
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
              buildTitleValue("Dosage:", entry.dosage.toString()),
              buildTitleValue("Active substance:", entry.activeSubstance),
              buildTitleValue("Date:", entry.eventTime.toString()),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: () => onDelete(context),
                  child: const Text("delete me"))
            ],
          ),
        ));
  }
}
