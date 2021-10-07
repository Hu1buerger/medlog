import 'package:json_annotation/json_annotation.dart';

part 'pharmaceutical.g.dart';

@JsonSerializable()
class Pharmaceutical {
  int id;

  final DocumentState documentState;

  final String tradename;
  final String dosage;
  final String? activeIngredient;
  final String? pzn;

  /// dont call me directly
  Pharmaceutical(this.documentState, this.tradename, this.dosage, this.activeIngredient, {this.pzn,this.id = -1});

  factory Pharmaceutical.fromJson(Map<String,dynamic> json) => _$PharmaceuticalFromJson(json);
  Map<String, dynamic> toJson() => _$PharmaceuticalToJson(this);
}

enum DocumentState{
  user_created,
  in_review,
  peer_reviewed,
  admin_reviewed,
}