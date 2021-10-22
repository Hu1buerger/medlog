import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:medlog/src/controller/log/log_controller.dart';
import 'package:medlog/src/controller/pharmaceutical/pharmaceutical_controller.dart';
import 'package:medlog/src/controller/stock/stock_controller.dart';
import 'package:medlog/src/model/log_entry/stock_event.dart';
import 'package:medlog/src/model/pharmaceutical/pharmaceutical.dart';
import 'package:medlog/src/model/stock/stock_entry.dart';
import 'package:medlog/src/presentation/add_entrys/add_pharmaceutical.dart';
import 'package:medlog/src/presentation/widgets/date_time_picker.dart';
import 'package:medlog/src/presentation/widgets/option_selector.dart';
import 'package:medlog/src/presentation/widgets/pharmaceutical_card.dart';
import 'package:medlog/src/presentation/widgets/pharmaceutical_selector.dart';
import 'package:medlog/src/presentation/widgets/stock_item_card.dart';

// ignore_for_file: curly_braces_in_flow_control_structures

/// Modifiying the stock is what happpens often.
///
/// This widget should let the user pick what item he wants to
/// add or remove.
///
/// OR
///
/// The user received an item from the pharmacy and is now
/// wanting to track these
class AddStock extends StatefulWidget {
  static const String routeName = "/addStock";
  final String title = "Edit stock";

  final PharmaceuticalController pharmaceuticalController;

  final StockController stockController;
  final LogController logController;

  const AddStock(
      {Key? key, required this.pharmaceuticalController, required this.stockController, required this.logController})
      : super(key: key);

  @override
  _AddStockState createState() => _AddStockState();
}

class _AddStockState extends State<AddStock> {
  static final Logger logger = Logger("AddStock");
  static const Duration expiryOffsetPast = Duration(days: -(365 * 3));
  static const Duration expiryOffsetFuture = Duration(days: (365 * 5));

  late final List<Widget Function(BuildContext)> builders;

  int stage = 0;
  static const int stages = 3;

  late List<Option<num>> quantityOptions;

  Pharmaceutical? pharmaceutical;
  double? quantity;

  // uncertain when the expiration actually sets in.
  // - on the end of the day
  // - or as soon as the day starts...
  DateTime? expiryDate;
  StockState? state;

  @override
  void initState() {
    super.initState();

    builders = <Widget Function(BuildContext)>[
      buildStage0,
      buildStage1,
      buildStage2,
      buildStage3,
    ];

    quantityOptions = options();
  }

  List<Option<num>> options() {
    var options = List.generate(5, (index) => Option<int>(value: (index + 1) * 5));
    options.add(VariableOption<int>(value: 5, min: 1, max: 100, step: 1));

    return options;
  }

  void commit() {
    //check all parameters for validity;
    assert(stage == stages);
    assert(pharmaceutical != null);
    assert(quantity != null && quantity! > 0);
    assert(expiryDate != null);

    StockItem si = buildStockItem();
    StockEvent se = StockEvent.restock(DateTime.now(), si);

    widget.stockController.addStockItem(si);
    widget.logController.addStockEvent(se);
    Navigator.pop(context);
  }

  void setPharmaceutical(Pharmaceutical p) {
    if (pharmaceutical != null && pharmaceutical == p) {
      return;
    }

    setState(() => pharmaceutical = p);
  }

  void setQuantity(num units) {
    if (quantity != null && quantity! == units) {
      //log
      return;
    }

    setState(() => quantity = units.toDouble());
  }

  void setExpiryDate(DateTime dt) {
    if (expiryDate != null && expiryDate == dt) {
      return;
    }

    setState(() => expiryDate = dt);
  }

  @override
  void setState(VoidCallback fn) {
    fn();

    if (pharmaceutical == null)
      stage = 0;
    else if (quantity == null)
      stage = 1;
    else if (expiryDate == null)
      stage = 2;
    else
      stage = 3;

    logger.fine("setStage migrated to stage $stage");
    super.setState(() {});
  }

  StockItem buildStockItem() {
    assert(pharmaceutical != null && quantity != null && expiryDate != null);
    return StockItem.create(pharmaceutical!, quantity!, state ?? StockState.closed, expiryDate!);
  }

  /// stage 0 lets the user pick a pharmaceutical that he wants to edit
  Widget buildStage0(BuildContext context) {
    logger.fine("building stage 1");

    return PharmaceuticalSelector(
      pharmaceuticalController: widget.pharmaceuticalController,
      onSelectionChange: (Pharmaceutical? p) {
        logger.fine(p?.displayName ?? "unselected");

        setState(() => pharmaceutical = p);
      },
      onSelectionFailed: (q) => Navigator.pushNamed(context, AddPharmaceutical.routeName),
    );
  }

  /// stage 1 lets the user select the quantity to add
  ///
  /// TODO: add the option to select negative quantity as a "remove from stock action"
  Widget buildStage1(BuildContext context) {
    logger.fine("building stage 2");
    assert(pharmaceutical != null);

    return Column(
      children: [
        PharmaceuticalCard(
          pharmaceutical: pharmaceutical!,
          onLongPress: () => setState(() => pharmaceutical = null),
        ),
        OptionSelector<num>(options: quantityOptions, onSelectValue: setQuantity, selected: -1),
      ],
    );
  }

  /// stage 2 lets the user pick the date on which the pharmaceutical spoils
  Widget buildStage2(BuildContext context) {
    logger.fine("building stage 3");
    assert(quantity != null);

    return Column(
      children: [
        PharmaceuticalCard(
          pharmaceutical: pharmaceutical!,
          onLongPress: () => setState(() => pharmaceutical = null),
        ),
        OptionSelector(
            options: quantityOptions,
            onSelectValue: setQuantity,
            selected: quantityOptions.indexWhere((o) => o.value == quantity)),
        DateTimePicker.range(
          title: "expiryDate",
          midDay: DateTime.now(),
          toPast: expiryOffsetPast,
          toFuture: expiryOffsetFuture,
          onSelected: setExpiryDate,
          selectTime: false,
        )
      ],
    );
  }

  /// stage 3 displays the selected options and allows for checking
  ///
  /// TODO: add a press to goback // add onLongPress => goback stage
  Widget buildStage3(BuildContext context) {
    return Column(
      children: [StockItemCard(stockItem: buildStockItem()), TextButton(onPressed: commit, child: Text("Submit"))],
    );
  }

  Widget buildStage(BuildContext context) {
    assert(stage >= 0);

    if (stage < builders.length) {
      return builders[stage](context);
    }

    return const Center(child: Text("AddStock: Something failed..."));
  }

  @override
  Widget build(BuildContext context) {
    Widget body = buildStage(context);

    logger.fine("building scaffold");
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: body);
  }
}
