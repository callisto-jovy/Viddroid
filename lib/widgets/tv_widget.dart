import 'package:flutter/material.dart';
import 'package:viddroid/util/capsules/fetch.dart';
import 'package:viddroid/util/extensions/string_extension.dart';
import 'package:viddroid/views/video_player.dart';
import 'package:viddroid/widgets/cards/episode_card.dart';

import '../provider/providers.dart';

class TvWidget extends StatefulWidget {
  final TvFetchResponse _fetchResponse;

  late final List<DropdownMenuItem<int>> _seasons;

  TvWidget(this._fetchResponse, {super.key}) {
    _seasons = List.generate(_fetchResponse.seasons, (index) => index)
        .map((index) => DropdownMenuItem(value: index, child: Text('Season $index')))
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

  void _displayVideoPlayer(final Episode episode) {
    // Hash calculated with The provider, the tv title, the season and the index.
    final String episodeHash =
        '${widget._fetchResponse.apiName}${widget._fetchResponse.title}${episode.season}${episode.index}'
            .toMD5;

    final Route route = MaterialPageRoute(
        builder: (context) => VideoPlayer(
            hash: episodeHash,
            stream:
                Providers().provider(widget._fetchResponse.apiName).load(episode.toLoadRequest()),
            title: widget._fetchResponse.title));
    Navigator.pushReplacement(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        DropdownButton<int>(
          icon: const Icon(Icons.menu),
          items: widget._seasons,
          onChanged: (int? value) => setState(() {
            dropdownValue = value ?? 0;
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
                        onTap: () => _displayVideoPlayer(episodes[index]),
                        child: EpisodeCard(episodes[index])));
              },
            ),
          ),
        )
      ],
    );
  }
}
