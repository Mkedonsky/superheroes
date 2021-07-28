import 'package:json_annotation/json_annotation.dart';

part 'powerstats.g.dart';

@JsonSerializable(fieldRename: FieldRename.kebab,explicitToJson: true)
class Powerstats{
  String intelligence;
  String strength;
  String speed;
  String durability;
  String power;
  String combat;

  Powerstats(this.intelligence, this.strength, this.speed, this.durability,
      this.power, this.combat);

  factory Powerstats.fromJson(final Map<String, dynamic> json) =>
      _$PowerstatsFromJson(json);

  Map<String,dynamic> toJson() =>_$PowerstatsToJson(this) ;

}