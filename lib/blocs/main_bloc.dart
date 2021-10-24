import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;
import 'package:superheroes/exception/api_exception.dart';
import 'package:superheroes/favorite_superheroes_storage.dart';
import 'package:superheroes/model/alignment_info.dart';
import 'package:superheroes/model/superhero.dart';

class MainBloc {
  final minSymbols = 3;

  final BehaviorSubject<MainPageState> stateSubject = BehaviorSubject();
  final searchSuperheroesSubject = BehaviorSubject<List<SuperheroInfo>>();
  final currentTextSubject = BehaviorSubject<String>.seeded("");

  StreamSubscription? textSubscription;
  StreamSubscription? searchSubscription;
  StreamSubscription? removeFromFavoritesSubscription;

  http.Client? client;

  MainBloc({this.client}) {
    textSubscription =
        Rx.combineLatest2<String, List<Superhero>, MainPageStateInfo>(
                currentTextSubject
                    .distinct()
                    .debounceTime(Duration(milliseconds: 500)),
                FavoriteSuperheroesStorage.getInstance()
                    .observeFavoriteSuperheroes(),
                (searchedText, favorites) =>
                    MainPageStateInfo(searchedText, favorites.isNotEmpty))
            .listen((value) {
      print("CHANGED: $value");
      searchSubscription?.cancel();
      if (value.searchedText.isEmpty) {
        if (value.haveFavorites) {
          stateSubject.add(MainPageState.favorites);
        } else {
          stateSubject.add(MainPageState.noFavorites);
        }
      } else if (value.searchedText.length < minSymbols) {
        stateSubject.add(MainPageState.minSymbols);
      } else {
        searchForSuperheroes(value.searchedText);
      }
    });
  }

  void searchForSuperheroes(final String text) {
    stateSubject.add(MainPageState.loading);
    searchSubscription = search(text).asStream().listen((searchResult) {
      if (searchResult.isEmpty) {
        stateSubject.add(MainPageState.nothingFound);
      } else {
        searchSuperheroesSubject.add(searchResult);
        stateSubject.add(MainPageState.searchResult);
      }
    }, onError: (error, stackTrace) {
      stateSubject.add(MainPageState.loadingError);
    });
  }

  void removeFromFavorites(final String id) {
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

  void retry() {
    final currentText = currentTextSubject.value;
    searchForSuperheroes(currentText);
  }

  Stream<List<SuperheroInfo>> observeFavoritesSuperheroes() =>
      FavoriteSuperheroesStorage.getInstance().observeFavoriteSuperheroes().map(
            (superheroes) => superheroes
                .map((superhero) => SuperheroInfo.fromSuperhero(superhero))
                .toList(),
          );

  Stream<List<SuperheroInfo>> observeSearchSuperheroes() =>
      searchSuperheroesSubject;

  Future<List<SuperheroInfo>> search(final String text) async {
    final token = dotenv.env["SUPERHERO_TOKEN"];
    final response = await (client ??= http.Client())
        .get(Uri.parse("https://superheroapi.com/api/$token/search/$text"));
    final decoded = json.decode(response.body);

    if (decoded['response'] == 'success') {
      final List<dynamic> results = decoded['results'];
      final List<Superhero> superheroes = results
          .map((rawSuperhero) => Superhero.fromJson(rawSuperhero))
          .toList();

      if (response.statusCode >= 400 && response.statusCode <= 499) {
        throw ApiException("Client error happened");
      }
      if (response.statusCode >= 500 && response.statusCode <= 599) {
        throw ApiException("Server error happened");
      }

      final List<SuperheroInfo> found = superheroes.map((superhero) {
        return SuperheroInfo.fromSuperhero(superhero);
      }).toList();
      return found;
    } else if (decoded['response'] == 'error') {
      if (decoded['error'] == "character with given name not found") {
        return [];
      }
      throw ApiException("Client error happened");
    }
    throw ApiException("Unknown error happened");
  }

  Stream<MainPageState> observeMainPageState() => stateSubject;

  // void removeFavorite() {
  //   print("Кнопка нажата remove");
  //   Iterable<SuperheroInfo>? favorites = favoriteSuperheroesSubject.value;
  //   if (favorites. isEmpty) {
  //     favoriteSuperheroesSubject.add(SuperheroInfo.mocked);
  //   } else {
  //     favoriteSuperheroesSubject
  //         .add(favorites.take(favorites.length - 1).toList());
  //   }
  // }

  void nextState() {
    final currentState = stateSubject.value;
    final nextState = MainPageState.values[
        (MainPageState.values.indexOf(currentState) + 1) %
            MainPageState.values.length];
    stateSubject.add(nextState);
  }

  void updateText(final String? text) {
    currentTextSubject.add(text ?? " ");
  }

  void dispose() {
    stateSubject.close();
    searchSuperheroesSubject.close();
    textSubscription?.cancel();
    currentTextSubject.close();
    textSubscription?.cancel();
    removeFromFavoritesSubscription?.cancel();
    client?.close();
  }
}

enum MainPageState {
  noFavorites,
  minSymbols,
  loading,
  nothingFound,
  loadingError,
  searchResult,
  favorites,
}

class MainPageStateInfo {
  final String searchedText;
  final bool haveFavorites;

  const MainPageStateInfo(this.searchedText, this.haveFavorites);

  @override
  String toString() {
    return 'MainPageStateInfo{searchText: $searchedText, haveFavorites: $haveFavorites}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MainPageStateInfo &&
          runtimeType == other.runtimeType &&
          searchedText == other.searchedText &&
          haveFavorites == other.haveFavorites;

  @override
  int get hashCode => searchedText.hashCode ^ haveFavorites.hashCode;
}

class SuperheroInfo {
  final String id;
  final String name;
  final String realName;
  final String imageUrl;
  final AlignmentInfo? alignmentInfo;

  const SuperheroInfo({
    required this.id,
    required this.name,
    required this.realName,
    required this.imageUrl,
    this.alignmentInfo,
  });

  factory SuperheroInfo.fromSuperhero(final Superhero superhero) {
    return SuperheroInfo(
      id: superhero.id,
      name: superhero.name,
      realName: superhero.biography.fullName,
      imageUrl: superhero.image.url,
      alignmentInfo:superhero.biography.alignmentInfo,
    );
  }

  @override
  String toString() {
    return 'SuperheroInfo{id: $id, name: $name, realName: $realName, imageUrl: $imageUrl}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SuperheroInfo &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          realName == other.realName &&
          imageUrl == other.imageUrl;

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ realName.hashCode ^ imageUrl.hashCode;

  static const mocked = [
    SuperheroInfo(
      id: "70",
      name: "Batman",
      realName: "Bruce Wayne",
      imageUrl:
          'https://www.superherodb.com/pictures2/portraits/10/100/639.jpg',
    ),
    SuperheroInfo(
      id: "732",
      name: "Ironman",
      realName: "Tony Stark",
      imageUrl: 'https://www.superherodb.com/pictures2/portraits/10/100/85.jpg',
    ),
    SuperheroInfo(
      id: "687",
      name: "Venom",
      realName: "Eddie Brock",
      imageUrl: 'https://www.superherodb.com/pictures2/portraits/10/100/22.jpg',
    ),
  ];
}
