import 'dart:math';

import 'package:flutter/material.dart';

extension MicrosecondableTimeOfDay on TimeOfDay {
  static final minuteToMicrosecods = 6 * pow(10, 7);

  /// converts timeOfDay to microseconds since
  int toMicroseconds() {
    return ((hour * 60 + minute) * minuteToMicrosecods).toInt();
  }
}

extension DateTimeExtension on DateTime{

  TimeOfDay toTimeOfDay(){
    return TimeOfDay.fromDateTime(this);
  }

  String toHumanString(){
    return "$year-$month-$day";
  }
}