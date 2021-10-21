import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:medlog/src/util/date_time_extension.dart';

class DateTimePicker extends StatefulWidget {

  final void Function(DateTime selectedDT) onSelected;

  const DateTimePicker({Key? key, required this.onSelected}) : super(key: key);

  //TODO: factory for picker for defining a range [-20 days, 3 * 365] as in DateTime + [i]

  @override
  _DateTimePickerState createState() => _DateTimePickerState();
}

class _DateTimePickerState extends State<DateTimePicker> {
  static final Logger logger = Logger("DateTimePicker");

  late DateTime selectedDateTime;
  TextEditingController dateTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();

    selectedDateTime = DateTime.now();
    dateTimeController.text = selectedDateTime.dateTimeString();
  }

  void setSelectedDateTime(DateTime dt, {bool setState = true}){
    if(selectedDateTime == dt){
      logger.fine("reselecting the same DateTime, dont update");
      return;
    }

    logger.fine("selecting ${dt.toIso8601String()}");

    selectedDateTime = dt;
    dateTimeController.text = selectedDateTime.dateTimeString();

    if(setState){
      this.setState((){});
    }
  }

  /// shows the dialog to select the administrationDateTime
  void showSelectDateTimeDialog(BuildContext context) async {
    final kindaTomorrow = DateTime.now().add(const Duration(days: 2));
    final tomorrow = DateTime(kindaTomorrow.year, kindaTomorrow.month, kindaTomorrow.day);
    final lastYear = DateTime.now().add(const Duration(days: -365));

    DateTime? selectedDate =
    await showDatePicker(context: context, initialDate: selectedDateTime, firstDate: lastYear, lastDate: tomorrow);

    if (selectedDate == null) return;

    var selectedTime = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(selectedDateTime));

    if (selectedTime == null) return;

    var dateInMicrosecSinceEpoch = selectedDate.microsecondsSinceEpoch + selectedTime.toMicroseconds();
    var newSelectedDateTime = DateTime.fromMicrosecondsSinceEpoch(dateInMicrosecSinceEpoch);

    setSelectedDateTime(newSelectedDateTime);
  }

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
