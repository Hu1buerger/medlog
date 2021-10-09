import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:medlog/src/model/log_entry/log_entry.dart';
import 'package:medlog/src/presentation/view_log/detailed_log_entry_widget.dart';

class LogEntryWidget extends StatelessWidget {
  final LogEntry item;

  const LogEntryWidget({Key? key, required this.item}) : super(key: key);

  void onTap(BuildContext context){
    Navigator.pushNamed(context, DetailedLogEntryWidget.routeName, arguments: item);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(item.displayName),
      subtitle: Text(item.dosage),
      trailing: Text(item.adminDate.toString()),
      onTap: () => onTap(context),
      onLongPress: () => print("longtap on $item"),
    );
  }
}
