import 'package:flutter/material.dart';
import 'package:medlog/src/model/log_entry/log_event.dart';
import 'package:medlog/src/model/log_entry/medication_intake_event.dart';
import 'package:medlog/src/model/log_entry/stock_event.dart';
import 'package:medlog/src/presentation/log/medication_intake_details.dart';
import 'package:medlog/src/presentation/widgets/date_time_widget.dart';
import 'package:medlog/src/util/date_time_extension.dart';

abstract class LogEventWidget<T extends LogEvent> extends StatelessWidget {
  final T logEvent;

  const LogEventWidget({Key? key, required this.logEvent}) : super(key: key);

  factory LogEventWidget.build({Key? key, required T item}) {
    if (item is MedicationIntakeEvent) {
      return MedicationLogWidget(
        key: key,
        item: item,
      ) as LogEventWidget<T>;
    }
    if (item is StockEvent) {
      return StockEventWidget(
        key: key,
        item: item,
      ) as LogEventWidget<T>;
    }

    throw ArgumentError.value(item.runtimeType);
  }

  void onTap(BuildContext context) {
    print("tapped on $this with $logEvent");
  }
}

/// see this for https://api.flutter.dev/flutter/material/ListTile-class.html#material.ListTile.5
class MedicationLogWidget extends LogEventWidget<MedicationIntakeEvent> {
  const MedicationLogWidget({Key? key, required MedicationIntakeEvent item}) : super(key: key, logEvent: item);

  void onTap(BuildContext context) {
    Navigator.pushNamed(context, MedicationIntakeDetails.routeName, arguments: logEvent);
  }

  @override
  Widget build(BuildContext context) {
    var logEntry = ListTile(
      title: Text(logEvent.displayName),
      subtitle: Text(logEvent.dosage.toString()),
      trailing: Text(logEvent.eventTime.toTimeOfDay().format(context)),
      onTap: () => onTap(context),
    );
    return logEntry;
  }
}

class StockEventWidget extends LogEventWidget<StockEvent> {
  const StockEventWidget({Key? key, required StockEvent item}) : super(key: key, logEvent: item);

  @override
  Widget build(BuildContext context) {
    var changeText = "${logEvent.amount.isNegative ? "-" : "+"} ${logEvent.amount.abs().toString()}";

    var logEntry = ListTile(
      title: Text(logEvent.pharmaceutical.displayName),
      subtitle: Text(changeText),
      trailing: Text(logEvent.eventTime.toTimeOfDay().format(context)),
      onTap: () => onTap(context),
    );

    return logEntry;
  }
}

class LogDayWidget extends StatelessWidget {
  LogDayWidget({Key? key, required this.logEvents})
      : assert(logEvents.isNotEmpty),
        assert(logEvents.every((element) => element.eventTime.isSameDay(logEvents[0].eventTime)) == true),
        super(key: key);

  /// the events to be displayed
  /// ensure that logEvents is sorted in the right way
  final List<LogEvent> logEvents;

  DateTime get day => logEvents.first.eventTime;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Chip(
          label: DateTimeWidget(dateTime: day, showDate: true, showTime: false),
        ),
        ...List.generate(logEvents.length, (index) => LogEventWidget.build(item: logEvents[index]))
      ],
    );
  }
}
