import 'package:hive_flutter/hive_flutter.dart';
import 'package:viddroid_flutter_desktop/util/watchable/watchable.dart';

class Watchables {
  static final Watchables _instance = Watchables._inst();

  Watchables._inst();

  factory Watchables() {
    return _instance;
  }

  late Box<Watchable> watchablesBox;

  Future<void> init() async {
    watchablesBox = await Hive.openBox('watchables');

    //Debug: Insert dummy data:
    /*
    Movie watchable = Movie({'id': 0000, 'title': 'Generic Movie #1', 'overview': 'Sample'});
    for (int i = 0; i < 4; i++) {
      watchablesBox.put('id:$i', watchable);
    }

     */
  }

  List<Watchable> get watchables {
    return watchablesBox.values.toList();
  }
}
