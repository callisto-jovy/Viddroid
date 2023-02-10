import 'dart:async';

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';


class SeekBar extends StatefulWidget {
  final Player player;

  const SeekBar({
    Key? key,
    required this.player,
  }) : super(key: key);

  @override
  State<SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  bool isPlaying = false;
  Duration position = Duration.zero;
  Duration duration = Duration.zero;

  List<StreamSubscription> subscriptions = [];

  @override
  void initState() {
    super.initState();
    isPlaying = widget.player.state.isPlaying;
    position = widget.player.state.position;
    duration = widget.player.state.duration;
    subscriptions.addAll(
      [
        widget.player.streams.isPlaying.listen((event) {
          setState(() {
            isPlaying = event;
          });
        }),
        widget.player.streams.position.listen((event) {
          setState(() {
            position = event;
          });
        }),
        widget.player.streams.duration.listen((event) {
          setState(() {
            duration = event;
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 48.0),
        IconButton(
          onPressed: widget.player.playOrPause,
          icon: Icon(
            isPlaying ? Icons.pause : Icons.play_arrow,
          ),
          color: Theme.of(context).primaryColor,
          iconSize: 36.0,
        ),
        const SizedBox(width: 24.0),
        Text(position.toString().substring(2, 7)),
        Expanded(
          child: Slider(
            min: 0.0,
            max: duration.inMilliseconds.toDouble(),
            value: position.inMilliseconds.toDouble().clamp(
                  0,
                  duration.inMilliseconds.toDouble(),
                ),
            onChanged: (e) {
              setState(() {
                position = Duration(milliseconds: e ~/ 1);
              });
            },
            onChangeEnd: (e) {
              widget.player.seek(Duration(milliseconds: e ~/ 1));
            },
          ),
        ),
        Text(duration.toString().substring(2, 7)),
        const SizedBox(width: 48.0),
      ],
    );
  }
}
