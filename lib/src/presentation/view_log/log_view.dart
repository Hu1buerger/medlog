import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:medlog/src/controller/administration_log/log_controller.dart';
import 'package:medlog/src/model/log_entry/log_entry.dart';
import 'package:medlog/src/presentation/add_entrys/add_log_entry.dart';
import 'package:medlog/src/presentation/settings/settings.dart';
import 'package:medlog/src/presentation/view_log/log_entry_widget.dart';

class LogView extends StatelessWidget {
  static const String title = "Log";
  static const String routeName = "/logview";

  const LogView({Key? key, required this.logController}) : super(key: key);

  final LogController logController;

  List<LogEntry> get items => logController.log;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, Settings.route_name);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.create),
        backgroundColor: Colors.green,
        onPressed: () {
          Navigator.pushNamed(context, AddLogEntry.routeName);
        },
      ),
      body: AnimatedBuilder(
        animation: logController,
        builder: (BuildContext context, Widget? child) {
          //lazy build the list items
          return ListView.builder(
              restorationId: 'administrationLogListView',
              itemCount: items.length,
              itemBuilder: (BuildContext context, int index) {
                final item = items[index];
                return LogEntryWidget(item: item);
              });
        },
      ),
    );
  }
}
