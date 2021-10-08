import 'package:json_annotation/json_annotation.dart';

part 'pharmaceutical.g.dart';

@JsonSerializable()
class Pharmaceutical {
  int id;

  final DocumentState documentState;

  final String human_known_name;
  final String tradename;
  final String dosage;
  final String? activeSubstance;
  final String? pzn;

  String get displayName => human_known_name;

  /// dont call me directly
  Pharmaceutical({
    required this.tradename,
    required this.dosage,
    required this.activeSubstance,
    String? human_known_name,
    this.pzn,
    this.documentState = DocumentState.user_created,
    this.id = -1}) : human_known_name = human_known_name ?? tradename;

  factory Pharmaceutical.fromJson(Map<String, dynamic> json) => _$PharmaceuticalFromJson(json);

  /// consider carefully if changing a value is a good idea
  Pharmaceutical cloneAndUpdate(
      {String? humanName, String? tradename, String? dosage, String? activeSubstance, String? pzn, DocumentState? documentState, int? id}) {

    return Pharmaceutical(
      tradename: tradename ?? this.tradename,
      dosage: dosage ?? this.dosage,
      activeSubstance: activeSubstance ?? this.activeSubstance,
      // ignore: unnecessary_this
      human_known_name: humanName ?? this.human_known_name,
      pzn: pzn ?? this.pzn,
      documentState: documentState ?? this.documentState,
      id: id ?? this.id
    );
  }

  Map<String, dynamic> toJson() => _$PharmaceuticalToJson(this);
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
  int get id => ref.id;

  @override
  set id(int value) => ref.id = value;

  @override
  DocumentState get documentState => ref.documentState;

  @override
  String? get activeSubstance => ref.activeSubstance;

  @override
  String get dosage => ref.dosage;

  @override
  String? get pzn => ref.pzn;

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
  Pharmaceutical cloneAndUpdate({String? humanName, String? tradename, String? dosage, String? activeSubstance, String? pzn, DocumentState? documentState, int? id}) {
    throw UnimplementedError();
  }
}
