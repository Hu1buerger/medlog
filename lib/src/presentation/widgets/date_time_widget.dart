import 'package:flutter/material.dart';
import 'package:medlog/src/util/date_time_extension.dart';

class DateTimeWidget extends StatelessWidget {
  final int maxDays;

  final DateTime dateTime;
  final bool showDate;
  final bool showTime;

  const DateTimeWidget({Key? key, required this.dateTime, this.showDate = true, this.showTime = true, this.maxDays = 7})
      : assert(showDate || showTime),
        super(key: key);

  String formatDate() {
    DateTime now = DateTime.now();

    if (dateTime.isSameDay(now)) return "today";
    if (dateTime.isSameDay(now.subtract(const Duration(days: 1)))) {
      return "yesterday";
    }

    var duration = now.difference(dateTime).abs();
    if (duration.inDays <= maxDays) {
      if (now.isAfter(dateTime)) {
        return "${duration.inDays} days ago";
      }
      return "in ${duration.inDays} days";
    }

    return dateTime.dateString();
  }

  @override
  Widget build(BuildContext context) {
    if (showDate && !showTime) {
      return Text(formatDate());
    }

    return Text(
        "${showDate ? dateTime.dateString() : ""} ${showTime ? dateTime.timeString() : ""}"
            .trim());
  }
}
