import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:medlog/src/api_provider.dart';
import 'package:medlog/src/model/log_entry/medication_intake_event.dart';
import 'package:medlog/src/model/pharmaceutical/pharmaceutical.dart';
import 'package:medlog/src/model/stock/stock_entry.dart';
import 'package:medlog/src/presentation/add_entrys/add_pharmaceutical.dart';
import 'package:medlog/src/presentation/widgets/date_time_picker.dart';
import 'package:medlog/src/presentation/widgets/option_selector.dart';
import 'package:medlog/src/presentation/widgets/pharmaceutical_selector.dart';
import 'package:medlog/src/presentation/widgets/pharmaceutical_widget.dart';
import 'package:medlog/src/repo/pharmaceutical/pharmaceutical_repo.dart';
import 'package:medlog/src/repo/provider.dart';
import 'package:medlog/src/repo/stock/stock_controller.dart';

/// Supports adding a logentry to the log
///
/// This Widget is supposed to handle the feature to track the intake of medications
///
/// TODO: search through the medication database notonly by tradname but also by active_substance; use a filter/strategy
/// TODO: make this visually appealing
class AddLogEntry extends StatefulWidget {
  static const String routeName = "/addMedicationIntakeLog";

  final APIProvider provider;

  PharmaceuticalRepo get pharmaController => provider.pharmaRepo;

  LogProvider get logProvider => provider.logProvider;

  StockRepo get stockController => provider.stockRepository;

  const AddLogEntry({Key? key, required this.provider}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AddLogEntryState();
}

class _AddLogEntryState extends State<AddLogEntry> {
  static const String title = "Add medication to log";
  static const String DIALOG_ADD_PHARM_OK = "Yes";
  static const String DIALOG_ADD_PHARM_ABORT = "No";

  final Logger logger = Logger("AddLogEntryState");

  PharmaceuticalRepo get pharmaController => widget.pharmaController;

  LogProvider get logProvider => widget.logProvider;

  StockRepo get stockController => widget.stockController;

  TextEditingController adminDateController = TextEditingController();

  List<Pharmaceutical> currentOptions = <Pharmaceutical>[];

  _Modus modus = _Modus.searching;

  Pharmaceutical? selectedPharmaceutical;
  DateTime? adminTime;
  double selectedUnits = 1;

  _AddLogEntryState();

  @override
  void initState() {
    super.initState();
    logger.fine("initializing with options ${currentOptions.length}");

    setAdministrationDateTime(DateTime.now());
  }

  void onReset(BuildContext context) {
    modus = _Modus.searching;

    //TODO persist query;
    //TODO: reset all items.
  }

  void onCommitIntake(BuildContext context) {
    if (selectedPharmaceutical == null) return;

    commitIntake(context);
  }

  commitIntake(BuildContext context) async {
    assert(selectedPharmaceutical != null);
    assert(adminTime != null);
    assert(selectedUnits > 0);

    if (selectedUnits % selectedPharmaceutical!.smallestDosageSize != 0) {
      logger.info("selected unit is not safely supported");
    }

    var intakeEvent = MedicationIntakeEvent.create(selectedPharmaceutical!, adminTime!, selectedUnits);

    if (stockController.remainingUnits(intakeEvent.pharmaceutical) < intakeEvent.amount) {
      logger.severe(
          "to little stock to log the event and insure that the stock remains in a valid state aka contains no negative items");
      // as for now set source to stock.
      intakeEvent.source = PharmaceuticalSource.other;

      //TODO: inform the user that we he tries to perform non-stock-backed operation
      logProvider.addMedicationIntake(intakeEvent);

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
    logProvider.addMedicationIntake(intakeEvent);

    Navigator.pop(context);
    return true;
  }

  void setAdministrationDateTime(DateTime dateTime) {
    adminTime = dateTime;
  }

  void onSelectUnits(Option<num>? option) {
    if (option == null) {
      logger.fine("unselect the units");
      // just reset it....
      setState(() => selectedUnits = 1);
      return;
    }

    double units = option.value.toDouble();
    assert(units > 0);
    if (selectedUnits != units) {
      logger.finest("updating the selectedUnits to $units");
      selectedUnits = units;
      setState(() {});
    }
  }

  void onSearchEmpty(BuildContext context) async {
    String result = await selectAddPharmaceutical(context);
    if (result == DIALOG_ADD_PHARM_OK) {
      Navigator.of(context).popAndPushNamed(AddPharmaceutical.routeName);
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

  Widget buildSearchWindow(BuildContext context) {
    assert(modus == _Modus.searching);

    // maybe use GLobalKey to get info about the state. (why would we?)
    // maybe the pharmaceuticalSelector should handle empty options or callback onOptionsEmpty and/or callback the query
    return PharmaceuticalSelector(
      pharmaceuticalController: pharmaController,
      onSelectionChange: (Pharmaceutical? p) {
        if (selectedPharmaceutical == p) return;

        if (p == null) modus = _Modus.searching;
        if (p != null) modus = _Modus.medication_selected;

        selectedPharmaceutical = p;
        setState(() {});
      },
      onSelectionFailed: (query) => Navigator.pushNamed(context, AddPharmaceutical.routeName),
    );
  }

  Widget buildSelectedWidget(BuildContext context) {
    assert(modus == _Modus.medication_selected);
    assert(selectedPharmaceutical != null);

    double unitSize = selectedPharmaceutical!.smallestDosageSize;
    var unitOptions = List<Option<double>>.generate(3, (index) {
      double unitOption = unitSize * (index + 1);

      return Option(
        value: unitOption,
      );
    });

    unitOptions
        .add(VariableOption(value: selectedUnits, title: "custom", min: unitSize, max: 100 * unitSize, step: 0.25));

    // TODO_FUTURE: add dismissable to swipe on the Card to unselect
    var gollum = <Widget>[
      Card(
        child: PharmaceuticalWidget(
          pharmaceutical: selectedPharmaceutical!,
          units: selectedUnits,
          onLongPress: () {
            assert(selectedPharmaceutical != null);
            assert(modus != _Modus.searching);

            selectedPharmaceutical = null;
            modus = _Modus.searching;

            setState(() {});
          },
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: DateTimePicker(
          onSelected: setAdministrationDateTime,
          initiallySelectedDT: adminTime,
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: OptionSelector<num>(
            options: [...unitOptions],
            onSelectOption: onSelectUnits,
            selected: unitOptions.indexWhere((element) => element.value == selectedUnits)),
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
