import 'package:flutter/material.dart';
import 'package:medlog/src/controller/pharmaceutical/pharmaceutical_controller.dart';
import 'package:medlog/src/model/pharmaceutical/pharmaceutical.dart';
import 'package:medlog/src/presentation/add_entrys/add_pharmaceutical.dart';
import 'package:medlog/src/presentation/add_entrys/pharmaceutical_selector.dart';

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
  Pharmaceutical? pharmaceutical;
  double? selectedQuantity;

  // uncertain when the expiration actually sets in.
  // - on the end of the day
  // - or as soon as the day starts...
  DateTime? selectedExpiryDate;

  buildSelectPharmaceutical(BuildContext context) {
    return PharmaceuticalSelector(
      pharmaceuticalController: widget.pharmaceuticalController,
      onSelectionChange: (Pharmaceutical? p) {
        print(p?.displayName ?? "unselected");
        pharmaceutical = p;
      },
      onSelectionFailed: (q) => Navigator.pushNamed(context, AddPharmaceutical.routeName),
    );
  }

  buildSelectQuantity(BuildContext context){
    return Center(child: Text("TODO add select quantity"));
  }

  buildSelectExpiryDate(BuildContext context){
    return Center(child: Text("Unimplemented select expiry Date"),);
  }

  @override
  Widget build(BuildContext context) {
    var body = const Center(child: Text("AddStock: Not implemented rn"));

    if(pharmaceutical == null) body = buildSelectPharmaceutical(context);
    if(selectedQuantity == null) body = buildSelectQuantity(context);
    if(selectedExpiryDate == null) body = buildSelectExpiryDate(context);

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: body);
  }
}
