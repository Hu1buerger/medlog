import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:medlog/src/administration_log/administration_log_entry.dart';

class LogEntryWidget extends StatelessWidget{
 final AdministrationLogEntry item;

 const LogEntryWidget({required this.item, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(item.pharamaceutical.tradename),
      subtitle: Text(item.pharamaceutical.dosage),
      trailing: Text(item.adminDate.toString()),
    );
  }
}