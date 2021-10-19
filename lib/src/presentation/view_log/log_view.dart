import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:medlog/src/controller/log/log_controller.dart';
import 'package:medlog/src/model/log_entry/log_event.dart';
import 'package:medlog/src/model/log_entry/medication_intake_event.dart';
import 'package:medlog/src/model/log_entry/stock_event.dart';
import 'package:medlog/src/presentation/add_entrys/add_log_entry.dart';
import 'package:medlog/src/presentation/home_page/home_page.dart';
import 'package:medlog/src/presentation/settings/settings.dart';
import 'package:medlog/src/presentation/view_log/log_entry_widgets.dart';

class LogView extends StatelessWidget with HomePagePage{
  static const String title = "Log";
  static const String routeName = "/logview";

  final LogController logController;

  List<LogEvent> get items => logController.log;

  const LogView({Key? key, required this.logController}) : super(key: key);

  @override
  String? tabtitle() {
    return title;
  }

  @override
  appBar(BuildContext context) {
    return AppBar(
      title: const Text(title),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.pushNamed(context, Settings.route_name);
          },
        ),
      ],
    );
  }

  @override
  Widget floatingActionButton(BuildContext context) {
    return FloatingActionButton(
      child: const Icon(Icons.create),
      backgroundColor: Colors.green,
      onPressed: () {
        Navigator.pushNamed(context, AddLogEntry.routeName);
      },
    );
  }

  Widget buildListItem(LogEvent e, bool showDateChip) {
    if (e is MedicationIntakeEvent) return MedicationLogWidget(item: e, showDateChip: showDateChip);
    if (e is StockEvent) return StockEventWidget(item: e, showDate: showDateChip,);
    throw Error();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: logController,
      builder: (BuildContext context, Widget? child) {
        //lazy build the list items
        return ListView.builder(
            restorationId: 'administrationLogListView',
            itemCount: items.length,
            itemBuilder: (BuildContext context, int index) {
              final item = items[index];

              bool showDateChip = false;
              if (index == 0) {
                showDateChip = true;
              } else {
                var previous = items[index - 1];

                showDateChip = previous.eventTime.day != item.eventTime.day ||
                    previous.eventTime.difference(item.eventTime).inDays > 0;
              }

              return buildListItem(item, showDateChip);
            });
      },
    );
  }
}
