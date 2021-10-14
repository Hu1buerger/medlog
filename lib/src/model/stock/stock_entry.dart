
import 'package:json_annotation/json_annotation.dart';
import 'package:medlog/src/model/pharmaceutical/pharmaceutical.dart';

part 'stock_entry.g.dart';

/// Represents the current stock state
@JsonSerializable()
class StockEntry{

  /// the id of the parmaceutical that is logged as stock
  String pharmaceuticalID;

  late PharmaceuticalRef _pharmaceutical;

  Pharmaceutical get pharmaceutical => _pharmaceutical;
  set pharmaceutical(Pharmaceutical p){
    if(p.id_is_set == false || p.id != pharmaceuticalID) throw ArgumentError("wrong phramaceutical");
    _pharmaceutical = _pharmaceutical;
  }

  ///the amount of medication still available in this unit
  int amount;

  /// denotes wheter or not this unit is started or still closed
  StockState state;

  DateTime expiryDate;
  
  StockEntry(this.pharmaceuticalID, this.amount, this.state, this.expiryDate){
    if(amount <= 0) throw ArgumentError.value(amount, "amount", "amount violates the constraints [1,...]");
  }

  factory StockEntry.fromJson(Map<String, dynamic> json) => _$StockEntryFromJson(json);

  Map<String,dynamic> toJson() => _$StockEntryToJson(this);
}

enum StockState{
  close,
  open
}