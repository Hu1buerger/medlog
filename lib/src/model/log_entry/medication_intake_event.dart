import 'package:json_annotation/json_annotation.dart';
import 'package:medlog/src/controller/pharmaceutical/pharmaceutical_controller.dart';
import 'package:medlog/src/model/log_entry/log_event.dart';
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

  MedicationIntakeEvent(int id, DateTime eventTime, this.pharmaceuticalID, this.amount) : super(id, eventTime);

  factory MedicationIntakeEvent.create(int id, DateTime eventTime, Pharmaceutical p, double amount){
    return MedicationIntakeEvent(id, eventTime, p.id, amount)
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

  String get dosage => pharmaceutical.dosage;

  String get activeSubstance => pharmaceutical.activeSubstance ?? "Unassigned";

  factory MedicationIntakeEvent.fromJson(Map<String, dynamic> json) => _$MedicationIntakeEventFromJson(json);

  Map<String, dynamic> toJson() {
    pharmaceuticalID = _pharmaceutical?.id ?? pharmaceuticalID;

    return _$MedicationIntakeEventToJson(this);
  }

  bool rehydrate(PharmaceuticalController p){
    var pharmaceutical = p.pharmaceuticalByID(pharmaceuticalID);
    if(pharmaceutical == null) {
      //throw StateError("couldnt rehydrate bcs the pharmaceutical with id couldnt be found");
      return false;
    }

    this.pharmaceutical = pharmaceutical;
    return true;
  }
}
