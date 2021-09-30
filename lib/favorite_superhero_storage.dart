import 'dart:convert';

import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:superheroes/model/superhero.dart';

class FavoriteSuperheroesStorage {
  static const _key = "favorite_superheroes";
  final updater = PublishSubject<Null>();
  static FavoriteSuperheroesStorage? _instance;

  factory FavoriteSuperheroesStorage.getInstance() =>
      _instance ??= FavoriteSuperheroesStorage._internal();
  FavoriteSuperheroesStorage._internal();

  Future<bool> addToFavorites(final Superhero superhero) async {
    final rawSuperheroes = await _getRowSuperheroes();
    rawSuperheroes.add(json.encode(superhero.toJson()));
    return _setRawSuperheroes(rawSuperheroes);
  }

  Future<bool> removeFavorites(final String id) async {
    final superheroes = await _getSuperheroes();
    superheroes.removeWhere((superhero) => superhero.id == id);
    return _setSuperheroes(superheroes);
  }

  Future<List<String>> _getRowSuperheroes() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getStringList(_key) ?? [];
  }

  Future<bool> _setRawSuperheroes(final List<String> rawSuperheroes) async {
    final sp = await SharedPreferences.getInstance();
    final result = sp.setStringList(_key, rawSuperheroes);
    updater.add(null);
    return result;
  }

  Future<List<Superhero>> _getSuperheroes() async {
    final rawSuperheroes = await _getRowSuperheroes();
    return rawSuperheroes
        .map(
            (rawSuperheroes) => Superhero.fromJson(json.decode(rawSuperheroes)))
        .toList();
  }

  Future<bool> _setSuperheroes(final List<Superhero> superheroes) async {
    final rawSuperheroes = superheroes
        .map((superhero) => json.encode(superhero.toJson()))
        .toList();
    return _setRawSuperheroes(rawSuperheroes);
  }

  Future<Superhero?> getSuperhero(final String id) async {
    final superheroes = await _getSuperheroes();
    for (final superhero in superheroes) {
      if (superhero.id == id) {
        return superhero;
      }
    }
    return null;
  }

  Stream<List<Superhero>> observeFavoriteSuperheroes() async* {
    yield await _getSuperheroes();
    await for (final _ in updater) {
      yield await _getSuperheroes();
    }
  }

  Stream<bool> observeIsFavorite(final String id) {
    return observeFavoriteSuperheroes().map((superheroes) =>
        superheroes.any((superhero) => superhero.id == id));
  }
}
