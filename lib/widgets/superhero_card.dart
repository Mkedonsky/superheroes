import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:superheroes/blocs/main_bloc.dart';
import 'package:superheroes/pages/superhero_page.dart';
import 'package:superheroes/resources/superheroes_colors.dart';
import 'package:superheroes/resources/superheroes_images.dart';

class SuperheroCard extends StatelessWidget {
  final VoidCallback onTap;
  final SuperheroInfo superheroInfo;

  const SuperheroCard({
    Key? key,
    required this.onTap,
    required this.superheroInfo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _superheroesPageInfo(context, superheroInfo.name);
      },
      child: Container(
        height: 70,
        color: SuperheroesColors.backgroundSuperheroesCard,
        child: Row(
          children: [
            Container(
              color: Colors.white24,
              width: 70,
              height: 70,
              child: CachedNetworkImage(
                progressIndicatorBuilder: (context, url, progress) {
                  return Center(
                    child: CircularProgressIndicator(
                      value: progress.progress,
                      color: Color(0xFF00BCD4),
                    ),
                  );

                },
                errorWidget: (context, url, error) => Center(
                  child: Image.asset(
                    SuperheroesImages.unknownImage,
                    width: 20,
                    height: 62,
                  ),
                ),
                imageUrl: superheroInfo.imageUrl,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    superheroInfo.name.toUpperCase(),
                    style: TextStyle(
                      color: SuperheroesColors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    superheroInfo.realName,
                    style: TextStyle(
                      color: SuperheroesColors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

_superheroesPageInfo(context, _name) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => SuperheroPage(
        name: _name,
      ),
    ),
  );

}
