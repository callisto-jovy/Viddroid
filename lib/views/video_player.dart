import 'dart:async';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:subtitle/subtitle.dart';
import 'package:viddroid/constants.dart';
import 'package:viddroid/util/capsules/link.dart';
import 'package:viddroid/util/capsules/option_item.dart';
import 'package:viddroid/util/download/downloader.dart';
import 'package:viddroid/util/extensions/string_extension.dart';
import 'package:viddroid/util/video_player_intents.dart';
import 'package:viddroid/widgets/player/option_dialog.dart';
import 'package:viddroid/widgets/player/playback_speed_dialog.dart';
import 'package:viddroid/widgets/player/subtitle_widget.dart';

import '../util/capsules/subtitle.dart' as internal;
import '../util/setting/settings.dart';
import '../util/watchable/watchables.dart';
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
  /// Create a [Player] instance from `package:media_kit`. And configure it.
  late final Player _player = Player(
      configuration: const PlayerConfiguration(logLevel: MPVLogLevel.warn, title: 'Viddroid'));

  /// Reference to the [VideoController] instance from `package:media_kit_video`.
  late final VideoController _controller = VideoController(_player);

  /// [List] of all current Responses [LinkResponse] from the stream.
  final List<LinkResponse> _responses = [];

  /// [List] of all current video tracks [VideoTrack] available.

  final List<VideoTrack> _videoTracks = [];

  /// The current playback link.
  LinkResponse? _currentLink;

  /// Hardcoded [List] of all the possible playback speeds
  static const List<double> _playbackSpeeds = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  /// [bool] which indicates whether the player is playing something right now. Used for autoplay
  bool _playing = false;

  /// [StreamController] which ensures that the selected subtitle is played. The controller is passed to the [SubtitleWidget]
  final StreamController<SubtitleController> _subtitleStream = StreamController();

  /// [Duration] which is non-null if the source was changed.
  Duration? _lastPosition;

  /// [Duration] pulled from the settings which determines how far to offset the player when skipping forward/backward
  final Duration _seekDuration = Duration(seconds: Settings().get(Settings.seekSpeed, 5));

  @override
  void initState() {
    super.initState();

    try {
      Future.microtask(() async {
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
          if (error is DioError) {
            logger.i(error.response?.realUri);
            logger.i(error.response?.data);
          }
        }); // Display message on error.

        // Listen for video tracks which may be selected.
        _player.stream.tracks.listen((event) {
          _videoTracks.addAll(event.video);
        });

        // Listen to the streams; print occurring errors.
        _player.stream.playing.listen((event) => _playing = event);
        // Only needed to restore the player to its previous state. I haven't found another way for now.
        // This unfortunately also applies whenever the stream is switched.
        _player.stream.duration.listen((event) {
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
    // Save the current state if keep_playback is toggled & more than 30 seconds are still left.
    if (Settings().get(Settings.keepPlayback, true) &&
        (_player.state.duration - _player.state.position).inSeconds > 30) {
      Watchables().saveTimestamp(widget.hash, _player.state.position);
    }

    Future.microtask(() async {
      // Release allocated resources back to the system.
      await _subtitleStream.close();
      await _player.dispose();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FocusableActionDetector(
        autofocus: true,
        actions: {
          SpaceIntent: CallbackAction<Intent>(onInvoke: (_) => _togglePlaying(player: true)),
          SkipBackwardIntent:
              CallbackAction<Intent>(onInvoke: (_) => _movePosition(-_seekDuration)),
          SkipForwardIntent: CallbackAction<Intent>(onInvoke: (_) => _movePosition(_seekDuration)),
        },
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.space): SpaceIntent(),
          SingleActivator(LogicalKeyboardKey.arrowLeft): SkipBackwardIntent(),
          SingleActivator(LogicalKeyboardKey.arrowRight): SkipForwardIntent(),
        },
        child: Stack(
          children: [
            _buildVideo(),
            //  _buildHitArea(), NOTE: Removed for now.
            _buildSubtitles()
            //SeekBar(player: _player),
            //const SizedBox(height: 32.0),
          ],
        ),
      ),
    );
  }

  void _movePosition(Duration offset) {
    _player.seek(_player.state.position + offset);
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

    await _player.open(Playlist([
      Media(
        response.url,
        httpHeaders: {'user-agent': userAgent, 'referrer': response.referer, ...?response.header},
      ),
    ]));
    //The player is definitely playing at this point
    _playing = _player.state.playing;
    // Seek to the previous position
    await _player.seek(previousPosition);
  }

  void _changeVideoTrack(final VideoTrack selected) async {
    await _player.setVideoTrack(selected);
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
    _subtitleStream.add(subtitleController);
  }

  Widget _buildSubtitles() {
    return SubtitleWidget(player: _player, subtitleStream: _subtitleStream);
  }

  Widget _buildVideo() {
    return MaterialDesktopVideoControlsTheme(
      normal: MaterialDesktopVideoControlsThemeData(
        // Modify theme options:
        buttonBarButtonSize: 24.0,
        buttonBarButtonColor: Colors.white,
        // Modify top button bar:
        topButtonBar: [_buildBackButton(), const Spacer(), _buildMenuButton()],
      ),
      fullscreen: const MaterialDesktopVideoControlsThemeData(
        // Modify theme options:
        displaySeekBar: false,
        automaticallyImplySkipNextButton: false,
        automaticallyImplySkipPreviousButton: false,
      ),
      child: Scaffold(
        body: Video(
          controller: _controller,
          wakelock: Settings().get(Settings.wakelock, true),
        ),
      ),
    );
  }

  Widget _buildMenuButton() {
    return MaterialDesktopCustomButton(
      icon: const Icon(Icons.menu),
      onPressed: () async {
        await showModalBottomSheet(
          context: context,
          shape: const BeveledRectangleBorder(),
          isScrollControlled: true,
          constraints: const BoxConstraints.tightForFinite(height: 300),
          builder: (_) => _buildMenuList(),
        );
      },
    );
  }

  Widget _buildBackButton() {
    return const BackButton(color: Colors.white);
  }

  /// TODO: Move bottom modal sheet to its own method with a function callback
  Widget _buildMenuList() {
    return OptionsDialog(options: [
      OptionItem(
          onTap: () async {
            // Pop old material dialog
            Navigator.pop(context);
            _changePlaybackSpeed(await showModalBottomSheet<double>(
              context: context,
              shape: const BeveledRectangleBorder(),
              isScrollControlled: true,
              constraints: const BoxConstraints.tightForFinite(height: 300),
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
              shape: const BeveledRectangleBorder(),
              isScrollControlled: true,
              constraints: const BoxConstraints.tightForFinite(height: 300),
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
              shape: const BeveledRectangleBorder(),
              isScrollControlled: true,
              constraints: const BoxConstraints.tightForFinite(height: 300),
              builder: (_) => _buildVideoTracksList(),
            );
          },
          iconData: Icons.fullscreen,
          title: 'Video track'),
      OptionItem(
          onTap: () async {
            Navigator.pop(context);
            await showModalBottomSheet(
              context: context,
              shape: const BeveledRectangleBorder(),
              isScrollControlled: true,
              constraints: const BoxConstraints.tightForFinite(height: 300),
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

  Widget _buildVideoTracksList() {
    final List<OptionItem> options = _videoTracks
        .map((e) => OptionItem(
              onTap: () {
                Navigator.pop(context);
                _changeVideoTrack(e);
              },
              title: '${e.title}/${e.id}',
              iconData: Icons.video_collection,
            ))
        .toList();
    return OptionsDialog(options: options);
  }

  // List view from all possible subtitle options
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
