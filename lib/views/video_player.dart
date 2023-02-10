import 'dart:async';

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:viddroid_flutter_desktop/util/capsules/link.dart';

import '../widgets/seek_bar_widget.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class VideoPlayer extends StatefulWidget {
  //final LinkResponse _linkResponse;

  final Stream<LinkResponse> _stream;

  const VideoPlayer(this._stream, {Key? key}) : super(key: key);

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  // Create a [Player] instance from `package:media_kit`.
  final Player _player = Player();

  // Reference to the [VideoController] instance from `package:media_kit_video`.
  VideoController? _controller;

  final List<LinkResponse> responses = [];
  final StreamController<List<LinkResponse>> _streamController = StreamController();

  LinkResponse? _currentLink;

  final List<double> _playbackSpeeds = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
  double _playbackSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      // Create a [VideoController] instance from `package:media_kit_video`.
      // Pass the [handle] of the [Player] from `package:media_kit` to the [VideoController] constructor.

      /*
      await _player.open(Playlist([
        Media(widget._linkResponse.url),
      ]));

       */

      widget._stream.asBroadcastStream().listen((event) {
        //TODO: Figure out a better way
        responses.add(event);
        _currentLink ??= event; //First element from the stream.
        //Notify the controller.
        _streamController.add(responses);
      });
      _controller = await VideoController.create(_player.handle);
      //

      // Must be created before opening any media. Otherwise, a separate window will be created.
      setState(() {});
    });
  }

  @override
  void dispose() {
    //  _streamController.close();
    Future.microtask(() async {
      // Release allocated resources back to the system.
      await _controller?.dispose();
      await _player.dispose();
    });
    super.dispose();
  }

  void _changeVideoSource(final LinkResponse index) async {
    // await _player.
    _currentLink = index;
    await _player.open(Playlist([
      Media(index.url),
    ]));
  }

  void _changePlaybackSpeed(final double playbackSpeed) {
    _playbackSpeed = playbackSpeed;
    _player.rate = playbackSpeed;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          StreamBuilder<List<LinkResponse>>(
            stream: _streamController.stream,
            builder: (BuildContext context, AsyncSnapshot<List<LinkResponse>> snapshot) {
              if (snapshot.hasData) {
                return DropdownButton(
                  value: _currentLink,
                  disabledHint: const Text('Loading...'),
                  items: snapshot.data!
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child:
                                Text(e.title != null ? '${e.title}/${e.mediaQuality.name}' : 'N/A'),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() {
                    _changeVideoSource(value!);
                  }),
                );
              } else {
                return Container();
              }
            },
          ),
          DropdownButton(
            value: _playbackSpeed,
            items: _playbackSpeeds
                .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(e.toString()),
                    ))
                .toList(),
            onChanged: (value) => setState(() {
              _changePlaybackSpeed(value!);
            }),
          )
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                //Display video controls
              },
              child: Video(
                controller: _controller,
              ),
            ),
          ),
          SeekBar(player: _player),
          const SizedBox(height: 32.0),
        ],
      ),
    );
  }
}
