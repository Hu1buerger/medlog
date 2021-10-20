import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:medlog/src/controller/pharmaceutical/pharmaceutical_controller.dart';
import 'package:medlog/src/model/pharmaceutical/pharmaceutical.dart';
import 'package:medlog/src/presentation/add_entrys/add_pharmaceutical.dart';
import 'package:medlog/src/presentation/add_entrys/option_selector.dart';
import 'package:medlog/src/presentation/add_entrys/pharmaceutical_selector.dart';
import 'package:medlog/src/presentation/pharmaceutical_card.dart';

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

  const AddStock({Key? key, required this.pharmaceuticalController}) : super(key: key);

  @override
  _AddStockState createState() => _AddStockState();
}

class _AddStockState extends State<AddStock> {
  static final Logger logger = Logger("AddStock");

  Pharmaceutical? pharmaceutical;
  double? selectedQuantity;

  // uncertain when the expiration actually sets in.
  // - on the end of the day
  // - or as soon as the day starts...
  DateTime? selectedExpiryDate;

  buildSelectPharmaceutical(BuildContext context) {
    logger.fine("building stage 1");

    return PharmaceuticalSelector(
      pharmaceuticalController: widget.pharmaceuticalController,
      onSelectionChange: (Pharmaceutical? p) {
        print(p?.displayName ?? "unselected");

        setState(() => pharmaceutical = p);
      },
      onSelectionFailed: (q) => Navigator.pushNamed(context, AddPharmaceutical.routeName),
    );
  }

  buildSelectQuantity(BuildContext context) {
    logger.fine("building stage 2");
    assert(pharmaceutical != null);

    var options = List.generate(9, (index) => Option<num>(value: (index + 1) * 5));
    options.add(VariableOption(value: 5, min: 1, max: 100, step: 1.0));

    return Column(
        children: [
          PharmaceuticalCard(pharmaceutical: pharmaceutical!, onLongPress: () => setState(() => pharmaceutical = null),),
          OptionSelector(options: options, onSelectValue: (suntis) => print(suntis)),
        ],
    );
  }

  buildSelectExpiryDate(BuildContext context) {
    logger.fine("building stage 3");

    return Center(
      child: Text("Unimplemented select expiry Date"),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget body = const Center(child: Text("AddStock: Not implemented rn"));

    if (pharmaceutical == null) body = buildSelectPharmaceutical(context);
    else if (selectedQuantity == null) body = buildSelectQuantity(context);
    else if (selectedExpiryDate == null) body = buildSelectExpiryDate(context);

    logger.fine("building scaffold");
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: body);
  }
}
