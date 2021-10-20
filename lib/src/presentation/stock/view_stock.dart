import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:medlog/src/controller/stock/stock_controller.dart';
import 'package:medlog/src/model/stock/stock_entry.dart';
import 'package:medlog/src/presentation/add_entrys/add_stock.dart';
import 'package:medlog/src/presentation/home_page/home_page.dart';
import 'package:medlog/src/presentation/settings/settings.dart';

class StockView extends StatefulWidget with HomePagePage {
  static const String routeName = "/viewStock";
  static const String title = "Stock";

  final StockController stockController;

  const StockView({Key? key, required this.stockController}) : super(key: key);

  @override
  State<StockView> createState() => _StockViewState();

  @override
  String? tabtitle() {
    return title;
  }

  @override
  PreferredSizeWidget? appBar(BuildContext context) {
    return AppBar(
      title: const Text(StockView.title),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.pushNamed(context, Settings.route_name);
          },
        ),
      ],
    );
  }

  @override
  Widget? floatingActionButton(BuildContext context) {
    return FloatingActionButton(
      child: const Icon(Icons.create),
      backgroundColor: Colors.green,
      onPressed: () => Navigator.pushNamed(context, AddStock.routeName),
    );
  }
}

class _StockViewState extends State<StockView> {
  static final Logger _logger = Logger("ViewStock");

  late List<StockItem> stock;

  @override
  void initState() {
    super.initState();
    stock = widget.stockController.stock;
    widget.stockController.addListener(stockChanged);
  }

  @override
  void dispose() {
    super.dispose();

    widget.stockController.removeListener(stockChanged);
  }

  void stockChanged() {
    _logger.fine("stock changed");

    stock = widget.stockController.stock;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (stock.isEmpty) {
      body = const Center(child: Text("such empty"));
    } else {
      body = ListView.builder(
        itemCount: stock.length,
        itemBuilder: (BuildContext context, int index) {
          var stockItem = stock[index];

          ///TODO: show all relevant details onClick
          /// for now
          ///
          /// remaining days til spoiled stockItem.expiryDate.difference(DateTime.now()).inDays.toString()
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey,
              child: Text(stockItem.state == StockState.open ? "O" : "C"),
            ),
            title: Text(stockItem.pharmaceutical.displayName),
            trailing: Text(stockItem.amount.toString()),
            onLongPress: () {
              widget.stockController.openItem(stockItem);
            },
          );
        },
      );
    }

    return body;
  }
}
