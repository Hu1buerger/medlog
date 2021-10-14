import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:medlog/src/model/log_entry/medication_intake_event.dart';
import 'package:medlog/src/model/log_entry/stock_event.dart';
import 'package:medlog/src/presentation/view_log/medication_intake_details.dart';
import 'package:medlog/src/util/date_time_extension.dart';

/// see this for https://api.flutter.dev/flutter/material/ListTile-class.html#material.ListTile.5
class MedicationLogWidget extends StatelessWidget {
  final MedicationIntakeEvent item;

  /// show the DateChip if the item is the first item in the current day.
  final bool showDateChip;

  const MedicationLogWidget({Key? key, required this.item, required this.showDateChip}) : super(key: key);

  void onTap(BuildContext context) {
    Navigator.pushNamed(context, MedicationIntakeDetails.routeName, arguments: item);
  }

  @override
  Widget build(BuildContext context) {
    var logEntry = ListTile(
      title: Text(item.displayName),
      subtitle: Text(item.dosage),
      trailing: Text(item.eventTime.toTimeOfDay().format(context)),
      onTap: () => onTap(context),
    );

    if (showDateChip) {
      return DateChipSmusher(dateTime: item.eventTime, child: logEntry);
    }

    return logEntry;
  }
}

class StockEventWidget extends StatelessWidget{

  final bool showDate;
  final StockEvent item;

  const StockEventWidget({Key? key, required this.item, this.showDate = true}) : super(key: key);

  void onTap(BuildContext context) {
    print("taped on stockEvent");
  }

  @override
  Widget build(BuildContext context) {
    var changeText = "${item.amount.isNegative ? "-" : "+"} ${item.amount.abs().toString()}";

    var logEntry = ListTile(
      title: Text(item.pharmaceutical.displayName),
      subtitle: Text(changeText),
      trailing: Text(item.eventTime.toTimeOfDay().format(context)),
      onTap: () => onTap(context),
    );

    if (showDate) {
      return DateChipSmusher(dateTime: item.eventTime, child: logEntry);
    }

    return logEntry;
  }
}

class DateChipSmusher extends StatelessWidget{

  final DateTime? dateTime;
  final Widget child;

  DateChipSmusher({Key? key, required this.child, this.dateTime});

  @override
  Widget build(BuildContext context){
    if(dateTime != null){
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Chip(label: Text(dateTime!.toHumanString())),
          child,
        ],
      );
    }

    return child;
  }
}