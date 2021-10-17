import 'package:json_annotation/json_annotation.dart';
import 'package:medlog/src/model/pharmaceutical/pharmaceutical.dart';

part 'stock_entry.g.dart';

/// Represents the current stock state
@JsonSerializable(ignoreUnannotated: true)
class StockItem {
  static const String emptyID = "";

  /// the id of this stockItem
  @JsonKey()
  String id;

  /// the id of the pharmaceutical that is logged as stock
  @JsonKey()
  String pharmaceuticalID;

  ///the amount of medication still available in this unit
  @JsonKey()
  double amount;

  /// denotes wheter or not this unit is started or still closed
  @JsonKey()
  StockState state;

  @JsonKey()
  DateTime expiryDate;

  Pharmaceutical? _pharmaceutical;

  Pharmaceutical get pharmaceutical => _pharmaceutical!;

  set pharmaceutical(Pharmaceutical p) {
    if (p.id_is_set == false || (pharmaceuticalID != Pharmaceutical.emptyID && p.id != pharmaceuticalID)) {
      throw ArgumentError("wrong phramaceutical");
    }
    _pharmaceutical = p;
  }

  StockItem(this.id, this.pharmaceuticalID, this.amount, this.state, this.expiryDate) {
    if (amount <= 0) throw ArgumentError.value(amount, "amount", "amount violates the constraints [1,...]");
  }

  factory StockItem.create(Pharmaceutical pharmaceutical, double amount, StockState itemState, DateTime expiryDate) {
    return StockItem(emptyID, pharmaceutical.id, amount, itemState, expiryDate)..pharmaceutical = pharmaceutical;
  }

  factory StockItem.fromJson(Map<String, dynamic> json) => _$StockItemFromJson(json);

  Map<String, dynamic> toJson() => _$StockItemToJson(this);
}

enum StockState { closed, open }
