import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:viddroid_flutter_desktop/util/capsules/fetch.dart';

import '../widgets/half_page_image.dart';
import '../widgets/movie_widget.dart';
import '../widgets/tv_widget.dart';

class WatchableView extends StatefulWidget {
  final FetchResponse _fetchResponse;

  const WatchableView(this._fetchResponse, {Key? key}) : super(key: key);

  @override
  State<WatchableView> createState() => _WatchableViewState();
}

class _WatchableViewState extends State<WatchableView> {
  Widget _buildTitleText() {
    return Flexible(
      child: Text(
        widget._fetchResponse.title,
        softWrap: true,
        maxLines: 1,
        style: const TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  //TODO: Image shadow
  Widget _buildThumbnail() {
    return widget._fetchResponse.thumbnail == null
        ? const Icon(Icons.error)
        : CachedNetworkImage(
            imageUrl: widget._fetchResponse.thumbnail!,
            progressIndicatorBuilder: (context, url, downloadProgress) =>
                CircularProgressIndicator(value: downloadProgress.progress),
            errorWidget: (context, url, error) => const Icon(Icons.error),
            fit: BoxFit.cover,
            filterQuality: FilterQuality.medium);
  }

  Widget _buildCenter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
            child: Container(padding: const EdgeInsets.only(right: 60), child: _buildThumbnail())),
        Flexible(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitleText(),
              _buildTopRow(),
              //TODO: Overflow prevention
              const Text(
                'Overview',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                widget._fetchResponse.description ?? 'N/A',
                maxLines: 5,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopRow() {
    return Flexible(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(5))),
            child: Text(
              widget._fetchResponse.type.name.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(
            width: 25,
          ),
          widget._fetchResponse.duration != null
              ? Text(
                  widget._fetchResponse.duration!,
                )
              : Container(),
        ],
      ),
    );
  }

  Widget _buildResponseWidget() {
    final FetchResponse fetchResponse = widget._fetchResponse;

    if (fetchResponse is MovieFetchResponse) {
      return MovieWidget(fetchResponse);
    } else if (fetchResponse is TvFetchResponse) {
      return TvWidget(fetchResponse);
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    final FetchResponse fetchResponse = widget._fetchResponse;
    return Scaffold(
      appBar: AppBar(
        //title: _buildTitleText(),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(children: [
        HalfPageImage(
            tag: fetchResponse.data,
            imageURL: fetchResponse.backgroundImage,
            headers: fetchResponse.thumbnailHeaders),
        Container(
          padding: const EdgeInsets.all(70),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _buildCenter()),
              Flexible(child: _buildResponseWidget()),
            ],
          ),
        )
      ]),
    );
  }
}
