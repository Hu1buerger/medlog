import 'package:json_annotation/json_annotation.dart';
import 'package:medlog/src/repo/pharmaceutical/pharmaceutical_repo.dart';
import 'package:medlog/src/model/log_entry/log_event.dart';
import 'package:medlog/src/model/pharmaceutical/dosage.dart';
import 'package:medlog/src/model/pharmaceutical/pharmaceutical.dart';

part 'medication_intake_event.g.dart';

@JsonSerializable(ignoreUnannotated: true)
class MedicationIntakeEvent extends LogEvent {
  @JsonKey()
  String pharmaceuticalID;

  Pharmaceutical? _pharmaceutical;

  /// how many of pharmaceutical have been ingested
  @JsonKey()
  double amount;

  /// Wheter the pharmaceutical has been taken from the stock
  @JsonKey()
  PharmaceuticalSource source;

  MedicationIntakeEvent(
      int id, DateTime eventTime, this.pharmaceuticalID, this.amount,
      {this.source = PharmaceuticalSource.other})
      : super(id, eventTime) {
    if (amount <= 0) throw ArgumentError.value(amount);
  }

  factory MedicationIntakeEvent.create(
      Pharmaceutical p, DateTime eventTime, double amount) {
    return MedicationIntakeEvent(LogEvent.unsetID, eventTime, p.id, amount,
        source: PharmaceuticalSource.other)
      ..pharmaceutical = p;
  }

  Pharmaceutical get pharmaceutical {
    return _pharmaceutical!;
  }

  set pharmaceutical(Pharmaceutical p) {
    //TODO: check for ID equality
    _pharmaceutical = p;
  }

  String get displayName => pharmaceutical.displayName;

  Dosage get dosage => pharmaceutical.dosage.scale(amount);

  String get activeSubstance => pharmaceutical.activeSubstance ?? "Unassigned";

  factory MedicationIntakeEvent.fromJson(Map<String, dynamic> json) =>
      _$MedicationIntakeEventFromJson(json);

  Map<String, dynamic> toJson() {
    pharmaceuticalID = _pharmaceutical?.id ?? pharmaceuticalID;

    return _$MedicationIntakeEventToJson(this);
  }

  @override
  bool rehydrate(PharmaceuticalRepo p) {
    var pharmaceutical = p.pharmaceuticalByID(pharmaceuticalID);
    if (pharmaceutical == null) {
      //throw StateError("couldnt rehydrate bcs the pharmaceutical with id couldnt be found");
      return false;
    }

    this.pharmaceutical = pharmaceutical;
    return true;
  }
}

enum PharmaceuticalSource { stock, other }
