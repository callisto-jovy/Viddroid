import 'package:viddroid/extractor/extractor.dart';
import 'package:viddroid/extractor/extractors/doki_cloud_extractor.dart';
import 'package:viddroid/extractor/extractors/mix_drop_extractor.dart';
import 'package:viddroid/extractor/extractors/rabbit_stream_extractor.dart';
import 'package:viddroid/extractor/extractors/stream_hub_extractor.dart';
import 'package:viddroid/extractor/extractors/stream_tape_extractor.dart';
import 'package:viddroid/extractor/extractors/vid_src_extractor.dart';
import 'package:viddroid/extractor/extractors/vidoza_extractor.dart';

import 'extractors/dood_stream_extractor.dart';

class Extractors {
  static final Extractors _instance = Extractors.inst();

  factory Extractors() {
    return _instance;
  }

  Extractors.inst();

  final List<Extractor> extractors = [
    VidSrcExtractor(),
    DoodStreamExtractor(),
    DokiCloudExtractor(),
    StreamTapeExtractor(),
    MixDropExtractor(),
    RabbitStreamExtractor(),
    VidozaExtractor(),
    StreamHubExtractor()
  ];

  Extractor? findExtractor(final String url) {
    for (final Extractor extr in extractors) {
      if (extr.mainUrl == url || (extr.altUrls != null && extr.altUrls!.contains(url))) {
        return extr;
      }
    }
    return null;
  }
}
