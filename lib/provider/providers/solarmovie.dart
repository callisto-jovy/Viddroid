import 'package:hive_flutter/hive_flutter.dart';
import 'package:viddroid_flutter_desktop/provider/providers/sflix.dart';

part 'solarmovie.g.dart';

@HiveType(typeId: 10)
class SolarMovie extends Sflix {
  @override
  String get mainUrl => 'https://solarmovie.pe';

  @override
  String get name => 'SolarMovie';
}
