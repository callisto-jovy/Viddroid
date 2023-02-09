import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:viddroid_flutter_desktop/provider/providers.dart';
import 'package:viddroid_flutter_desktop/util/capsules/search.dart';
import 'package:viddroid_flutter_desktop/views/watchable_view.dart';

class SearchResponseCard extends StatelessWidget {
  final SearchResponse _searchResponse;

  const SearchResponseCard(this._searchResponse, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: () {
          //Fetch data and navigate
          Providers().fetch(_searchResponse).then((value) => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WatchableView(value),
                ),
              ));
        },
        child: Column(
          children: [
            Expanded(
              child: _searchResponse.thumbnail == null
                  ? const Icon(Icons.error)
                  : CachedNetworkImage(
                      imageUrl: _searchResponse.thumbnail!,
                      progressIndicatorBuilder: (context, url, downloadProgress) =>
                          CircularProgressIndicator(value: downloadProgress.progress),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.medium),
            ),
            Text(
              _searchResponse.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(_searchResponse.type.name.toUpperCase()),
          ],
        ),
      ),
    );
  }
}
