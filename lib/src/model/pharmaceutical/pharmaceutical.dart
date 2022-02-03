import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

import 'dosage.dart';

part 'pharmaceutical.g.dart';

///   Pharmaceutical
///     - It contains a substance that is causing the treatment effect (including homeopathics)
///     - It is identified by an id. This can either be created on the client device and is denoted by the [DocumentState.user_created]
@JsonSerializable()
@DosageJsonConverter()
@DateTimeConverter()
class Pharmaceutical {
  static const String emptyID = "";

  /// dont call me directly
  Pharmaceutical({
    this.id = Pharmaceutical.emptyID,
    this.source,
    required this.tradename,
    required this.dosage,
    this.smallestDosageSize = 1,
    required this.changeTime,
    this.substances = const [],
  });

  factory Pharmaceutical.fromJson(Map<String, dynamic> json) => _$PharmaceuticalFromJson(json);

  factory Pharmaceutical.create(
      {String id = "",
      required String tradename,
      required Dosage dosage,
      Uri? source,
      DateTime? changeTime,
      List<String> substances = const [],
      double smallestDosageSize = 1}) {
    return Pharmaceutical(
        id: id,
        source: source,
        tradename: tradename,
        dosage: dosage,
        changeTime: changeTime ?? DateTime.now(),
        substances: substances,
        smallestDosageSize: smallestDosageSize);
  }

  /// the id of this pharmaceutical
  @JsonKey(name: "id")
  String id;

  final Uri? source;

  @JsonKey(ignore: true)
  @Deprecated("documentState versioning is just causing issues")
  final DocumentState documentState = DocumentState.user_created;

  final DateTime changeTime;

  /// the name that is used by the manufacturer to identify this item
  final String tradename;
  final Dosage dosage;

  /// the smallest unit one can take
  ///
  /// this would be = 0.5 if this pharmaceutical is halfable
  final double smallestDosageSize;

  final List<String> substances;

  /// the string to display for the user
  String get displayName => tradename;

  /// marks that this item has a id. this shall be valid
  bool get isIded => id.isNotEmpty;

  String? get displaySubstances {
    if (substances.isEmpty) return null;

    String displayString = substances.first;
    for (int i = 1; i < substances.length; i++) {
      displayString += ", ${substances[i]}";
    }

    return displayString;
  }

  Map<String, dynamic> toJson() {
    assert(isIded);
    var json = _$PharmaceuticalToJson(this);
    return json;
  }

  /// consider carefully if changing a value is a good idea
  Pharmaceutical cloneAndUpdate(
      {String? tradename,
      Dosage? dosage,
      List<String>? substances,
      String? id,
      double? smallestPartialUnit,
      DateTime? changeTime}) {
    assert(changeTime == null || DateTime.now().isAfter(changeTime));

    return Pharmaceutical(
        id: id ?? this.id,
        changeTime: changeTime ?? this.changeTime,
        tradename: tradename ?? this.tradename,
        dosage: dosage ?? this.dosage,
        substances: substances ?? this.substances,
        smallestDosageSize: smallestPartialUnit ?? smallestDosageSize);
  }

  static String newUUID() => const Uuid().v4();
}

class DosageJsonConverter extends JsonConverter<Dosage, String> {
  const DosageJsonConverter();

  @override
  Dosage fromJson(String json) => Dosage.parse(json);

  @override
  String toJson(Dosage object) => object.toString();
}

class DateTimeConverter extends JsonConverter<DateTime, String> {
  const DateTimeConverter();

  @override
  DateTime fromJson(String json) => DateTime.parse(json).toLocal();

  @override
  String toJson(DateTime object) => object.toUtc().toIso8601String();
}

enum DocumentState {
  user_created,
  in_review,
  peer_reviewed,
  admin_reviewed,
}

/// classification of a pharmaceutical as per german law
/// this should be extended to other places
///
/// this is a bitwise flag see for more:
/// https://github.com/dart-lang/sdk/issues/33698#issuecomment-773285584
class PharmaceuticalProperty {
  static const int LARGEST_FLAG = GENERIC << 1;

  static const int ARZNEIMITTEL = 1 << 0;
  static const int APOTHEKENPFLICHTIG = 1 << 1;
  static const int BTM = 1 << 2;
  static const int DOPING_LISTE = 1 << 3;
  static const int FIKTIV_ZUGELASSEN = 1 << 4;
  static const int PRISCUS_ITEM = 1 << 5;
  static const int CAVE_GRAVIDITAS = 1 << 6;
  static const int HOMOEOPATHIC = 1 << 7;
  static const int REZEPTPFLICHTIG = 1 << 8;
  static const int GENERIC = 1 << 9;

  PharmaceuticalProperty(int bitfield) {
    if (bitfield >= 0 && bitfield <= LARGEST_FLAG) {
      throw ArgumentError.value(bitfield, "Is invalid");
    }
    _bitfield = bitfield;
  }

  int _bitfield = 0;

  int get value => _bitfield;

  validFlag(int flag) {
    assert(flag >= 0 && flag <= LARGEST_FLAG);
  }

  setFlag(int flag) {
    validFlag(flag);
    _bitfield |= flag;
  }

  unsetFlag(int flag) {
    validFlag(flag);
    _bitfield |= ~flag;
  }

  isFlagSet(int flag) {
    validFlag(flag);
    return _bitfield & flag > 0;
  }

  String enumerateFlags() {
    const Map<int, String> flags = {
      ARZNEIMITTEL: "ARZNEIMITTEL",
      APOTHEKENPFLICHTIG: "APOTHEKENPFLICHTIG",
      BTM: "BTM",
      DOPING_LISTE: "DOPING_LISTE",
      FIKTIV_ZUGELASSEN: "FIKTIV_ZUGELASSEN",
      PRISCUS_ITEM: "PRISCUS_ITEM",
      CAVE_GRAVIDITAS: "CAVE_GRAVIDITAS",
      HOMOEOPATHIC: "HOMOEOPATHIC",
      REZEPTPFLICHTIG: "REZEPTPFLICHTIG",
      GENERIC: "GENERIC",
    };

    String result = "";
    for (final possibleFlag in flags.keys) {
      if (isFlagSet(possibleFlag)) {
        if (result.isNotEmpty) {
          result += ",";
        }
        result += flags[possibleFlag]!;
      }
    }

    return result;
  }
}
