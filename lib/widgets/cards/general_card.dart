import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class GeneralPurposeCard extends StatelessWidget {
  final String title;
  final String? lowerCaption;

  final String? thumbnail;

  final Function onTap;

  const GeneralPurposeCard(
      {Key? key, required this.title, this.lowerCaption, this.thumbnail, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: () => onTap.call(),
        child: Card(
          semanticContainer: true,
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Expanded(
                child: CachedNetworkImage(
                    imageUrl: thumbnail ?? 'null',
                    progressIndicatorBuilder: (context, url, downloadProgress) =>
                        CircularProgressIndicator(value: downloadProgress.progress),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                    fit: BoxFit.scaleDown),
              ),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              )
            ],
          ),
        ),
      ),
    );
  }
}
