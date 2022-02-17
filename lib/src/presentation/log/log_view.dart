import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:medlog/src/api_provider.dart';
import 'package:medlog/src/model/log_entry/log_event.dart';
import 'package:medlog/src/presentation/add_entrys/add_log_entry.dart';
import 'package:medlog/src/presentation/home_page.dart';
import 'package:medlog/src/presentation/log/log_entry_widgets.dart';
import 'package:medlog/src/presentation/settings.dart';
import 'package:medlog/src/repo/log/log_provider.dart';
import 'package:medlog/src/util/date_time_extension.dart';

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

          var events = List<LogEvent>.of(items, growable: false);
          events.sort((a, b) => a.eventTime.compareTo(b.eventTime));
          assert(events.first.eventTime.isBefore(events.last.eventTime));

          events = events.reversed.toList();

          // clustering the logEvents by day
          List<List<LogEvent>> loggedDays = [];
          List<LogEvent> day = [];
          for (int i = 0; i < events.length; i++) {
            final currentEvent = events[i];

            if (day.isEmpty) {
              day.add(currentEvent);
              continue;
            }

            final lastEvent = day.last;
            if (lastEvent.eventTime.isSameDay(currentEvent.eventTime)) {
              day.add(currentEvent);
              continue;
            }

            assert(day.isNotEmpty);
            loggedDays.add(day);
            day = [];
          }

          return ListView.builder(
            restorationId: 'administrationLogListView',
            reverse: false,
            itemCount: loggedDays.length,
            itemBuilder: (BuildContext context, int index) => LogDayWidget(logEvents: loggedDays[index]),
          );
        });
  }
}
