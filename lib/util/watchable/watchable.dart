import 'package:viddroid/util/watchable/season.dart';

abstract class Watchable {
  final int _id;
  final String? _title;
  final String? _description;
  final String _apiUrl;
  final String? _thumbnail;

  Watchable(this._id, this._title, this._description, this._apiUrl, this._thumbnail);

  int get id => _id;

  @override
  String toString() => 'Watchable "$_title" with id: $_id';

  String get apiUrl => _apiUrl;

  //TODO: Poster-path default
  String? get thumbnail => _thumbnail!;

  String? get title => _title;

  String? get description => _description;
}

class TVShow extends Watchable {
  final List<Season> _seasons = [];

  TVShow(dynamic json)
      : super(
            json['id'], json['name'], json['overview'], json['backdrop_path'], json['poster_path']);

  void addSeason(int index, Season season) =>
      index == -1 ? _seasons.add(season) : _seasons[index] = season;

  List<Season> get getSeasons => _seasons;
}

class Movie extends Watchable {
  Movie(dynamic json)
      : super(json['id'], json['title'], json['overview'], json['backdrop_path'],
            json['poster_path']);
}
