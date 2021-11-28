import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:medlog/src/repo/stock/stock_controller.dart';
import 'package:medlog/src/model/stock/stock_entry.dart';
import 'package:medlog/src/presentation/add_entrys/add_stock.dart';
import 'package:medlog/src/presentation/home_page/home_page.dart';
import 'package:medlog/src/presentation/settings/settings.dart';
import 'package:medlog/src/presentation/stock/stock_item_card.dart';
import 'package:medlog/src/presentation/stock/stock_item_detail.dart';

class StockView extends StatefulWidget with HomePagePage {
  static const String routeName = "/viewStock";
  static const String title = "Stock";

  final StockRepo stockController;

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

  List<StockItem> get stock => widget.stockController.stock;

  @override
  void initState() {
    super.initState();
    widget.stockController.addListener(stockChanged);
  }

  @override
  void dispose() {
    super.dispose();
    widget.stockController.removeListener(stockChanged);
  }

  void stockChanged() {
    _logger.fine("stock changed");

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

          /// TODO: show all relevant details onClick
          /// remaining days til spoiled stockItem.expiryDate.difference(DateTime.now()).inDays.toString()
          return StockItemCard(
            stockItem: stockItem,
            onTap: () => Navigator.pushNamed(context, StockItemDetail.routeName, arguments: stockItem),
            onLongPress: () => widget.stockController.openItem(stockItem),
          );
        },
      );
    }

    return body;
  }
}
