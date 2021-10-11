import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;
import 'package:superheroes/exception/api_exception.dart';
import 'package:superheroes/favorite_superhero_storage.dart';
import 'package:superheroes/model/superhero.dart';

class SuperheroBloc {
  http.Client? client;
  final String id;

  final superheroSubject = BehaviorSubject<Superhero>();
  final superheroSubjectPageState = BehaviorSubject<SuperheroPageState>();

  StreamSubscription? getFromFavoritesSubscription;
  StreamSubscription? requestSubscription;
  StreamSubscription? addToFavoriteSubscription;
  StreamSubscription? removeFromFavoritesSubscription;

  SuperheroBloc({this.client, required this.id}) {
    getFromFavorites();
  }

  void getFromFavorites() {
    getFromFavoritesSubscription?.cancel();
    getFromFavoritesSubscription = FavoriteSuperheroesStorage.getInstance()
        .getSuperhero(id)
        .asStream()
        .listen(
      (superhero) {
        if (superhero != null) {
          superheroSubject.add(superhero);
          superheroSubjectPageState.add(SuperheroPageState.loaded);
        } else {
          superheroSubjectPageState.add(SuperheroPageState.loading);
        }
        requestSuperhero(superhero != null);
      },
      onError: (error, stackTrace) =>
          print("Error happened in addToFavorite: $error,$stackTrace "),
    );
  }

  void addToFavorite() {
    final superhero = superheroSubject.valueOrNull;
    if (superhero == null) {
      print("Error: superhero = null");
      return;
    }
    addToFavoriteSubscription?.cancel();
    addToFavoriteSubscription = FavoriteSuperheroesStorage.getInstance()
        .addToFavorites(superhero)
        .asStream()
        .listen(
      (event) {
        print("Added to favorites $event");
      },
      onError: (error, stackTrace) =>
          print("Error happened in addToFavorite: $error,$stackTrace "),
    );
  }

  void removeFromFavorites() {
    // final superhero = superheroSubject.valueOrNull;
    // if (superhero == null) {
    //   print("Error: superhero = null");
    //   return;
    // }
    removeFromFavoritesSubscription?.cancel();
    removeFromFavoritesSubscription = FavoriteSuperheroesStorage.getInstance()
        .removeFavorites(id)
        .asStream()
        .listen(
      (event) {
        print("Removed from favorites $event");
      },
      onError: (error, stackTrace) =>
          print("Error happened in removeFromFavorites: $error,$stackTrace "),
    );
  }

  Stream<bool> observeIsFavorite() =>
      FavoriteSuperheroesStorage.getInstance().observeIsFavorite(id);

  void requestSuperhero(final bool isInFavorites) {
    requestSubscription?.cancel();
    requestSubscription = request().asStream().listen(
      (superhero) {
        superheroSubject.add(superhero);
        superheroSubjectPageState.add(SuperheroPageState.loaded);
      },
      onError: (error, stackTrace) {
        if (!isInFavorites) {
          superheroSubjectPageState.add(SuperheroPageState.error);
        }
        print("Error happened in requestSuperhero: $error,$stackTrace ");
      },
    );
  }

  void retry() {
    superheroSubjectPageState.add(SuperheroPageState.loading);
    requestSuperhero(false);
  }

  Future<Superhero> request() async {
    final token = dotenv.env["SUPERHERO_TOKEN"];
    final response = await (client ??= http.Client())
        .get(Uri.parse("https://superheroapi.com/api/$token/$id"));
    if (response.statusCode >= 500 && response.statusCode <= 599) {
      throw ApiException("Server error happened");
    }
    if (response.statusCode >= 400 && response.statusCode <= 499) {
      throw ApiException("Client error happened");
    }
    final decoded = json.decode(response.body);
    if (decoded['response'] == 'success') {
      final superhero = Superhero.fromJson(decoded);
      await FavoriteSuperheroesStorage.getInstance()
          .updateIfInFavorites(superhero);
      return superhero;
    } else if (decoded['response'] == 'error') {
      throw ApiException("Client error happened");
    }
    throw ApiException("Unknown error happened");
  }

  Stream<Superhero> observeSuperhero() => superheroSubject.distinct();

  Stream<SuperheroPageState> observeSuperheroPageState() =>
      superheroSubjectPageState.distinct();

  void dispose() {
    client?.close();
    superheroSubject.close();
    requestSubscription?.cancel();
    addToFavoriteSubscription?.cancel();
    removeFromFavoritesSubscription?.cancel();
    getFromFavoritesSubscription?.cancel();
    superheroSubjectPageState.close();
  }
}

enum SuperheroPageState { loading, loaded, error }
