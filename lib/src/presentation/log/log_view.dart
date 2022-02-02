import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:medlog/src/api_provider.dart';
import 'package:medlog/src/model/log_entry/log_event.dart';
import 'package:medlog/src/presentation/add_entrys/add_log_entry.dart';
import 'package:medlog/src/presentation/home_page.dart';
import 'package:medlog/src/presentation/log/log_entry_widgets.dart';
import 'package:medlog/src/presentation/settings.dart';
import 'package:medlog/src/repo/log/log_provider.dart';

class LogView extends StatelessWidget with HomePagePage {
  static const String title = "Log";
  static const String routeName = "/logview";

  static final Logger logger = Logger("LogView");
  final APIProvider provider;

  LogProvider get logProvider => provider.logProvider;

  List<LogEvent> get items => logProvider.getLog();

  const LogView({Key? key, required this.provider}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: logProvider,
      builder: (BuildContext context, Widget? child) {
        logger.fine("rebuilding due to change");

        //lazy build the list items
        return ListView.builder(
            restorationId: 'administrationLogListView',
            reverse: false, //For reversing we need to change the smushing behaviour
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

              return LogEventWidget.build(
                key: ObjectKey(item),
                item: item,
                showDate: showDateChip,
              );
            });
      },
    );
  }
}
