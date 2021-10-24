import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:medlog/src/model/log_entry/log_event.dart';
import 'package:medlog/src/model/log_entry/medication_intake_event.dart';
import 'package:medlog/src/model/log_entry/stock_event.dart';
import 'package:medlog/src/presentation/log/medication_intake_details.dart';
import 'package:medlog/src/presentation/widgets/date_time_widget.dart';
import 'package:medlog/src/util/date_time_extension.dart';

/// see this for https://api.flutter.dev/flutter/material/ListTile-class.html#material.ListTile.5
class MedicationLogWidget extends LogEventWidget<MedicationIntakeEvent> {
  const MedicationLogWidget({Key? key, required MedicationIntakeEvent item, bool showDateChip = true})
      : super(key: key, logEvent: item, showDate: showDateChip);

  void onTap(BuildContext context) {
    Navigator.pushNamed(context, MedicationIntakeDetails.routeName, arguments: logEvent);
  }

  @override
  Widget buildChild(BuildContext context) {
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
  const StockEventWidget({Key? key, required StockEvent item, bool showDate = true})
      : super(key: key, logEvent: item, showDate: showDate);

  @override
  Widget buildChild(BuildContext context) {
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

abstract class LogEventWidget<T extends LogEvent> extends StatelessWidget {
  final T logEvent;

  /// show the DateChip if the item is the first item in the current day.
  final bool showDate;

  const LogEventWidget({Key? key, required this.logEvent, this.showDate = true}) : super(key: key);

  factory LogEventWidget.build({Key? key, required T item, bool showDate = true}) {
    if (item is MedicationIntakeEvent) {
      return MedicationLogWidget(
        key: key,
        item: item,
        showDateChip: showDate,
      ) as LogEventWidget<T>;
    }
    if (item is StockEvent) {
      return StockEventWidget(
        key: key,
        item: item,
        showDate: showDate,
      ) as LogEventWidget<T>;
    }

    throw ArgumentError.value(item.runtimeType);
  }

  void onTap(BuildContext context) {
    print("tapped on $this with $logEvent");
  }

  Widget buildChild(BuildContext context);

  @override
  Widget build(BuildContext context) {
    Widget child = buildChild(context);

    if (showDate) {
      return DateChipSmusher(dateTime: logEvent.eventTime, child: child);
    }

    return child;
  }
}

class DateChipSmusher extends StatelessWidget {
  final DateTime? dateTime;
  final Widget child;

  const DateChipSmusher({Key? key, required this.child, this.dateTime}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (dateTime != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Chip(label: DateTimeWidget(dateTime: dateTime!, showDate: true, showTime: false)),
          child,
        ],
      );
    }

    return child;
  }
}
