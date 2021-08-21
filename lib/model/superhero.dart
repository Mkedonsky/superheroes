import 'package:json_annotation/json_annotation.dart';
import 'package:superheroes/model/powerstats.dart';
import 'package:superheroes/model/server_image.dart';
import 'biography.dart';

part 'superhero.g.dart';

@JsonSerializable()
class Superhero {
  final String id;
  final String name;
  final Biography biography;
  final ServerImage image;
  final Powerstats powerstats;


  Superhero(this.name, this.biography, this.image, this.id, this.powerstats);

  factory Superhero.fromJson(final Map<String, dynamic> json) =>
      _$SuperheroFromJson(json);

  Map<String, dynamic> toJson() => _$SuperheroToJson(this);
}
