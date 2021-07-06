import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:superheroes/blocs/main_bloc.dart';
import 'package:superheroes/resources/superheroes_colors.dart';
import 'package:superheroes/resources/superheroes_images.dart';
import 'package:superheroes/widgets/action_button.dart';
import 'package:superheroes/widgets/info_with_button.dart';
import 'package:superheroes/widgets/superhero_card.dart';

class MainPage extends StatefulWidget {
  MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

// class MainBlocHolder extends InheritedWidget {
//   final MainBloc bloc;
//
//   MainBlocHolder({required this.bloc, required final Widget child})
//       : super(child: child);
//
//   @override
//   bool updateShouldNotify(MainBlocHolder oldWidget) => false;
//
//   static MainBlocHolder of(final BuildContext context) {
//     final InheritedElement element =
//         context.getElementForInheritedWidgetOfExactType<MainBlocHolder>()!;
//     return element.widget as MainBlocHolder ;
//   }
// }

class _MainPageState extends State<MainPage> {
  final MainBloc bloc = MainBloc();

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: bloc,
      child: Scaffold(
        backgroundColor: SuperheroesColors.background,
        body: SafeArea(
          child: MainPageContent(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }
}

class MainPageContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final MainBloc bloc = Provider.of<MainBloc>(context);

    return Stack(
      children: [
        MainPageStateWidget(),
        Align(
            alignment: Alignment.bottomCenter,
            child: ActionButton(
              text: "Next state",
              onTap: () => bloc.nextState(),
            ))
      ],
    );
  }
}

class MainPageStateWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final MainBloc bloc = Provider.of<MainBloc>(context);

    return StreamBuilder<MainPageState>(
      stream: bloc.observeMainPageState(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox();
        }
        final MainPageState state = snapshot.data!;
        switch (state) {
          case MainPageState.loading:
            return LoadingIndicator();
          case MainPageState.noFavorites:
            return NoFavoritesWidget();
          case MainPageState.minSymbols:
            return MinSymbolsWidget();
          case MainPageState.nothingFound:
            return NothingFoundWidget();
          case MainPageState.loadingError:
            return LoadingErrorWidget();
          case MainPageState.searchResult:
            return SearchResultWidget();
          case MainPageState.favorites:
            return FavoritesWidget();
          default:
        }
        return Center(
          child: Text(
            state.toString(),
            style: TextStyle(color: SuperheroesColors.white),
          ),
        );
      },
    );
  }
}

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.only(top: 110),
        child: CircularProgressIndicator(
          color: SuperheroesColors.blue,
          strokeWidth: 4,
        ),
      ),
    );
  }
}

class NoFavoritesWidget extends StatelessWidget {
  const NoFavoritesWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: InfoWithButton(
            title: 'No favorites yet',
            subtitle: 'Search and add',
            imageTopPadding: 174,
            imageWidth: 108,
            imageHeight: 119,
            assetImage: SuperheroesImages.ironManImage,
            buttonText: 'Search',
          ),
        ),
      ],
    );
  }
}

class MinSymbolsWidget extends StatelessWidget {
  const MinSymbolsWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        margin: EdgeInsets.only(top: 110),
        child: Text(
          "Enter at least 3 symbols",
          style: TextStyle(
            color: SuperheroesColors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}

class NothingFoundWidget extends StatelessWidget {
  const NothingFoundWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: InfoWithButton(
            title: 'Nothing found',
            subtitle: 'Search for something else',
            imageTopPadding: 180,
            imageWidth: 84,
            imageHeight: 112,
            assetImage: SuperheroesImages.hulkImage,
            buttonText: 'Search',
          ),
        ),
      ],
    );
  }
}

class LoadingErrorWidget extends StatelessWidget {
  const LoadingErrorWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: InfoWithButton(
            title: 'Error happened',
            subtitle: 'Please, try again',
            imageTopPadding: 186,
            imageWidth: 126,
            imageHeight: 106,
            assetImage: SuperheroesImages.supermanImage,
            buttonText: 'Retry',
          ),
        ),
      ],
    );
  }
}

class FavoritesWidget extends StatelessWidget {
  const FavoritesWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 90),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            alignment: Alignment.centerLeft,
            child: Text(
              "Your favorites",
              style: TextStyle(
                color: SuperheroesColors.white,
                fontWeight: FontWeight.w800,
                fontSize: 24,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SuperheroCard(
            name: "Batman",
            realName: "Bruce Wayne",
            imageUrl:
                'https://www.superherodb.com/pictures2/portraits/10/100/639.jpg',
            onTap: () {},
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SuperheroCard(
            name: "Ironman",
            realName: "Tony Stark",
            imageUrl:
                'https://www.superherodb.com/pictures2/portraits/10/100/85.jpg',
            onTap: () {},
          ),
        ),
      ],
    );
  }
}

class SearchResultWidget extends StatelessWidget {
  const SearchResultWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 90),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            alignment: Alignment.centerLeft,
            child: Text(
              "Search results",
              style: TextStyle(
                color: SuperheroesColors.white,
                fontWeight: FontWeight.w800,
                fontSize: 24,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SuperheroCard(
            name: "Batman",
            realName: "Bruce Wayne",
            imageUrl:
                'https://www.superherodb.com/pictures2/portraits/10/100/639.jpg',
            onTap: () {},
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SuperheroCard(
            name: "Venom",
            realName: "Eddie Brock",
            imageUrl:
                'https://www.superherodb.com/pictures2/portraits/10/100/22.jpg',
            onTap: () {},
          ),
        ),
      ],
    );
  }
}
