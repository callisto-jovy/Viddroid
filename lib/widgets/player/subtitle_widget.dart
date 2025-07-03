import 'dart:async';

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:subtitle/subtitle.dart';

class SubtitleWidget extends StatefulWidget {
  final Player player;

  final StreamController<SubtitleController> subtitleStream;

  const SubtitleWidget({super.key, required this.player, required this.subtitleStream});

  @override
  State<SubtitleWidget> createState() => _SubtitleWidgetState();
}

class _SubtitleWidgetState extends State<SubtitleWidget> {
  Duration position = Duration.zero;
  SubtitleController? subtitleController;
  Subtitle? subtitle;

  List<StreamSubscription> subscriptions = [];

  @override
  void initState() {
    super.initState();
    position = widget.player.state.position;

    subscriptions.addAll(
      [
        widget.subtitleStream.stream.listen((event) {
          setState(() {
            subtitleController = event;
            subtitle = subtitleController?.durationSearch(position);
          });
        }),
        //TODO: Just increment; this is inefficient for now.
        widget.player.streams.position.listen((event) {
          setState(() {
            position = event;
            subtitle = subtitleController?.durationSearch(position);
          });
        }),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    for (final s in subscriptions) {
      s.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(30),
          child: Text(
            softWrap: true,
            subtitle?.data ?? '',
            style:
                const TextStyle(backgroundColor: Colors.black54, fontSize: 25, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
