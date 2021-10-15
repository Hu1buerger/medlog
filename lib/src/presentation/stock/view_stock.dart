import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:medlog/src/controller/stock/stock_controller.dart';
import 'package:medlog/src/model/stock/stock_entry.dart';
import 'package:medlog/src/presentation/add_entrys/add_stock.dart';
import 'package:medlog/src/presentation/settings/settings.dart';

class ViewStock extends StatefulWidget {
  static const String routeName = "/viewStock";
  static const String title = "Stock";

  final StockController stockController;

  const ViewStock({Key? key, required this.stockController}) : super(key: key);

  @override
  State<ViewStock> createState() => _ViewStockState();
}

class _ViewStockState extends State<ViewStock> {
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

  void stockChanged(){
    _logger.fine("stock changed");

    stock = widget.stockController.stock;
    setState((){});
  }

  @override
  Widget build(BuildContext context) {
    var body;
    if(stock.isEmpty){
      widget.stockController.createStockItem(StockItem.create(widget.stockController.pharmaController.pharmaceuticals.first, 10, StockState.open, DateTime.now()));
      body = Text("such empty");
    }else{
      body = ListView.builder(
        itemCount: widget.stockController.stock.length,
        itemBuilder: (BuildContext context, int index){
          var stockItem = widget.stockController.stock[index];

          return ListTile(
            title: Text(stockItem.pharmaceutical.displayName),
            subtitle: Text("${stockItem.amount.toString()} ${describeEnum(stockItem.state)}"),
            trailing: Text(DateTime.now().difference(stockItem.expiryDate).inDays.toString()),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(ViewStock.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, Settings.route_name);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.create),
        backgroundColor: Colors.green,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AddStock()));
        },
      ),
      body: body
    );
  }
}
