
import 'package:hive/hive.dart';

part 'media.g.dart';

@HiveType(typeId: 69)
enum TvType {
  @HiveField(0)
  movie,
  @HiveField(1)
  tv,
  @HiveField(2)
  anime,
  //TODO: Add more in the future.
}

enum MediaType {
  m3u8,
  video,
}

enum MediaQuality {
  unknown(400),
  p_144(144), // 144p
  p_240(240), // 240p
  p_360(360), // 360p
  p_480(480), // 480p
  p_720(720), // 720p
  p_1080(1080), // 1080p
  p_1440(1440), // 1440p
  p_2160(2160); //4k or 2160p

  final int quality;

  const MediaQuality(this.quality);
}

extension MediaQualityExtension on MediaQuality {
  static MediaQuality fromString(final String? string) {
    if (string == null) {
      return MediaQuality.unknown;
    }

    return MediaQuality.values.firstWhere((element) => element.quality.toString() == string,
        orElse: () => MediaQuality.unknown);
  }
}
