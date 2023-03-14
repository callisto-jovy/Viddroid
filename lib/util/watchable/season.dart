import '../capsules/fetch.dart';

class Season {
  int seasonIndex;
  List<Episode> episodes = [];

  Season(this.seasonIndex);

  void addEpisode(Episode episode) {
    episodes.add(episode);
  }
}
