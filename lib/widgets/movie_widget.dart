import 'package:flutter/material.dart';
import 'package:viddroid_flutter_desktop/util/capsules/fetch.dart';
import 'package:viddroid_flutter_desktop/util/capsules/link.dart';
import 'package:viddroid_flutter_desktop/views/video_player.dart';

import '../provider/providers.dart';

class MovieWidget extends StatefulWidget {
  final MovieFetchResponse _fetchResponse;

  late final List<DropdownMenuItem> _seasons;

  MovieWidget(this._fetchResponse, {Key? key}) : super(key: key) {
    _seasons = [
      const DropdownMenuItem(
        value: 0,
        child: Text('0'),
      )
    ];
  }

  @override
  State<MovieWidget> createState() => _MovieWidgetState();
}

class _MovieWidgetState extends State<MovieWidget> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  void _displayVideoPlayer(final LoadRequest loadRequest) {
    final Route route = MaterialPageRoute(
        builder: (context) =>
            VideoPlayer(Providers().provider(widget._fetchResponse.apiName).load(loadRequest)));
    Navigator.pushReplacement(context, route);
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return SizedBox(
      child: ElevatedButton.icon(
        onPressed: () => _displayVideoPlayer(widget._fetchResponse.toLoadRequest()),
        icon: const Icon(Icons.play_arrow),
        label: const Text('Play'),
      ),
    );
  }
}
