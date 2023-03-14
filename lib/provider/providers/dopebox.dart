import 'package:hive_flutter/hive_flutter.dart';
import 'package:viddroid_flutter_desktop/provider/providers/sflix.dart';

part 'dopebox.g.dart';

@HiveType(typeId: 6)
class DopeBox extends Sflix {
  @override
  String get mainUrl => 'https://dopebox.to';

  @override
  String get name => 'Dopebox';
}
