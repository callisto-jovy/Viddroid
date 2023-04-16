import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:subtitle/subtitle.dart';
import 'package:viddroid_flutter_desktop/constants.dart';
import 'package:viddroid_flutter_desktop/util/capsules/link.dart';
import 'package:viddroid_flutter_desktop/util/capsules/option_item.dart';
import 'package:viddroid_flutter_desktop/util/download/downloader.dart';
import 'package:viddroid_flutter_desktop/util/extensions/string_extension.dart';
import 'package:viddroid_flutter_desktop/widgets/player/option_dialog.dart';
import 'package:viddroid_flutter_desktop/widgets/player/playback_speed_dialog.dart';
import 'package:viddroid_flutter_desktop/widgets/player/seek_bar_widget.dart';
import 'package:viddroid_flutter_desktop/widgets/player/subtitle_widget.dart';
import 'package:wakelock/wakelock.dart';
import 'package:window_manager/window_manager.dart';

import '../util/capsules/subtitle.dart' as internal;
import '../util/setting/settings.dart';
import '../util/watchable/watchables.dart';
import '../widgets/player/center_play_button.dart';
import '../widgets/snackbars.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class VideoPlayer extends StatefulWidget {
  final Stream<LinkResponse> stream;
  final String title;
  final String hash;

  const VideoPlayer({
    Key? key,
    required this.stream,
    required this.title,
    required this.hash,
  }) : super(key: key);

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  // Create a [Player] instance from `package:media_kit`.
  final Player _player = Player(
    configuration: const PlayerConfiguration(
      logLevel: MPVLogLevel.warn,
      title: 'Viddroid'
    )
  );

  // Reference to the [VideoController] instance from `package:media_kit_video`.
  VideoController? _controller;

  // List of all current Responses [LinkResponse] from the stream.
  final List<LinkResponse> _responses = [];

  // The current playback link.
  LinkResponse? _currentLink;

  // Hardcoded list of all the possible playback speeds
  static const List<double> _playbackSpeeds = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  // [Timer] instance which is triggered and reset to hide / display the overlay ui
  Timer? _hideTimer;

  bool _hideOverlay = false;
  bool _playing = false;

  final StreamController<SubtitleController> subtitleStream = StreamController();

  // [Duration] which is non-null if the source was changed.
  Duration? _lastPosition;

  @override
  void initState() {
    super.initState();
    //Timers
    _startHideTimer();
    try {
      Future.microtask(() async {
        //TODO: Setting
        // Enable the wakelock
        await Wakelock.enable();

        if (Platform.isWindows && Settings().get(Settings.changeFullscreen)) {
          await WindowManager.instance.setFullScreen(true);
        }
        // Create a [VideoController] instance from `package:media_kit_video`.
        // Pass the [handle] of the [Player] from `package:media_kit` to the [VideoController] constructor.
        widget.stream.asBroadcastStream().listen((event) {
          _responses.add(event);
          _currentLink ??= event; //First element from the stream.

          //Autoplay
          if (!_playing) {
            _changeVideoSource(event);
          }
        }).onError((error, stackTrace) {
          ScaffoldMessenger.of(context).showSnackBar(errorSnackbar(error.toString()));
          logger.e(error.toString(), error, stackTrace);
        }); // Display message on error.

        _controller = await VideoController.create(_player);

        // Listen to the streams; print occurring errors.
        _player.streams.playing.listen((event) => _playing = event);
        // Only needed to restore the player to its previous state. I haven't found another way for now.
        // This unfortunately also applies whenever the stream is switched.
        _player.streams.duration.listen((event) {
          // Load the previous state if possible
          if (Settings().get(Settings.keepPlayback, true) && _lastPosition == null) {
            final Duration? previousState = Watchables().getTimestamp(widget.hash);
            if (previousState != null) {
              _player.seek(previousState);
            }
          }
          // Overwrite the previous state if the source was changed.
          if (_lastPosition != null) {
            _player.seek(_lastPosition!);
          }
        });
        // Must be created before opening any media. Otherwise, a separate window will be created.
        setState(() {});
      });
    } catch (e, s) {
      logger.e('An error occurred in the video_player init', e, s);
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();

    // Save the current state. TODO: dont save if close to end.
    if (Settings().get(Settings.keepPlayback, true)) {
      Watchables().saveTimestamp(widget.hash, _player.state.position);
    }

    Future.microtask(() async {
      // Release allocated resources back to the system.
      await subtitleStream.close();
      await _controller?.dispose();
      await _player.dispose();
      if (Platform.isWindows && Settings().get(Settings.changeFullscreen)) {
        await WindowManager.instance.setFullScreen(false);
      }
      // Disable the Wakelock, as to not mess with the systems functionality.
      await Wakelock.disable();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: MouseRegion(
        onHover: (event) => _cancelAndRestartTimer(),
        child: GestureDetector(
          onTap: () => _cancelAndRestartTimer(),
          child: AbsorbPointer(
            absorbing: _hideOverlay,
            child: Stack(
              children: [
                Video(
                  controller: _controller,
                ),
                //  _buildHitArea(), NOTE: Removed for now.
                _buildSubtitles(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildSeekbar(),
                    //Place for subtitles
                  ],
                ),
                //SeekBar(player: _player),
                //const SizedBox(height: 32.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _startHideTimer() {
    //TODO: Timer duration
    _hideTimer = Timer(const Duration(milliseconds: 500, seconds: 1), () {
      setState(() {
        _hideOverlay = true;
      });
    });
  }

  void _cancelAndRestartTimer() {
    _hideTimer?.cancel();
    _startHideTimer();

    setState(() {
      _hideOverlay = false;
    });
  }

  void _togglePlaying({bool? player}) {
    if (player != null && player) {
      _player.playOrPause();
    }
    _playing = !_playing;
  }

  void _changeVideoSource(final LinkResponse response) async {
    _currentLink = response;
    // I have to do this for now. Unfortunate.
    // Saves the previous position if the position is not null, not the start of the playback.
    final Duration previousPosition = _player.state.position;
    if (previousPosition.inSeconds != 0) {
      _lastPosition = previousPosition;
    }

    if (_player.platform is libmpvPlayer) {
      final String properties =
          response.header?.entries.map((e) => "'${e.key}: ${e.value}'").join(',') ?? '';

      final libmpvPlayer? player = _player.platform as libmpvPlayer?;

      await player?.setProperty('user-agent', userAgent);
      await player?.setProperty('referrer', response.referer);
      await player?.setProperty('http-header-fields', properties);
 //     await player?.setProperty('demuxer-lavf-o', 'protocol_whitelist=[file,tcp,tls,https,crypto,data]');
    }

    await _player.open(Playlist([
      Media(
        response.url,
      ),
    ]));
    //The player is definitely playing at this point
    _playing = _player.state.playing;
    // Seek to the previous position
    await _player.seek(previousPosition);
  }

  void _changePlaybackSpeed(final double? playbackSpeed) {
    if (playbackSpeed == null) {
      return;
    }
    _player.setRate(playbackSpeed);
  }

  void _changeSubtitle(final internal.Subtitle subtitle) async {
    final Uri url = Uri.parse(subtitle.url);
    SubtitleController subtitleController = SubtitleController(
      provider: SubtitleProvider.fromNetwork(url),
    );
    await subtitleController.initial();
    subtitleStream.add(subtitleController);
  }

  Widget _buildSubtitles() {
    return SubtitleWidget(player: _player, subtitleStream: subtitleStream);
  }

  Widget _buildHitArea() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _togglePlaying(player: true);
          _hideOverlay = true;
        });
      },
      child: CenterPlayButton(
        backgroundColor: Colors.black54,
        iconColor: Colors.white,
        isFinished: false,
        isPlaying: _playing,
        show: !_hideOverlay,
        //  onPressed: () => _togglePlaying(player: true),
      ),
    );
  }

  Widget _buildSeekbar() {
    return AnimatedOpacity(
      opacity: _hideOverlay ? 0 : 1,
      duration: const Duration(milliseconds: 300),
      child: Container(
          padding: const EdgeInsets.only(top: 50),
          child: SafeArea(
              child: Row(
            children: [
              Expanded(child: SeekBar(player: _player)),
              _buildMenuButton(),
            ],
          ))),
    );
  }

  Widget _buildMenuButton() {
    return AnimatedOpacity(
      opacity: _hideOverlay ? 0 : 1,
      duration: const Duration(milliseconds: 300),
      child: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () async {
          await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => _buildMenuList(),
          );
        },
      ),
    );
  }

  Widget _buildMenuList() {
    return OptionsDialog(options: [
      OptionItem(
          onTap: () async {
            // Pop old material dialog
            Navigator.pop(context);
            _changePlaybackSpeed(await showModalBottomSheet<double>(
              context: context,
              isScrollControlled: true,
              builder: (_) => const PlaybackSpeedDialog(speeds: _playbackSpeeds, selected: 1.0),
            ));
          },
          iconData: Icons.speed_outlined,
          title: 'Playback Speed'),
      OptionItem(
          onTap: () async {
            Navigator.pop(context);
            await showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => _buildStreamerList(),
            );
          },
          iconData: Icons.video_collection,
          title: 'Stream Source'),
      OptionItem(
          onTap: () async {
            Navigator.pop(context);
            await showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => _buildSubtitleList(),
            );
          },
          iconData: Icons.subtitles,
          title: 'Subtitles'),
      OptionItem(
          onTap: () async {
            Navigator.pop(context);
            //Pause the player
            _togglePlaying(player: true);

            final String? result = await FilePicker.platform.saveFile(
                dialogTitle: 'Please select where to save the file.',
                fileName: widget.title.cleanWindows);

            // Dialog has been aborted
            if (result == null || _currentLink == null) {
              return;
            }

            //Show notification
            LocalNotification(
              title: "Download",
              body: "Starting to download",
            ).show();

            Downloaders()
                .getDownloader(_currentLink!, result)
                ?.download(
                  (p0) => logger.i('Downloading with process $p0'),
                )
                .onError((error, stackTrace) =>
                    LocalNotification(title: "Download", body: error.toString()).show());
          },
          iconData: Icons.download,
          title: 'Download')
    ]);
  }

  // List view from all possible stream options
  Widget _buildStreamerList() {
    final List<OptionItem> options = _responses
        .map((e) => OptionItem(
              onTap: () {
                Navigator.pop(context);
                _changeVideoSource(e);
              },
              title: e.title != null ? '${e.title}/${e.mediaQuality.name}' : 'N/A',
              iconData: Icons.video_collection,
            ))
        .toList();
    return OptionsDialog(options: options);
  }

  // List view from all possible stream options
  Widget _buildSubtitleList() {
    if (_currentLink?.subtitles == null) {
      return OptionsDialog(options: List.empty());
    }

    final List<OptionItem> options = _currentLink!.subtitles!
        .map((e) => OptionItem(
              onTap: () {
                Navigator.pop(context);
                _changeSubtitle(e);
              },
              title: '${e.name} - ${e.language}',
              iconData: Icons.subtitles,
            ))
        .toList();
    return OptionsDialog(options: options);
  }
}
