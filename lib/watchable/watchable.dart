import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:viddroid_flutter_desktop/watchable/season.dart';

@HiveType(typeId: 0)
abstract class Watchable {
  @HiveField(0)
  final int _id;
  @HiveField(1)
  final String? _title;
  @HiveField(2)
  final String? _description;
  @HiveField(3)
  final String _apiUrl;
  @HiveField(4)
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
