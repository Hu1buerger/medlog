import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:medlog/src/add_entrys/add_pharmaceutical.dart';
import 'package:medlog/src/administration_log/log_controller.dart';
import 'package:medlog/src/pharmaceutical/pharmaceutical.dart';
import 'package:medlog/src/pharmaceutical/pharmaceutical_controller.dart';

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
  static const int max_options = 10;
  static const String DIALOG_ADD_PHARM_OK = "Yes";
  static const String DIALOG_ADD_PHARM_ABORT = "No";

  PharmaceuticalController get pharmaController => widget.pharmaController;
  LogController get logController => widget.logController;

  TextEditingController searchQueryController = TextEditingController();
  List<Pharmaceutical> currentOptions = <Pharmaceutical>[];

  _Modus modus = _Modus.searching;

  Pharmaceutical? selectedPharmaceutical;
  DateTime adminTime = DateTime.now();

  _AddLogEntryState();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentOptions = widget.pharmaController.pharmaceuticals;
  }

  @override
  setState(VoidCallback fn) {
    super.setState(fn);
  }

  void onReset(BuildContext context) {
    //Navigator.pop(context);
    modus = _Modus.searching;
    searchQueryController.text = "";
    updateQuery("", context);
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

  updateQuery(String query, BuildContext context) {
    currentOptions = sortPharmaceuticals(pharmaController.filter(query));
    if (currentOptions.isEmpty) {
      modus = _Modus.failed;
      onSearchEmpty(context);
    }else {
      setState(() {});
    }
  }

  selectPharmaceutical(Pharmaceutical p) {
    print("Selecting ${p.tradename} ${p.dosage}");

    selectedPharmaceutical = p;
    modus = _Modus.selected;
    setState((){});
  }

  onSearchEmpty(BuildContext context) async {
    String result = await showGotoAddPharmaceuticalDialog(context);
    if (result == DIALOG_ADD_PHARM_OK) Navigator.of(context).popAndPushNamed(AddPharmaceutical.route_name);
  }

  onEditingComplete(BuildContext context) {
    print("Editing complete with ${searchQueryController.text}");
    if (modus == _Modus.failed) onSearchEmpty(context);
  }

  Future<String> showGotoAddPharmaceuticalDialog(BuildContext context) async {
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

    if (selectedOption == null) // the user seems to have aborted the dialog?
      return DIALOG_ADD_PHARM_ABORT;
    return selectedOption;
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
                border: OutlineInputBorder(), hintText: 'Enter a search term', prefixIcon: Icon(Icons.search)),
            autocorrect: false,
            onChanged: (value) => updateQuery(value, context),
            onEditingComplete: () => onEditingComplete(context),
          ),
        ),
        Expanded(
            child: Card(
          child: ListView.builder(
              itemCount: min(max_options, currentOptions.length),
              itemBuilder: (BuildContext context, int index) {
                var currentItem = currentOptions[index];

                return ListTile(
                  title: Text(currentItem.tradename),
                  subtitle: Text(currentItem.dosage),
                  onTap: () => selectPharmaceutical(currentItem),
                );
              }),
        )),
      ],
    );
  }

  Widget buildSelectedWidget(BuildContext context) {
    assert(modus == _Modus.selected);
    assert(selectedPharmaceutical != null);

    //TODO: add dismissable
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: Card(
              child: ListTile(
                title: Text(selectedPharmaceutical!.tradename),
                subtitle: Text("${selectedPharmaceutical!.activeSubstance} ${selectedPharmaceutical!.dosage}"),
              )
            )),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [Text("later"), Text("now")],
            ))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    switch (modus) {
      case _Modus.searching:
        body = buildSearchWindow(context);
        break;
      case _Modus.selected:
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

enum _Modus { searching, selected, failed }
