import 'package:flutter/material.dart';
import 'package:viddroid_flutter_desktop/util/capsules/fetch.dart';
import 'package:viddroid_flutter_desktop/util/capsules/link.dart';
import 'package:viddroid_flutter_desktop/views/video_player.dart';
import 'package:viddroid_flutter_desktop/watchable/episode.dart';
import 'package:viddroid_flutter_desktop/widgets/cards/episode_card.dart';

import '../provider/providers.dart';

class TvWidget extends StatefulWidget {
  final TvFetchResponse _fetchResponse;

  late final List<DropdownMenuItem> _seasons;

  TvWidget(this._fetchResponse, {Key? key}) : super(key: key) {
    _seasons = List.generate(_fetchResponse.seasons, (index) => index)
        .map((event) => DropdownMenuItem(value: event, child: Text('Season $event')))
        .toList();
  }

  @override
  State<TvWidget> createState() => _TvWidgetState();
}

class _TvWidgetState extends State<TvWidget> {
  int dropdownValue = 0;
  List<Episode> episodes = [];

  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadEpisodesForSeason();
  }

  void _loadEpisodesForSeason() {
    episodes =
        widget._fetchResponse.episodes.where((element) => element.season == dropdownValue).toList();
  }

  void _displayVideoPlayer(final LoadRequest loadRequest) {
    final Route route = MaterialPageRoute(
        builder: (context) => VideoPlayer(
            stream: Providers().provider(widget._fetchResponse.apiName).load(loadRequest),
            title: widget._fetchResponse.title));
    Navigator.pushReplacement(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        DropdownButton(
          icon: const Icon(Icons.menu),
          items: widget._seasons,
          onChanged: (value) => setState(() {
            dropdownValue = value!;
            _loadEpisodesForSeason();
          }),
          value: dropdownValue,
        ),
        Expanded(
          child: Scrollbar(
            controller: _scrollController,
            child: ListView.builder(
              shrinkWrap: true,
              controller: _scrollController,
              itemCount: episodes.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return Container(
                    padding: const EdgeInsets.all(10),
                    child: InkWell(
                        onTap: () => _displayVideoPlayer(episodes[index].toLoadRequest()),
                        child: EpisodeCard(episodes[index])));
              },
            ),
          ),
        )
      ],
    );
  }
}
