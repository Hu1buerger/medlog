import 'package:json_annotation/json_annotation.dart';

import 'dosage.dart';

part 'pharmaceutical.g.dart';

/// TODO: turn dosage into object for scaling and other manipulations
///   Pharmaceutical
///     - It contains a substance that is causing the treatment effect (including homeopathics)
///     - It is identified by an id. This can either be created on the client device and is denoted by the [DocumentState.user_created]
@JsonSerializable()
@DosageJsonConverter()
class Pharmaceutical {
  static const String emptyID = "";

  /// the id of this pharmaceutical
  @JsonKey(name: "id")
  String id;

  final DocumentState documentState;

  /// the name under which humans buy / know this medication
  // ignore: non_constant_identifier_names
  final String? human_known_name;

  /// the name under which the pharmaceutical gets marketed
  /// I.e. Ibuflam 400mg where "Ibuflam" is the tradename and "Ibuflam 400mg" is the name that humans use
  final String tradename;
  final Dosage dosage;
  final String? activeSubstance;

  /// the smallest unit one can take
  ///
  /// this would be = 0.5 if this pharmaceutical is halfable
  final double? _minUnit;
  double get smallestConsumableUnit => _minUnit ?? 0.25;

  /// the string to display for the user
  String get displayName => human_known_name ?? tradename;

  /// marks that this item has a id. this shall be valid
  bool get isIded => id.isNotEmpty;

  /// dont call me directly
  Pharmaceutical(
      {required this.tradename,
      required this.dosage,
      required this.activeSubstance,
      this.human_known_name,
      this.documentState = DocumentState.user_created,
      this.id = Pharmaceutical.emptyID,
      double? smallestConsumableUnit})
      : _minUnit = smallestConsumableUnit;

  factory Pharmaceutical.fromJson(Map<String, dynamic> json) => _$PharmaceuticalFromJson(json);

  Map<String, dynamic> toJson() {
    assert(isIded);
    var json = _$PharmaceuticalToJson(this);
    return json;
  }

  /// consider carefully if changing a value is a good idea
  Pharmaceutical cloneAndUpdate(
      {String? humanName,
      String? tradename,
      Dosage? dosage,
      String? activeSubstance,
      String? pzn,
      DocumentState? documentState,
      String? id,
      double? smallestPartialUnit}) {
    return Pharmaceutical(
        tradename: tradename ?? this.tradename,
        dosage: dosage ?? this.dosage,
        activeSubstance: activeSubstance ?? this.activeSubstance,
        // ignore: unnecessary_this
        human_known_name: humanName ?? this.human_known_name,
        documentState: documentState ?? this.documentState,
        id: id ?? this.id,
        smallestConsumableUnit: smallestPartialUnit ?? smallestConsumableUnit);
  }
}

class DosageJsonConverter extends JsonConverter<Dosage, String> {
  const DosageJsonConverter();

  @override
  Dosage fromJson(String json) => Dosage.parse(json);

  @override
  String toJson(Dosage object) => object.toString();
}

enum DocumentState {
  user_created,
  in_review,
  peer_reviewed,
  admin_reviewed,
}

extension ComparableDocumentState on DocumentState {
  //indicates that other has more administrative power to override the this
  bool isHeavier(DocumentState other) {
    return index > other.index;
  }
}
