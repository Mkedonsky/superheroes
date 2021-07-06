import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:superheroes/pages/superhero_page.dart';
import 'package:superheroes/resources/superheroes_colors.dart';

class SuperheroCard extends StatelessWidget {
  final String name;
  final String realName;
  final String imageUrl;
  final VoidCallback onTap;

  const SuperheroCard({
    Key? key,
    required this.name,
    required this.realName,
    required this.imageUrl,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _superheroesPageInfo(context, name);
      },
      child: Container(
        height: 70,
        color: SuperheroesColors.backgroundSuperheroesCard,
        child: Row(
          children: [
            Image.network(imageUrl, width: 70, height: 70, fit: BoxFit.fill),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: 14),
                  Text(
                    name.toUpperCase(),
                    style: TextStyle(
                      color: SuperheroesColors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    realName.toUpperCase(),
                    style: TextStyle(
                      color: SuperheroesColors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 15),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

_superheroesPageInfo(context, name) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => SuperheroPage(
        name: name,
      ),
    ),
  );
}
