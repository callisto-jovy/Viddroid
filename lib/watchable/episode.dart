
class Episode {
  final String _name;
  final int _index;
  final int _season;
  final String? _poster;

  Episode(this._name, this._index, this._season, this._poster);

  String? get poster => _poster;

  int get season => _season;

  int get index => _index;

  String get name => _name;

  @override
  String toString() {
    return 'Episode{_name: $_name, _index: $_index, _season: $_season, _poster: $_poster}';
  }

  //TODO: Poster-path default
  String? getSeasonPosterPath() => poster!;
}
