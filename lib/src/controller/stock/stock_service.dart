import 'package:logging/logging.dart';
import 'package:medlog/src/controller/storage_service.dart';
import 'package:medlog/src/model/stock/stock_entry.dart';

class StockService extends StorageService<StockItem> {
  static final Logger _logger = Logger("StockService");
  static const String key = "stock";

  StockService() : super(key, _logger);

  @override
  StockItem fromJson(Map<String, dynamic> json) => StockItem.fromJson(json);

  @override
  Map<String, dynamic> toJson(StockItem t) => t.toJson();
}
