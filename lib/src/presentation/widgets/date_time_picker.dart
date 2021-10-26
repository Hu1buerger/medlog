import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:medlog/src/util/date_time_extension.dart';

class DateTimePicker extends StatefulWidget {
  /// indicate to user shall select Date
  final bool selectDate;

  /// user shall select time
  final bool selectTime;

  /// the dateTime that is selected until the user selects another one
  /// or if null no DT is selected
  final DateTime? initiallySelectedDT;

  final DateTime? firstDT;
  final DateTime? selectedDT;
  final DateTime? lastDT;

  final String title;

  final void Function(DateTime selectedDT) onSelected;

  DateTimePicker(
      {Key? key,
      this.title = "",
      required this.onSelected,
      this.initiallySelectedDT,
      this.firstDT,
      this.selectedDT,
      this.lastDT,
      this.selectDate = true,
      this.selectTime = true})
      : assert(selectDate || selectTime),
        assert(() {
          //firstDT <= selectedDT
          if (selectedDT != null && firstDT != null) {
            return selectedDT.isAfter(firstDT) || firstDT.isAtSameMomentAs(selectedDT);
          }
          return true;
        }()),
        assert(() {
          //selectedDT <= lastDT
          if (selectedDT != null && lastDT != null) {
            return lastDT.isAfter(selectedDT) || selectedDT.isAtSameMomentAs(lastDT);
          }
          return true;
        }()),
        //TODO: assert selectDate && (firstDT != selectDT || selectDT != lastDT)
        super(key: key);

  //TODO: factory for picker for defining a range [-20 days, 3 * 365] as in DateTime + [i]

  factory DateTimePicker.range(
      {Key? key,
      required DateTime midDay,
      required Duration? toPast,
      required Duration? toFuture,
      required void Function(DateTime) onSelected,
      String? title,
      bool selectTime = true}) {
    // one Duration can be null and will be initialized to zero seconds
    assert(toPast != null || toFuture != null);
    toPast = toPast ?? const Duration();
    toFuture = toFuture ?? const Duration();

    assert(toPast.inSeconds != 0 || toFuture.inSeconds != 0);
    assert(toPast.inSeconds == 0 || toPast.isNegative);
    assert(toFuture.inSeconds == 0 || toFuture.isNegative == false);

    return DateTimePicker(
      key: key,
      title: title ?? "",
      onSelected: onSelected,
      selectedDT: midDay,
      firstDT: midDay.add(toPast),
      lastDT: midDay.add(toFuture),
      selectTime: selectTime,
    );
  }

  @override
  _DateTimePickerState createState() => _DateTimePickerState();
}

class _DateTimePickerState extends State<DateTimePicker> {
  static final Logger logger = Logger("DateTimePicker");

  late DateTime firstDT;
  late DateTime selectedDateTime;
  late DateTime lastDT;

  TextEditingController dateTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();

    /*
     * final kindaTomorrow = DateTime.now().add(const Duration(days: 2));
     * final tomorrow = DateTime(kindaTomorrow.year, kindaTomorrow.month, kindaTomorrow.day);
     * final lastYear = DateTime.now().add(const Duration(days: -365));
     */
    selectedDateTime = widget.selectedDT ?? DateTime.now();
    firstDT = widget.firstDT ?? selectedDateTime.subtract(const Duration(days: 365));
    lastDT = widget.lastDT ?? selectedDateTime.add(const Duration(days: 365));

    dateTimeController.text = widget.title;

    if (widget.initiallySelectedDT != null) {
      setSelectedDateTime(widget.initiallySelectedDT!);
    }
  }

  void setSelectedDateTime(DateTime dt) {
    if (selectedDateTime == dt) {
      logger.fine("reselecting the same DateTime, dont update");
      return;
    }

    logger.fine("selecting ${dt.toIso8601String()}");

    selectedDateTime = dt;
    dateTimeController.text = selectedDateTime.dateTimeString();

    widget.onSelected(selectedDateTime);
    setState(() {});
  }

  /// shows the dialog to select the administrationDateTime
  void showSelectDateTimeDialog(BuildContext context) async {
    // set the selected date in microseconds without timeofday
    int dateInMicroseconds = selectedDateTime.toDate().microsecondsSinceEpoch;

    if (widget.selectDate) {
      DateTime? selectedDate =
          await showDatePicker(context: context, initialDate: selectedDateTime, firstDate: firstDT, lastDate: lastDT);

      if (selectedDate == null) return;
      dateInMicroseconds = selectedDate.toDate().microsecondsSinceEpoch;
    }

    if (widget.selectTime) {
      var selectedTime = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(selectedDateTime));

      if (selectedTime == null) return;
      dateInMicroseconds += selectedTime.toMicroseconds();
    }

    var newSelectedDateTime = DateTime.fromMicrosecondsSinceEpoch(dateInMicroseconds);

    setSelectedDateTime(newSelectedDateTime);
  }

  void selectDate(BuildContext context) {}

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: TextField(
        controller: dateTimeController,
        decoration: const InputDecoration(border: OutlineInputBorder(), prefixIcon: Icon(Icons.schedule)),
        enabled: false, // disable the textinput, but also disables the onText
      ),
      onTap: () => showSelectDateTimeDialog(context),
    );
  }
}
