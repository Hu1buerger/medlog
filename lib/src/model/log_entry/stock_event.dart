import 'package:json_annotation/json_annotation.dart';
import 'package:medlog/src/controller/pharmaceutical/pharmaceutical_controller.dart';
import 'package:medlog/src/model/log_entry/log_event.dart';
import 'package:medlog/src/model/pharmaceutical/pharmaceutical.dart';
import 'package:medlog/src/model/stock/stock_entry.dart';

part 'stock_event.g.dart';

/// an entry in the log related with a change in stock
///
/// This event logs removal or addition of medication
/// This is only used if the change is not from taking a medication
@JsonSerializable(ignoreUnannotated: true)
class StockEvent extends LogEvent {
  @JsonKey()

  /// the id of the pharmaceutical that has been restocked
  String pharmaceuticalID;

  Pharmaceutical? _pharmaceutical;

  Pharmaceutical get pharmaceutical {
    if (_pharmaceutical == null) throw StateError("this item needs to be loaded fully, but isnt");
    return _pharmaceutical!;
  }

  set pharmaceutical(Pharmaceutical p) {
    //TODO: check for the right pharmaceutical...
    _pharmaceutical = p;
  }

  @JsonKey()

  /// the delta of stockChanges
  double amount;

  StockEvent(int id, DateTime eventTime, this.pharmaceuticalID, this.amount) : super(id, eventTime);

  factory StockEvent.create(DateTime eventTime, Pharmaceutical p, double amount) {
    assert(amount != 0);

    return StockEvent(LogEvent.unsetID, eventTime, p.id, amount)..pharmaceutical = p;
  }

  factory StockEvent.restock(DateTime eventTime, StockItem item) {
    assert(item.amount > 0);

    return StockEvent.create(eventTime, item.pharmaceutical, item.amount);
  }

  factory StockEvent.fromJson(Map<String, dynamic> json) => _$StockEventFromJson(json);

  Map<String, dynamic> toJson() {
    pharmaceuticalID = _pharmaceutical?.id ?? pharmaceuticalID;

    return _$StockEventToJson(this);
  }

  @override
  bool rehydrate(PharmaceuticalController pc) {
    var pharmaceutical = pc.pharmaceuticalByID(pharmaceuticalID);
    if (pharmaceutical == null) {
      //throw StateError("couldnt rehydrate bcs the pharmaceutical with id couldnt be found");
      return false;
    }

    this.pharmaceutical = pharmaceutical;
    return true;
  }
}
