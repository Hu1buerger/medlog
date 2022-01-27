import 'package:json_annotation/json_annotation.dart';

import 'dosage.dart';

part 'pharmaceutical.g.dart';

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

  @Deprecated("documentState versioning is just causing issues")
  final DocumentState documentState;

  /// the name under which the pharmaceutical gets marketed
  /// I.e. Ibuflam 400mg where "Ibuflam" is the tradename and "Ibuflam 400mg" is the name that humans use
  final String tradename;
  final Dosage dosage;

  final List<String> substances;

  /// the smallest unit one can take
  ///
  /// this would be = 0.5 if this pharmaceutical is halfable
  final double smallestDosageSize;

  /// the string to display for the user
  String get displayName => tradename;

  /// marks that this item has a id. this shall be valid
  bool get isIded => id.isNotEmpty;

  String? get displaySubstances {
    if (substances.isEmpty) return "";
    return (substances.fold(substances.first, (String previousValue, String element) => previousValue + ", " + element)
        as String);
  }

  /// dont call me directly
  Pharmaceutical(
      {this.id = Pharmaceutical.emptyID,
      required this.tradename,
      required this.dosage,
      this.substances = const [],
      this.documentState = DocumentState.user_created,
      this.smallestDosageSize = 1});

  factory Pharmaceutical.fromJson(Map<String, dynamic> json) => _$PharmaceuticalFromJson(json);

  Map<String, dynamic> toJson() {
    assert(isIded);
    var json = _$PharmaceuticalToJson(this);
    return json;
  }

  /// consider carefully if changing a value is a good idea
  Pharmaceutical cloneAndUpdate(
      {String? tradename, Dosage? dosage, List<String>? substances, String? id, double? smallestPartialUnit}) {
    return Pharmaceutical(
        tradename: tradename ?? this.tradename,
        dosage: dosage ?? this.dosage,
        substances: substances ?? this.substances,
        // ignore: unnecessary_this
        documentState: documentState,
        id: id ?? this.id,
        smallestDosageSize: smallestPartialUnit ?? smallestDosageSize);
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
