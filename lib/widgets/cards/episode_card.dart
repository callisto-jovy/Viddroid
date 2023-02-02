import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:viddroid_flutter_desktop/watchable/episode.dart';

class EpisodeCard extends StatelessWidget {
  final Episode _episode;

  const EpisodeCard(this._episode, {Key? key}) : super(key: key);

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
              child: _episode.thumbnail == null
                  ? Image.asset(
                      "images/ep-no-thumb.jpg",
                      fit: BoxFit.fill,
                    )
                  : CachedNetworkImage(
                      imageUrl: _episode.thumbnail!,
                      progressIndicatorBuilder: (context, url, downloadProgress) =>
                          CircularProgressIndicator(value: downloadProgress.progress),
                      errorWidget: (context, url, error) => Image.asset(
                        "ep-no-thumb.jpg",
                        fit: BoxFit.fill,
                      ),
                      fit: BoxFit.fill,
                      filterQuality: FilterQuality.medium),
            ),
            Text('Episode ${_episode.index}',
                style: const TextStyle(fontWeight: FontWeight.w400)),
            Text(_episode.name,
                softWrap: true, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
