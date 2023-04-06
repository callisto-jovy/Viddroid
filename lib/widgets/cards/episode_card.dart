import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../util/capsules/fetch.dart';

class EpisodeCard extends StatelessWidget {
  final Episode _episode;

  const EpisodeCard(this._episode, {Key? key}) : super(key: key);

  Widget _buildErrorImage() {
    return const Image(
      image: AssetImage('images/ep-no-thumb.jpg'),
      alignment: Alignment.center,
      height: double.infinity,
      width: double.infinity,
      fit: BoxFit.cover,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width * 0.3,
      height: size.height * 0.2,
      child: Card(
        semanticContainer: true,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _episode.thumbnail == null || _episode.thumbnail!.isEmpty
                  ? _buildErrorImage()
                  : CachedNetworkImage(
                      imageUrl: _episode.thumbnail!,
                      progressIndicatorBuilder: (context, url, downloadProgress) =>
                          CircularProgressIndicator(value: downloadProgress.progress),
                      errorWidget: (context, url, error) => _buildErrorImage(),
                      imageBuilder: (context, imageProvider) => Image(
                          image: imageProvider,
                          alignment: Alignment.center,
                          height: double.infinity,
                          width: double.infinity,
                          fit: BoxFit.cover),
                      filterQuality: FilterQuality.medium),
            ),
            Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Text('Episode ${_episode.index}',
                    style: const TextStyle(fontWeight: FontWeight.w400))),
            Padding(
              padding: const EdgeInsets.all(5),
              child: Text(_episode.name,
                  softWrap: true, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
