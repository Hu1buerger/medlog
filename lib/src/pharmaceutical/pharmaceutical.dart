import 'package:json_annotation/json_annotation.dart';

part 'pharmaceutical.g.dart';

@JsonSerializable()
class Pharmaceutical {
  final String pzn;
  final String tradename;
  final String activeIngredient;
  final String dosage;

  /// dont call me directly
  Pharmaceutical(this.tradename, this.dosage, {this.pzn = "UNASSIGNED", this.activeIngredient = "UNASSIGNED"});

  factory Pharmaceutical.fromJson(Map<String,dynamic> json) => _$PharmaceuticalFromJson(json);
  Map<String, dynamic> toJson() => _$PharmaceuticalToJson(this);
}
