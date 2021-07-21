import 'dart:async';

import 'package:rxdart/rxdart.dart';

class MainBloc {
  final minSymbols = 3;

  final BehaviorSubject<MainPageState> stateSubject = BehaviorSubject();
  final favoriteSuperheroesSubject = BehaviorSubject<List<SuperheroInfo>>();
  final searchSuperheroesSubject = BehaviorSubject<List<SuperheroInfo>>();
  final currentTextSubject = BehaviorSubject<String>.seeded("");

  StreamSubscription? textSubscription;
  StreamSubscription? searchSubscription;
  StreamSubscription? removeFavoriteSubscription;

  MainBloc() {
    stateSubject.add(MainPageState.noFavorites);

    textSubscription = currentTextSubject
        .distinct()
        .debounceTime(Duration(milliseconds: 200))
        .listen((value) {
      print("CHANGED: $value");
      searchSubscription?.cancel();
      if (value.isEmpty) {
        stateSubject.add(MainPageState.favorites);
      } else if (value.length < minSymbols) {
        stateSubject.add(MainPageState.minSymbols);
      } else {
        searchForSuperheroes(value);
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

  // void removeFavorite(){
  //
  //
  // }

  Stream<List<SuperheroInfo>> observeFavoritesSuperheroes() =>
      favoriteSuperheroesSubject;

  Stream<List<SuperheroInfo>> observeSearchSuperheroes() =>
      searchSuperheroesSubject;

  Future<List<SuperheroInfo>> search(final String text) async {
    await Future.delayed(Duration(seconds: 1));
    Iterable<SuperheroInfo> heroes = SuperheroInfo.mocked;
    heroes = heroes.where(
      (element) => element.name.contains(text),
    );
    return heroes.toList();
  }

  Stream<MainPageState> observeMainPageState() => stateSubject;

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
    favoriteSuperheroesSubject.close();
    currentTextSubject.close();
    textSubscription?.cancel();
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

class SuperheroInfo {
  final String name;
  final String realName;
  final String imageUrl;

  const SuperheroInfo({
    required this.name,
    required this.realName,
    required this.imageUrl,
  });

  @override
  String toString() {
    return 'SuperheroInfo{name: $name, realName: $realName, imageUrl: $imageUrl}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SuperheroInfo &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          realName == other.realName &&
          imageUrl == other.imageUrl;

  @override
  int get hashCode => name.hashCode ^ realName.hashCode ^ imageUrl.hashCode;

  static const mocked = [
    SuperheroInfo(
      name: "Batman",
      realName: "Bruce Wayne",
      imageUrl:
          'https://www.superherodb.com/pictures2/portraits/10/100/639.jpg',
    ),
    SuperheroInfo(
      name: "Ironman",
      realName: "Tony Stark",
      imageUrl: 'https://www.superherodb.com/pictures2/portraits/10/100/85.jpg',
    ),
    SuperheroInfo(
      name: "Venom",
      realName: "Eddie Brock",
      imageUrl: 'https://www.superherodb.com/pictures2/portraits/10/100/22.jpg',
    ),
  ];
}
