import 'package:json_annotation/json_annotation.dart';

part 'pharmaceutical.g.dart';

///   Pharmaceutical
///     - It contains a substance that is causing the treatment effect (including homeopathics)
///     - It is identified by an id. This can either be created on the client device and is denoted by the [DocumentState.user_created]
@JsonSerializable()
class Pharmaceutical {
  static const String emptyID = "";

  String id;

  final DocumentState documentState;

  // ignore: non_constant_identifier_names
  final String human_known_name;
  final String tradename;
  final String dosage;
  final String? activeSubstance;

  String get displayName => human_known_name;
  bool get id_is_set => id.isNotEmpty;

  /// dont call me directly
  Pharmaceutical(
      {required this.tradename,
      required this.dosage,
      required this.activeSubstance,
      String? human_known_name,
      this.documentState = DocumentState.user_created,
        // dont use emptyID here bcs JsonSerializable cannot handle it rn see https://github.com/google/json_serializable.dart/issues/994
      this.id = ""})
      : human_known_name = human_known_name ?? tradename;

  factory Pharmaceutical.fromJson(Map<String, dynamic> json) => _$PharmaceuticalFromJson(json);

  /// consider carefully if changing a value is a good idea
  Pharmaceutical cloneAndUpdate(
      {String? humanName,
      String? tradename,
      String? dosage,
      String? activeSubstance,
      String? pzn,
      DocumentState? documentState,
      String? id}) {
    return Pharmaceutical(
        tradename: tradename ?? this.tradename,
        dosage: dosage ?? this.dosage,
        activeSubstance: activeSubstance ?? this.activeSubstance,
        // ignore: unnecessary_this
        human_known_name: humanName ?? this.human_known_name,
        documentState: documentState ?? this.documentState,
        id: id ?? this.id);
  }

  Map<String, dynamic> toJson() {
    assert(id_is_set);
    return _$PharmaceuticalToJson(this);
  }
}

enum DocumentState {
  user_created,
  in_review,
  peer_reviewed,
  admin_reviewed,
}

class PharmaceuticalRef implements Pharmaceutical {
  bool registered = false;
  Pharmaceutical ref;

  @override
  String get id => ref.id;

  @override
  set id(value) => ref.id = value;

  @override
  bool get id_is_set => ref.id_is_set;

  @override
  DocumentState get documentState => ref.documentState;

  @override
  String? get activeSubstance => ref.activeSubstance;

  @override
  String get dosage => ref.dosage;

  @override
  String get human_known_name => ref.human_known_name;

  @override
  String get tradename => ref.tradename;

  @override
  String get displayName => ref.displayName;

  @override
  Map<String, dynamic> toJson() => ref.toJson();

  PharmaceuticalRef(this.ref);

  @override
  Pharmaceutical cloneAndUpdate(
      {String? humanName,
      String? tradename,
      String? dosage,
      String? activeSubstance,
      String? pzn,
      DocumentState? documentState,
      String? id}) {
    throw UnimplementedError();
  }
}
