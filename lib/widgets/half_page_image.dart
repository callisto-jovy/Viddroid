import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class HalfPageImage extends StatelessWidget {
  final String tag;
  final String? imageURL;
  final Map<String, String>? headers;

  const HalfPageImage({super.key, required this.tag, required this.imageURL, this.headers});

  Widget _buildImage(BuildContext context) {
    return imageURL == null
        ? Container(color: Theme.of(context).colorScheme.surface)
        : CachedNetworkImage(
            imageUrl: imageURL!,
            httpHeaders: headers,
            errorWidget: (context, url, error) =>
                Container(color: Theme.of(context).colorScheme.surface),
            progressIndicatorBuilder: (context, url, downloadProgress) =>
                CircularProgressIndicator(value: downloadProgress.progress),
            imageBuilder: (context, imageProvider) => _cachedImageBuilder(imageProvider),
          );
  }

  Widget _cachedImageBuilder(ImageProvider imageProvider) {
    return ClipRRect(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5, tileMode: TileMode.mirror),
        child: ColorFiltered(
          colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.2), BlendMode.dstATop),
          child: Image(
            image: imageProvider,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Hero(
      tag: tag,
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: _buildImage(context),
      ),
    );
  }
}
