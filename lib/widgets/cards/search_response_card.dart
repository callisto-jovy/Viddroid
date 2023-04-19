import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:viddroid/provider/providers.dart';
import 'package:viddroid/util/capsules/search.dart';
import 'package:viddroid/views/watchable_view.dart';

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
        child: Container(
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(10)),
          child: Column(
            children: [
              _searchResponse.thumbnail == null
                  ? const Icon(Icons.question_mark_rounded)
                  : Expanded(
                      child: CachedNetworkImage(
                        imageUrl: _searchResponse.thumbnail!,
                        progressIndicatorBuilder: (context, url, downloadProgress) =>
                            CircularProgressIndicator(value: downloadProgress.progress),
                        imageBuilder: (context, imageProvider) {
                          return Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12.withOpacity(0.5),
                                    spreadRadius: 2,
                                    blurRadius: 7,
                                    offset: const Offset(0, 6),
                                  )
                                ],
                              ),
                              child: Image(
                                image: imageProvider,
                                filterQuality: FilterQuality.medium,
                                fit: BoxFit.scaleDown,
                              ));
                        },
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                      ),
                    ),
              Text(
                _searchResponse.title,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              Text(_searchResponse.type.name.toUpperCase()),
            ],
          ),
        ),
      ),
    );
  }
}
