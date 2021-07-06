import 'package:flutter/cupertino.dart';
import 'package:superheroes/resources/superheroes_colors.dart';

import 'action_button.dart';

class InfoWithButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonText;
  final String assetImage;
  final double imageHeight;
  final double imageWidth;
  final double imageTopPadding;

  const InfoWithButton({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.assetImage,
    required this.imageHeight,
    required this.imageWidth,
    required this.imageTopPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,

      children: [
        Padding(
          padding: const EdgeInsets.only(top: 165),
          child: Container(
            height: 108,
            width: 108,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: SuperheroesColors.blue,
              ),
            ),
          ),
        ),
        Padding(
          padding:  EdgeInsets.only(top: imageTopPadding),
          child: Image.asset(
            assetImage,
            width: imageWidth,
            height: imageHeight,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 313),
          child: Text(
            title,
            style: TextStyle(
                color: SuperheroesColors.white,
                fontSize: 32,
                fontWeight: FontWeight.w800),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 368),
          child: Text(
            subtitle.toUpperCase(),
            style: TextStyle(
                color: SuperheroesColors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.only(top: 414),
          child: ActionButton(
            text: buttonText,
            onTap: () {},
          ),
        ),
      ],
    );
  }
}
