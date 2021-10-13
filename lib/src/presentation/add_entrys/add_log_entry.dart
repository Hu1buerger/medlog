import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:medlog/src/controller/administration_log/log_controller.dart';
import 'package:medlog/src/controller/pharmaceutical/pharmaceutical_controller.dart';
import 'package:medlog/src/model/pharmaceutical/pharmaceutical.dart';
import 'package:medlog/src/presentation/add_entrys/add_pharmaceutical.dart';

/// Supports adding a logentry to the log
///
/// This Widget is supposed to handle the feature to track the intake of medications
///
/// TODO: search through the medication database notonly by tradname but also by active_substance; use a filter/strategy
/// TODO: make this visually appealing
class AddLogEntry extends StatefulWidget {
  static const String routeName = "/addMedicationIntakeLog";

  final PharmaceuticalController pharmaController;
  final LogController logController;

  const AddLogEntry({Key? key, required this.pharmaController, required this.logController}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AddLogEntryState();
}

class _AddLogEntryState extends State<AddLogEntry> {
  static const String title = "Add medication to log";
  static const String DIALOG_ADD_PHARM_OK = "Yes";
  static const String DIALOG_ADD_PHARM_ABORT = "No";

  final Logger logger = Logger("AddLogEntryState");

  PharmaceuticalController get pharmaController => widget.pharmaController;

  LogController get logController => widget.logController;

  TextEditingController searchQueryController = TextEditingController();
  TextEditingController adminDateController = TextEditingController();

  List<Pharmaceutical> currentOptions = <Pharmaceutical>[];

  _Modus modus = _Modus.searching;
  Pharmaceutical? selectedPharmaceutical;
  DateTime adminTime = DateTime.now();

  _AddLogEntryState();

  @override
  void initState() {
    super.initState();
    setOptions(pharmaController.pharmaceuticals);
    logger.fine("initializing with options ${currentOptions.length}");

    pharmaController.addListener(onPharmaControllerChange);
    setAdministrationDateTime(adminTime);
  }

  @override
  void dispose() {
    super.dispose();
    pharmaController.removeListener(onPharmaControllerChange);
  }

  void onPharmaControllerChange() {
    logger.fine("change in pharmaController");
    updateQuery(searchQueryController.text);
  }

  void onReset(BuildContext context) {
    modus = _Modus.searching;
    searchQueryController.text = "";
    updateQuery("");
  }

  void onDone(BuildContext context) {
    if (selectedPharmaceutical == null) return;

    logController.addLogEntry(selectedPharmaceutical!, adminTime);
    Navigator.pop(context);
  }

  List<Pharmaceutical> sortPharmaceuticals(List<Pharmaceutical> list) {
    list.sort((a, b) => a.displayName.compareTo(b.displayName));
    return list;
  }

  void updateQuery(String query) {
    var options = pharmaController.filter(query);
    logger.fine("updated current options to ${options.length}");

    setOptions(options);
  }

  void setOptions(List<Pharmaceutical> options) {
    currentOptions = sortPharmaceuticals(options);
    setState(() {});
  }

  void setPharmaceutical(Pharmaceutical p) {
    logger.fine("Selecting ${p.id} ${p.displayName}");

    selectedPharmaceutical = p;
    modus = _Modus.medication_selected;
    setState(() {});
  }

  void unselectPharmaceutical() {
    if (selectedPharmaceutical == null) {
      logger.severe(
          "unselectPharmaceutical called even though no pharmaceutical was set and modus is ${describeEnum(modus)}");
      return;
    }

    logger.fine("Deselecting ${selectedPharmaceutical!.id} ${selectedPharmaceutical!.displayName}");
    modus = _Modus.searching;
    selectedPharmaceutical = null;
    setState(() {});
  }

  void setAdministrationDateTime(DateTime dateTime) {
    adminTime = dateTime;
    adminDateController.text = adminTime.toIso8601String();
    // no need to setState bcs the TextController will update the neccessary widget
  }

  void onSearchEmpty(BuildContext context) async {
    String result = await selectAddPharmaceutical(context);
    if (result == DIALOG_ADD_PHARM_OK) {
      Navigator.of(context).popAndPushNamed(AddPharmaceutical.route_name);
    }
  }

  void onEditingComplete(BuildContext context) {
    logger.fine("Editing complete with ${searchQueryController.text}");

    if (currentOptions.isEmpty) {
      modus = _Modus.failed;
    }

    if (modus == _Modus.failed) onSearchEmpty(context);
  }

  /// shows the dialog to select whether or not to add a new pharmaceutical
  Future<String> selectAddPharmaceutical(BuildContext context) async {
    String? selectedOption = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Search failed"),
            content: const Text("would you like to create the medication"),
            actions: <Widget>[
              TextButton(
                child: const Text("No"),
                onPressed: () => Navigator.of(context).pop(DIALOG_ADD_PHARM_ABORT),
              ),
              TextButton(
                child: const Text("Yes"),
                onPressed: () => Navigator.of(context).pop(DIALOG_ADD_PHARM_OK),
              )
            ],
          );
        });

    if (selectedOption == null) {
      // the user seems to have aborted the dialog, as for now default should be abort
      return DIALOG_ADD_PHARM_ABORT;
    }

    return selectedOption;
  }

  /// shows the dialog to select the administrationDateTime
  void selectAdministrationDateTime(BuildContext context) async {
    final kindaTomorrow = DateTime.now().add(const Duration(days: 2));
    final tomorrow = DateTime(kindaTomorrow.year, kindaTomorrow.month, kindaTomorrow.day);
    final lastYear = DateTime.now().add(const Duration(days: -365));

    DateTime? selectedDate =
        await showDatePicker(context: context, initialDate: adminTime, firstDate: lastYear, lastDate: tomorrow);

    if (selectedDate == null) return;

    var selectedTime = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(adminTime));

    if (selectedTime == null) return;

    var dateInMicrosecSinceEpoch = selectedDate.microsecondsSinceEpoch + selectedTime.toMicroseconds();
    var selectedDateTime = DateTime.fromMicrosecondsSinceEpoch(dateInMicrosecSinceEpoch);

    setAdministrationDateTime(selectedDateTime);
  }

  Widget buildSearchWindow(BuildContext context) {
    assert(modus == _Modus.searching);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: TextField(
            controller: searchQueryController,
            decoration: const InputDecoration(
                border: OutlineInputBorder(), hintText: 'Enter a search term:', prefixIcon: Icon(Icons.search)),
            autocorrect: false,
            onChanged: (value) => updateQuery(value),
            onEditingComplete: () => onEditingComplete(context),
          ),
        ),
        Expanded(
            child: Card(
          child: ListView.builder(
              itemCount: currentOptions.length,
              itemBuilder: (BuildContext context, int index) {
                var currentItem = currentOptions[index];

                return ListTile(
                  title: Text(currentItem.displayName),
                  subtitle: Row(
                    children: [
                      Text(currentItem.activeSubstance ?? ""),
                      const SizedBox(width: 10),
                      Text(currentItem.dosage)
                    ],
                  ),
                  onTap: () => setPharmaceutical(currentItem),
                );
              }),
        )),
      ],
    );
  }

  Widget buildSelectedWidget(BuildContext context) {
    assert(modus == _Modus.medication_selected);
    assert(selectedPharmaceutical != null);

    //TODO: add dismissable to swipe on the Card to unselect
    // the list of items to display
    var gollum = <Widget>[
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Card(
            child: ListTile(
              title: Text(selectedPharmaceutical!.tradename),
              subtitle: Text("${selectedPharmaceutical!.activeSubstance} ${selectedPharmaceutical!.dosage}"),
              onLongPress: unselectPharmaceutical,
            ),
          )),
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: GestureDetector(
            child: TextField(
              controller: adminDateController,
              decoration: const InputDecoration(border: OutlineInputBorder(), prefixIcon: Icon(Icons.schedule)),
              enabled: false, // disable the textinput, but also disables the onText
            ),
            onTap: () => selectAdministrationDateTime(context),
          ))
    ];

    return SingleChildScrollView(child: Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: gollum));
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    switch (modus) {
      case _Modus.searching:
        body = buildSearchWindow(context);
        break;
      case _Modus.medication_selected:
        body = buildSelectedWidget(context);
        break;
      case _Modus.failed:
      // TODO: Handle this case.
      default:
        body = const Text("Such empty");
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text(title),
          actions: [
            IconButton(
              icon: const Icon(Icons.restart_alt_outlined),
              onPressed: () => onReset(context),
            ),
            IconButton(
              icon: const Icon(Icons.done),
              onPressed: () => onDone(context),
            ),
          ],
        ),
        body: body);
  }
}

enum _Modus {
  /// searching for a medication
  searching,

  /// selected the medication to log
  medication_selected,

  /// search for a medication resulted in no found medication
  failed
}

extension MicrosecondableTimeOfDay on TimeOfDay {
  static final minuteToMicrosecods = 6 * pow(10, 7);

  /// converts timeOfDay to microseconds since
  int toMicroseconds() {
    return ((hour * 60 + minute) * minuteToMicrosecods).toInt();
  }
}
