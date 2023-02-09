import 'package:viddroid_flutter_desktop/util/capsules/media.dart';

import '../util/capsules/link.dart';

class Episode {
  final String _name;
  final int _index;
  final int _season;
  final String? _thumbnail;
  final String data;

  Episode(this._name, this._index, this._season, this._thumbnail, this.data);

  String? get thumbnail => _thumbnail;

  int get season => _season;

  int get index => _index;

  String get name => _name;

  @override
  String toString() {
    return 'Episode{_name: $_name, _index: $_index, _season: $_season, _thumbnail: $_thumbnail}';
  }

  //TODO: Poster-path default
  String? getSeasonPosterPath() => thumbnail!;

  LoadRequest toLoadRequest() {
    return TvLoadRequest(data, TvType.tv, name, episode: index, season: season);
  }
}
