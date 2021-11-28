import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:medlog/src/repo/stock/stock_controller.dart';
import 'package:medlog/src/model/stock/stock_entry.dart';
import 'package:medlog/src/presentation/widgets/date_time_widget.dart';
import 'package:medlog/src/presentation/widgets/option_selector.dart';
import 'package:medlog/src/presentation/widgets/pharmaceutical_widget.dart';

class StockItemDetail extends StatelessWidget {
  static const String routeName = "/stockItemDetail";
  static const String title = "Details";

  final StockItem stockItem;

  final StockRepo stockController;

  const StockItemDetail({Key? key, required this.stockController, required this.stockItem}) : super(key: key);

  /// Deletes the stockItem
  ///
  /// method called by button press
  void delete() {
    stockController.delete(stockItem);
  }

  /// toggles the stockstate
  void toggleState(BuildContext context) {
    stockController.updateStockState(
        stockItem, stockItem.state == StockState.open ? StockState.closed : StockState.open);
    Navigator.popAndPushNamed(context, routeName, arguments: stockItem);
  }

  Widget buildKeyValuePair(String title, Widget value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [Text(title), const Spacer(), value],
    );
  }

  quickActions() {
    const int stepSize = 5;

    var options = <Option<double>>[];
    for (int i = 0; i <= stockItem.amount; i += stepSize) {
      options.add(Option(value: i.toDouble(), leading: "-"));
    }

    if (stockItem.amount % stepSize != 0) {
      options.add(Option(value: stockItem.amount, leading: "-"));
    }

    final min = stockItem.pharmaceutical.smallestConsumableUnit;
    options.add(VariableOption<double>(value: 1, min: min, max: stockItem.amount, step: min));

    return options;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(title),
          actions: const [],
        ),
        body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildKeyValuePair(
                    "Pharmaceutical",
                    Flexible(
                        flex: 7, child: Card(child: PharmaceuticalWidget(pharmaceutical: stockItem.pharmaceutical)))),
                buildKeyValuePair(
                    "Expiry date",
                    DateTimeWidget(
                      dateTime: stockItem.expiryDate,
                      showTime: false,
                    )),
                buildKeyValuePair("Remaining", Text(stockItem.amount.toString() + " Pcs")),
                buildKeyValuePair(
                    "State",
                    InkWell(
                      child: Text(describeEnum(stockItem.state)),
                      onTap: () => toggleState(context),
                    )),
                //TODO: add quickoptions as per #26
                //OptionSelector<double>(options: quickActions(), onSelectValue: (d) => print(d)), clicking on one shoudnt trigger a removal asap
                ElevatedButton(onPressed: delete, child: const Text("delete me"))
              ],
            )));
  }
}
