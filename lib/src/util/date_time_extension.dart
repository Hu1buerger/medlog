import 'dart:math';

import 'package:flutter/material.dart';

extension MicrosecondableTimeOfDay on TimeOfDay {
  static final minuteToMicrosecods = 6 * pow(10, 7);

  /// converts timeOfDay to microseconds since
  int toMicroseconds() {
    return ((hour * 60 + minute) * minuteToMicrosecods).toInt();
  }
}

extension DateTimeExtension on DateTime {
  TimeOfDay toTimeOfDay() {
    return TimeOfDay.fromDateTime(this);
  }

  DateTime toDate() {
    return DateTime(year, month, day);
  }

  String dateString() {
    return "$year-$month-$day";
  }

  String timeString() {
    return "$hour:$minute";
  }

  String dateTimeString() {
    return "${dateString()} ${timeString()}";
  }

  bool isSameDay(DateTime other) {
    // match day first bcs it is most likely to change
    return day == other.day && month == other.month && year == other.year;
  }
}
