import 'package:flutter/material.dart';
import 'package:medlog/src/model/stock/stock_entry.dart';
import 'package:medlog/src/presentation/widgets/pharmaceutical_widget.dart';
import 'package:medlog/src/util/date_time_extension.dart';

class StockItemCard extends StatelessWidget {
  final StockItem stockItem;

  final void Function()? onTap;
  final void Function()? onLongPress;

  const StockItemCard({Key? key, required this.stockItem, this.onTap, this.onLongPress}) : super(key: key);

  Widget buildState(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Colors.grey,
      child: Text(stockItem.state == StockState.open ? "O" : "C"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: buildState(context),
        title: PharmaceuticalWidget(pharmaceutical: stockItem.pharmaceutical),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${stockItem.amount.toString()} Pcs"),
            Text("expires on: ${stockItem.expiryDate.dateString()}")
          ],
        ),
        onTap: onTap,
        onLongPress: onLongPress,
      ),
    );
  }
}
