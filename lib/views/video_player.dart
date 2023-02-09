import 'package:flutter/material.dart';
import 'package:viddroid_flutter_desktop/util/capsules/link.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class VideoPlayer extends StatefulWidget {
  final LinkResponse _linkResponse;

  const VideoPlayer(this._linkResponse, {Key? key}) : super(key: key);

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
