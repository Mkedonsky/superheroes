import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:superheroes/blocs/main_bloc.dart';
import 'package:superheroes/model/alignment_info.dart';
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
      onTap: onTap,
      // _superheroesPageInfo(context, superheroInfo.id);
      child: Container(
        height: 70,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: SuperheroesColors.backgroundSuperheroesCard,
        ),
        child: Row(
          children: [
            _AvatarWidget(superheroInfo: superheroInfo),
            const SizedBox(width: 12),
            NameAndRealNameWidget(superheroInfo: superheroInfo),
            if (superheroInfo.alignmentInfo != null)
              AlignmentWidget(alignmentInfo: superheroInfo.alignmentInfo!)
          ],
        ),
      ),
    );
  }
}

class AlignmentWidget extends StatelessWidget {
  final AlignmentInfo alignmentInfo;

  const AlignmentWidget({Key? key, required this.alignmentInfo})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: 1,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6),
        color: alignmentInfo.color,
        alignment: Alignment.center,
        child: Text(
          alignmentInfo.name.toUpperCase(),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 10,
          ),
        ),
      ),
    );
  }
}

class NameAndRealNameWidget extends StatelessWidget {
  const NameAndRealNameWidget({
    Key? key,
    required this.superheroInfo,
  }) : super(key: key);

  final SuperheroInfo superheroInfo;

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
    );
  }
}

class _AvatarWidget extends StatelessWidget {
  const _AvatarWidget({
    Key? key,
    required this.superheroInfo,
  }) : super(key: key);

  final SuperheroInfo superheroInfo;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white24,
      width: 70,
      height: 70,
      child: CachedNetworkImage(
        progressIndicatorBuilder: (context, url, progress) {
          return Container(
            alignment: Alignment.center,
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              value: progress.progress,
              color: SuperheroesColors.blue,
            ),
          );
        },
        errorWidget: (context, url, error) => Center(
          child: Image.asset(
            SuperheroesImages.unknownImage,
            width: 20,
            height: 62,
            fit: BoxFit.cover,
          ),
        ),
        imageUrl: superheroInfo.imageUrl,
        width: 70,
        height: 70,
        fit: BoxFit.cover,
      ),
    );
  }
}

_superheroesPageInfo(context, id) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => SuperheroPage(
        id: id,
      ),
    ),
  );
}
