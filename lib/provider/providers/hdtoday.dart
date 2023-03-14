import 'package:hive/hive.dart';
import 'package:viddroid_flutter_desktop/provider/providers/sflix.dart';

part 'hdtoday.g.dart';

@HiveType(typeId: 7)
class HdToday extends Sflix {
  @override
  String get mainUrl => 'https://hdtoday.cc';

  @override
  String get name => 'HDToday';
}
