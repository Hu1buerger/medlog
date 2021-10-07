import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:medlog/src/add_entrys/add_log_entry.dart';
import 'package:medlog/src/administration_log/administration_log_controller.dart';
import 'package:medlog/src/administration_log/administration_log_entry.dart';
import 'package:medlog/src/view_administration/log_entry_view.dart';

class LogView extends StatelessWidget {
  static const String title = "Log";
  static const String routeName = "/logview";

  const LogView({Key? key, required this.logController}) : super(key: key);

  final AdministrationLogController logController;

  List<AdministrationLogEntry> get items => logController.log;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to the settings page. If the user leaves and returns
              // to the app after it has been killed while running in the
              // background, the navigation stack is restored.
              Navigator.restorablePushNamed(context, AddLogEntry.routeName);
            },
          ),
        ],
      ),

      body: AnimatedBuilder(
        animation: logController,
        builder: (BuildContext context, Widget? child) {
          //lazy build the list items
          return ListView.builder(
            // Providing a restorationId allows the ListView to restore the
            // scroll position when a user leaves and returns to the app after it
            // has been killed while running in the background.
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
