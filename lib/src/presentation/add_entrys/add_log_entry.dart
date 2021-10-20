import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:medlog/src/controller/log/log_controller.dart';
import 'package:medlog/src/controller/pharmaceutical/pharmaceutical_controller.dart';
import 'package:medlog/src/controller/stock/stock_controller.dart';
import 'package:medlog/src/model/log_entry/medication_intake_event.dart';
import 'package:medlog/src/model/pharmaceutical/pharmaceutical.dart';
import 'package:medlog/src/model/stock/stock_entry.dart';
import 'package:medlog/src/presentation/add_entrys/add_pharmaceutical.dart';
import 'package:medlog/src/presentation/add_entrys/option_selector.dart';
import 'package:medlog/src/presentation/add_entrys/pharmaceutical_selector.dart';
import 'package:medlog/src/util/date_time_extension.dart';

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
  final StockController stockController;

  const AddLogEntry(
      {Key? key, required this.pharmaController, required this.logController, required this.stockController})
      : super(key: key);

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

  StockController get stockController => widget.stockController;

  TextEditingController adminDateController = TextEditingController();

  List<Pharmaceutical> currentOptions = <Pharmaceutical>[];

  _Modus modus = _Modus.searching;
  Pharmaceutical? selectedPharmaceutical;
  DateTime adminTime = DateTime.now();
  double selectedUnits = 1;

  _AddLogEntryState();

  @override
  void initState() {
    super.initState();
    logger.fine("initializing with options ${currentOptions.length}");

    setAdministrationDateTime(adminTime);
  }

  void onReset(BuildContext context) {
    modus = _Modus.searching;

    //TODO persist query;

    //searchQueryController.text = "";
    //updateQuery("");
  }

  void onCommitIntake(BuildContext context) {
    if (selectedPharmaceutical == null) return;

    commitIntake(context);
  }

  commitIntake(BuildContext context) async {
    assert(selectedPharmaceutical != null);

    if (selectedUnits % selectedPharmaceutical!.smallestConsumableUnit != 0) {
      logger.info("selected unit is not safely supported");
    }

    var intakeEvent = MedicationIntakeEvent.create(selectedPharmaceutical!, adminTime, selectedUnits);

    if (stockController.remainingUnits(intakeEvent.pharmaceutical) < intakeEvent.amount) {
      logger.severe(
          "to little stock to log the event and insure that the stock remains in a valid state aka contains no negative items");
      // as for now set source to stock.
      intakeEvent.source = PharmaceuticalSource.other;

      //TODO: inform the user that we he tries to perform non-stock-backed operation
      logController.addMedicationIntake(intakeEvent);

      Navigator.pop(context);
      return;
    }

    double remainingUnits = intakeEvent.amount;

    while (remainingUnits > 0) {
      var stockItems = stockController.stockItemByPharmaceutical(intakeEvent.pharmaceutical);
      var openItems = stockItems.where((element) => element.state == StockState.open);

      StockItem? stockItemToTakeFrom;

      if (openItems.length != 1) {
        logger.severe("no open items to take from");
        await showDialog(
            context: context,
            builder: (context) {
              var options = List.generate(stockItems.length, (index) {
                var stockItem = stockItems[index];
                return SimpleDialogOption(
                  onPressed: () {
                    if (stockItem.state == StockState.closed) {
                      stockController.openItem(stockItem);
                    }
                    stockItemToTakeFrom = stockItem;
                    Navigator.pop(context);
                  },
                  child: Text(
                      "${describeEnum(stockItem.state)[0]} ${stockItem.pharmaceutical.displayName} spoils on ${stockItem.expiryDate.toString()}"),
                );
              });

              return SimpleDialog(
                title: Text("select item to take from"),
                children: [...options],
              );
            });
      } else {
        stockItemToTakeFrom = openItems.single;
      }

      assert(stockItemToTakeFrom!.pharmaceutical == intakeEvent.pharmaceutical);

      if (stockItemToTakeFrom!.amount < intakeEvent.amount) {
        logger.severe("unhandled the stock has to little units available to handle this shit");
      }

      remainingUnits = stockController.takeFromStockItem(stockItemToTakeFrom!, intakeEvent.amount);
    }

    // as for now set source to stock.
    intakeEvent.source = PharmaceuticalSource.stock;
    logController.addMedicationIntake(intakeEvent);

    Navigator.pop(context);
    return true;
  }

  void setAdministrationDateTime(DateTime dateTime) {
    adminTime = dateTime;
    adminDateController.text = adminTime.toIso8601String();
    // no need to setState bcs the TextController will update the neccessary widget
  }

  void onSelectUnits(double units) {
    if (selectedUnits != units) {
      logger.finest("updating the selectedUnits to $units");
      selectedUnits = units;
      setState(() {});
    }
  }

  void onSearchEmpty(BuildContext context) async {
    String result = await selectAddPharmaceutical(context);
    if (result == DIALOG_ADD_PHARM_OK) {
      Navigator.of(context).popAndPushNamed(AddPharmaceutical.route_name);
    }
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

    //TODO: maybe use GLobalKey to get info about the state.
    // maybe the pharmaceuticalSelector should handle empty options or callback onOptionsEmpty and/or callback the query
    return PharmaceuticalSelector(
        pharmaceuticalController: pharmaController,
        onSelectionChange: (Pharmaceutical? p) {
          if (selectedPharmaceutical == p) return;

          if (p == null) modus = _Modus.searching;
          if (p != null) modus = _Modus.medication_selected;

          selectedPharmaceutical = p;
        });
  }

  Widget buildSelectedWidget(BuildContext context) {
    assert(modus == _Modus.medication_selected);
    assert(selectedPharmaceutical != null);

    double unitSize = selectedPharmaceutical!.smallestConsumableUnit;
    var unitOptions = List<Option<num>>.generate(5, (index) {
      double unitOption = unitSize * (index + 1);

      return Option(
        value: unitOption,
      );
    });

    unitOptions.add(VariableOption(value: 1, title: "custom", min: unitSize, max: 100 * unitSize, step: unitSize));

    //TODO: add dismissable to swipe on the Card to unselect
    // the list of items to display
    var gollum = <Widget>[
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Card(
            child: ListTile(
              title: Text(selectedPharmaceutical!.tradename),
              subtitle: Text(
                  "${selectedPharmaceutical!.activeSubstance} ${selectedPharmaceutical!.dosage.scale(selectedUnits)}"),
              onLongPress: () {
                assert(selectedPharmaceutical != null);
                assert(modus != _Modus.searching);

                selectedPharmaceutical = null;
                modus = _Modus.searching;

                setState(() {});
              },
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
          )),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: OptionSelector<num>(
          options: [...unitOptions],
          onSelectValue: (num value) => onSelectUnits(value.toDouble()),
        ),
      )
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
              onPressed: () => onCommitIntake(context),
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
