import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:viddroid_flutter_desktop/util/fetch.dart';
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
  Widget build(BuildContext context) {
    return Expanded(
      flex: 8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          DropdownButton(
            icon: const Icon(Icons.menu),
            items: widget._seasons,
            onChanged: (value) => setState(() {
              dropdownValue = value!;
              episodes = widget._fetchResponse.episodes
                  .where((element) => element.season == dropdownValue)
                  .toList();
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
                          onTap: () {
                            Providers()
                                .siteProviders
                                .where((element) => widget._fetchResponse.apiName == element.name)
                                .forEach((element) {
                              element
                                  .load(widget._fetchResponse
                                      .toTvLoadRequest(episodes[index].season, index + 1))
                                  .listen((event) {
                                print(event);
                              });
                            });
                          },
                          child: EpisodeCard(episodes[index])));
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
